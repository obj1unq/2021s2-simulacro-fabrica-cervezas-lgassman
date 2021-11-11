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
	method porcentajeDescuento()
	
	method ibu() {
		return azucar * lupulo.amargor() / 2
	}
}

class LoteCervezaClasica inherits LoteCerveza {
	const levadura
	override method costoElaboracion() {
		return levadura.costo(self)
	}
	override method porcentajeDescuento() {
		return 0.05
	}
}
class LoteCervezaLager inherits LoteCerveza {
	const aditivos
	
	override method costoElaboracion() {
		return 50 * aditivos
	}
	override method porcentajeDescuento() {
		return (0.02 * aditivos).min(0.1)
	}
	
}

class LoteCervezaPorter inherits LoteCerveza {
	const alcohol
	const limiteAlcohol = 8
	override method costoElaboracion() {
		return if (self.altoContenidoAlcoholico()) 450 else 150 
	}
	
	method altoContenidoAlcoholico() {
		return alcohol > limiteAlcohol
	}
	override method porcentajeDescuento() {
		return 0
	}
	
	override method ibu() {
		return super() * self.coeficienteIbu() 
	}
	
	method coeficienteIbu() {
		return if (self.altoContenidoAlcoholico()) {
			1 + (alcohol - limiteAlcohol) / 100	
		}
		else {
			0.97
		}
	}
	
}

object levaduraAlta {
	method costo(cerveza) {
		return cerveza.costoLupulo() * 0.10
	}
}

object levaduraBaja {
	method costo(cerveza) {
		return 300
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
	var property impuesto = 1.20
	method costo() {
		return 1000 * impuesto
	}
	method amargor() {
		return 2.4
	}
}

object ley {
	var property ibuMaximoPermitido
}

class PedidoCompuesto {
	const subpedidos = #{}
	method precio(distribuidor) {
		return subpedidos.sum({pedido => pedido.precio(distribuidor)})
		//return subpedidos.map({pedidos=>pedido.precio(distribuidor)}).sum()
	}
	
	method cantidad() {
		return subpedidos.sum({pedido => pedido.cantidad()})
	}
	
	method distancia() {
		return subpedidos.max({pedido => pedido.distancia()}).distancia()
		//return subpedidos.map({pedido => pedido.sitancia()}).max()
	}
	
	method cumpleLey() {
		return subpedidos.all({pedido => pedido.cumpleLey()})
	}
}
class Pedido {
	
	const property distancia
	const property cantidad
	const property lote
	
	
	method precio(distribuidor) {
		return self.precioBase() + distribuidor.comision(self) - self.descuentos(distribuidor)
	}
	
	method precioBase() {
		return cantidad * lote.costo()
	}
	
	method descuentos(distribuidor) {
		if(distribuidor.debeAplicarPromocion(self)) {
			return lote.porcentajeDescuento() * self.precioBase()
		}
		else {
			return 0
		}
	}
	
	method esDificil() {
		return not self.cerca() or cantidad > 10
	}
	
	method cerca() {
		return distancia < 1
	}
	
	method cumpleLey() {
		return lote.ibu() <= ley.ibuMaximoPermitido()
	}
	
}

class Distribuidor {
	const property porcentajeComision
	var property promocion;
	var property cobrado = 0
/*
 *  var cobrado= 0
 *  method cobrado() { return cobrado}
 *  method cobrado(_cobrado) {cobrado = _cobrado}
 * 
 */	
	
	
	const property pedidos = #{}
/*
 *  const pedidos = #{}
 *  method pedidos() { return pedidos }
 * 
 */	
		
	method comision(pedido) {
		return porcentajeComision * pedido.precioBase() 
	}
	
	method debeAplicarPromocion(pedido) {
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
	    return pedidos.filter({pedido => pedido.esDificil()})
	}
	
	method aEncargar() {
		return pedidos.map({pedido => pedido.lote()}).asSet()
	}
	
	method validarTomar(pedido) {
		if(not pedido.cumpleLey()) {
			self.error("No se puede agregar el pedido porque viola la ley")
		}
	}
	method tomar(pedido) {
		self.validarTomar(pedido)
		pedidos.add(pedido)
	}
}

object noPromocion {
	method debeAplicar() {
		return false
	}
}

class PromocionCantidad {
	const cantidadMinima
	method debeAplicar(pedido) {
		return pedido.cantidad() > cantidadMinima
	}
}

object promocionCercania {
	method debeAplicar(pedido) {
		return pedido.cerca()
	}
}



