/** First Wollok example */

class LoteCerveza {
	const lupulo
	const azucar
	
	method costo() {
		return self.costoLupulo() + self.costoElaboracion()
	}
	
	method costoLupulo() {
		return lupulo.costo()
	}
	method costoElaboracion()	
	method descuento()
	
	method ibu() {
		return azucar * self.amargor() /2
	}
	
	method amargor() {
		return lupulo.amargor()
	}
}

class LoteClasica inherits LoteCerveza{
	const levadura
	
	override method costoElaboracion() {
		return levadura.costo(self)
	}
	
	override method descuento() {
		return 0.05
	}
}

class LoteLager inherits LoteCerveza {
	const aditivos
	override method costoElaboracion() {
		return 50 * aditivos
	}
	
	override method descuento() {
		return (0.02 * aditivos).min(0.1)
	}
	
}
class LotePorter inherits LoteCerveza {
	const alcohol
	const limite = 8
	override method costoElaboracion() {
		return if (self.altoContenidoAlcoholico()) 450 else 150  
	}
	
	method altoContenidoAlcoholico() {
		return alcohol > limite
	}
	
	override method descuento() {
		return 0
	}
	
	override method ibu() {
		return super() * self.coeficienteIbu()
	}
	
	method coeficienteIbu() {
		return if (self.altoContenidoAlcoholico()) {
			1 + (alcohol - limite)/100
		}
		else {
			0.97
		}
	}
}

object levaduraFermentacionBaja {
	method costo(cerveza) {
		return 300 
	}
}

object levaduraFermentacionAlta {
	method costo(cerveza) {
		return cerveza.costoLupulo() * 0.1
	}
}

object lupuloLocal {
	
	method costo() {
		return 800
	}
	method amargor() {
		return 1.6
	}
}

object lupuloImportado {
	const base = 1000
	method costo() {
		return base + impuesto.valor(base) 
	}
	method amargor() {
		return 2.4
	}
}

object impuesto {
	var property porcentaje = 0.2
	method valor(base) {
		return base * porcentaje
	}
}

class Pedido {
	const property cantidad
	const property cerveza
	const property distancia
	
	method precio(distribuidor) {
		return self.precioBase() + self.comision(distribuidor) - self.descuentos(distribuidor)
	}
	
	method precioBase() {
		return cantidad * cerveza.costo()
	}
	
	method comision(distribuidor) {
		return distribuidor.comision(self)
	}
	
	method descuentos(distribuidor) {
		if(distribuidor.aplicarDescuento(self)) {
			return self.precioBase() * cerveza.descuento()
		} 
		return 0
	}
	method dificil() {
		return cantidad >10  or not self.cerca()
	}
	method cerca() {
		return distancia <= 1
	}
	
	method cumpleLey() {
		return cerveza.ibu()<=ley.ibuMaximo()
	}
}

class PedidoCompuesto {
	const pedidos = #{}
	
	method precio(distribuidor) {
		return pedidos.sum({pedido=>pedido.precio(distribuidor)})
	}
	
	method cantidad() {
		return pedidos.sum({pedido=>pedido.cantidad()})
	}
	
	method distancia() {
		return pedidos.max({pedido=>pedido.distancia()}).distancia()
	}

	method cumpleLey() {
		return pedidos.all({pedido => pedido.cumpleLey()})
	}
	
}
object ley {
	var property ibuMaximo
}

class Distribuidor {
	const comision
	const promocion
	var property pedidos = #{}
	var property cobrado = 0
	
	method comision(pedido) {
		return pedido.precioBase() * comision
	}
	
	method aplicarDescuento(pedido) {
		return promocion.debeAplicar(pedido)
	}
	
	method concretarPedidos() {
		pedidos.forEach({pedido => self.concretar(pedido)})	
	}
	
	method concretar(pedido) {
		cobrado += self.comision(pedido)
		pedidos.remove(pedido)
	}
	
	method dificiles() {
		return pedidos.filter({pedido=>pedido.dificil()})
	}
	
	method lotesAEncargar() {
		return pedidos.map({pedido => pedido.cerveza()}).asSet()
	}
	
	method validarTomar(pedido) {
		if ( not pedido.cumpleLey()) {
			self.error("no cumple la ley")
		}
	}
	method tomar(pedido) {
		self.validarTomar(pedido)
		pedidos.add(pedido)
	}
	
}

object promocionCercania {
	method debeAplicar(pedido) {
		return pedido.cerca() 
	}
}

class PromocionCantidad {
	const minimo
	method debeAplicar(pedido) {
		return pedido.cantidad() >= minimo
	}
}


