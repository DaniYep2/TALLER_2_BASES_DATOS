CREATE TABLE IF NOT EXISTS Seller (
  idSeller INT PRIMARY KEY,
  Nombre_Seller VARCHAR(45) NOT NULL,
  calificacion_Seller int NOT NULL,
  ventas_Realizadas VARCHAR(45) NOT NULL,
  fecha_Venta date
  )

CREATE TABLE IF NOT EXISTS Customer (
  idCustomer INT NOT NULL,
  Nombre_Customer VARCHAR(45) NOT NULL,
  PRIMARY KEY (idCustomer))



CREATE TABLE IF NOT EXISTS users (
  idUsuarios INT NOT NULL,
  Nombre_Usuario VARCHAR(45) NOT NULL,
  CargoUsuario VARCHAR(45) NOT NULL,
  Seller_idSeller INT NOT NULL,
  Customer_idCustomer INT NOT NULL,
  PRIMARY KEY (idUsuarios, Seller_idSeller,Customer_idCustomer))


CREATE TABLE IF NOT EXISTS Compradores (
  idCompradores INT NOT NULL,
  nombreComprador VARCHAR(45) NOT NULL,
  tipodePago VARCHAR(45) NOT NULL,
  cantidadProductosComprados VARCHAR(45) NOT NULL,
  telefono VARCHAR(45) NOT NULL,
  correoElectronico VARCHAR(45) NOT NULL,
  direccion VARCHAR(45) NOT NULL,
  ciudad VARCHAR(45) NOT NULL,
  administradoresAplicación_idAdministradorAplicacion INT NOT NULL,
  PRIMARY KEY (idCompradores,administradoresAplicación_idAdministradorAplicacion))


CREATE TABLE IF NOT EXISTS Productos (
  idProductos INT NOT NULL,
  nombreProducto VARCHAR(45) NOT NULL,
  tipoProducto VARCHAR(45) NOT NULL,
  stockProducto VARCHAR(45) NOT NULL,
  valorProducto VARCHAR(45) NOT NULL,
  Compradores_idCompradores INT NOT NULL,
  nombre_Seller VARCHAR(45) NOT NULL
  )


CREATE TABLE IF NOT EXISTS Proveedor (
  idProveedor INT NOT NULL,
  nombreProveedorProducto VARCHAR(45) NOT NULL,
  direccionProveedor VARCHAR(45) NOT NULL,
  ciudadProveedor VARCHAR(45) NOT NULL,
  telefonoProveedor VARCHAR(45) NOT NULL,
  administradoresAplicación_idAdministradorAplicacion INT NOT NULL,
  PRIMARY KEY (idProveedor,administradoresAplicación_idAdministradorAplicacion))


CREATE TABLE IF NOT EXISTS Cart (
  idCart INT NOT NULL,
  Productos_Comprados VARCHAR(45) NOT NULL,
  Valor_compra VARCHAR(45) NOT NULL,
  Customer_idCustomer INT NOT NULL,
  PRIMARY KEY (idCart, Customer_idCustomer)

CREATE TABLE IF NOT EXISTS Variant (
  idVariant INT NOT NULL,
  Especificaciones_variante VARCHAR(45) NOT NULL,
  Productos_idProductos INT NOT NULL,
  Productos_Compradores_idCompradores INT NOT NULL,
  Productos_Seller_idSeller INT NOT NULL,
  PRIMARY KEY (idVariant,Productos_idProductos, Productos_Compradores_idCompradores, Productos_Seller_idSeller))

CREATE TABLE IF NOT EXISTS Method_payment (
  idMethod_payment INT NOT NULL PRIMARY KEY,
  Tipo_de_Pago VARCHAR(45) NOT NULL)
 



CREATE TABLE IF NOT EXISTS Pago (
  idPago INT NOT NULL PRIMARY KEY,
  Tipo_de_pago VARCHAR(45) NOT NULL,
  Method_payment_idMethod_payment INT NOT NULL)


CREATE TABLE IF NOT EXISTS Orden (
  idOrder INT NOT NULL PRIMARY KEY,
  Cantidad_productos VARCHAR(45) NOT NULL,
  Valor_productos VARCHAR(45) NOT NULL,
  Cart_idCart INT NOT NULL,
  Cart_Customer_idCustomer INT NOT NULL,
  Pago_idPago VARCHAR(45) NOT NULL,
  Pago_Method VARCHAR(45) NOT NULL)


CREATE TABLE auditoria_productos(
idSeleccion VARCHAR(45)NULL,
fechaEjecucion timestamp,
usuario VARCHAR (45) NULL,
idProductos int NOT NULL,
nombreProducto_COPIA VARCHAR(45)  NULL,
tipoProducto_COPIA VARCHAR(45)  NULL,
stockProducto_COPIA VARCHAR(45)  NULL,
valorProducto_COPIA VARCHAR(45)  NULL,
Compradores_idCompradores_COPIA INT  NULL,
nombre_Seller_COPIA VARCHAR(45)  NOT NULL)
 

CREATE TABLE IF NOT EXISTS event_type(
  idevent_type INT NOT NULL,
  insert_ VARCHAR(45) NOT NULL,
  update_ VARCHAR(45) NOT NULL,
  delete_ VARCHAR(45) NOT NULL,
  time_event VARCHAR(45) NOT NULL,
  product_audit_idProductos INT NOT NULL,
  product_audit_Variant_idVariant INT NOT NULL,
  product_audit_Variant_Productos_idProductos INT NOT NULL,
  product_audit_Variant_Productos_Compradores_idCompradores INT NOT NULL,
  product_audit_Variant_Productos_Seller_idSeller INT NOT NULL,
  PRIMARY KEY (idevent_type, product_audit_idProductos, product_audit_Variant_idVariant, product_audit_Variant_Productos_idProductos,product_audit_Variant_Productos_Compradores_idCompradores, product_audit_Variant_Productos_Seller_idSeller))

CREATE TABLE IF NOT EXISTS administradoresaplicacion(
  idadministradoresAplicación INT NOT NULL,
  cantidadUsuarios VARCHAR(45) NOT NULL,
  stockAlmacen VARCHAR(45) NOT NULL,
  aprobacionProveedor VARCHAR(45) NOT NULL,
  PRIMARY KEY (idadministradoresAplicación))
	
	

CREATE TABLE IF NOT EXISTS categoriaproducto(
  idcategoriaProducto INT NOT NULL,
  nombreCategoria VARCHAR(45) NOT NULL,
  nombreProveedorProducto VARCHAR(45) NOT NULL,
  Productos_idProductos VARCHAR(45) NULL DEFAULT NULL,
  Productos_Compradores_idCompradores VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (idcategoriaProducto))
	
CREATE TABLE weekly_reputation
	
	
------------------------- 1er punto------------------------------------------------------------
INSERT INTO Productos VALUES (2,'Jabon','Aseo', 130, 2000,1234567,'Juan');
	
CREATE OR REPLACE FUNCTION process_product_audit() RETURNS TRIGGER AS $auditoria_productos$
	BEGIN
	IF(TG_OP ='DELETE')THEN
	INSERT INTO auditoria_productos SELECT 'D',now(),user,OLD.*;
	RETURN OLD;
	ELSIF(TG_OP ='UPDATE')THEN
	INSERT INTO auditoria_productos SELECT 'U',now(),user,NEW.*;
	RETURN NEW;
	ELSIF(TG_OP = 'INSERT')THEN
	INSERT INTO auditoria_productos SELECT 'I',now(),user,NEW.*;
	RETURN NEW;
	END IF;
	RETURN NULL;
	END;
	$auditoria_productos$ LANGUAGE plpgsql;

CREATE trigger product_audit_trigger
	after insert or update or delete on Productos
	for each row
	execute procedure process_product_audit();
	
------------------------2do Punto------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION validarOrden()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS
$$
	BEGIN
	IF(NEW.idOrder = OLD.idOrder) THEN
		RAISE 'La orden ya se encuentra creada';
	END IF;
	
	RETURN NEW;
END;
$$
	
CREATE TRIGGER validacionOrdenCreada
	BEFORE UPDATE
	ON Orden
	FOR EACH ROW
	EXECUTE PROCEDURE validarOrden();
	
---------------------------------------3er Punto------------------------------------------
CREATE OR REPLACE PROCEDURE reputacionVendedor()
language plpgsql 
as $$
BEGIN
IF (select to_char(current_date, 'd') = '1') then
	
DROP TABLE if exists weekly_reputation;
CREATE TABLE weekly_reputation AS SELECT idSeller,Nombre_Seller, 
CASE 
WHEN SUM(calificacion_Seller)<=5 then 'baja'
WHEN SUM(calificacion_Seller)<=10 then 'baja-media'
WHEN SUM(calificacion_Seller)<=15 then 'media'
WHEN SUM(calificacion_Seller)<=20 then 'media-alta'
else 'Alta'
end calificacion

FROM Seller 

WHERE EXTRACT (MONTH FROM fecha_Venta)=EXTRACT(MONTH FROM current_date) 

GROUP BY idSeller,Nombre_Seller;

END IF;
END;	
$$

CALL reputacionVendedor()

SELECT * FROM weekly_reputation
	
	
	
	
	
	
	
	