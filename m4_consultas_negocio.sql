USE Ventas_Tech_DB;

--Consulta general sobre la tabla a utilizar
SELECT * FROM ventas;

--CONSULTA 1 - Resumen ejecutivo mensual

--Total mensual facturado por mes: primero se genera la agrupacion por mes, y luego se suma la cantidad de productos por su precio unitario para luego obtener el total
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_mensual_facturado
FROM ventas
GROUP BY MONTH(fecha_venta);

--Cantidad de pedidos por mes
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad) AS total_cantidad_pedidos
FROM ventas
GROUP BY MONTH(fecha_venta);

--Ticket promedio por mes
SELECT 
    MONTH(fecha_venta) AS mes,
    COUNT(DISTINCT id_venta) AS total_tickets,
    SUM(cantidad * precio_unitario) / COUNT(DISTINCT id_venta) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);

--CONSULTA 2 - Ranking de productos (Top 5 de id_producto por total facturado)

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
--El orden es para que la primera fila sea la que tiene el total mayor
ORDER BY total_generado DESC;

--CONSULTA 3 - Clientes recurrentes
SELECT 
    id_cliente,
    COUNT(id_venta) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(id_venta) > 1
ORDER BY total_gastado DESC;

--CONSULTA 4 -  Meses por encima/por debajo del promedio

--Creo una tabla temporal con WITH para poder generar el calculo de promedios de manera más optima, siempre teniendo en cuenta la distincion mensual
WITH ventas_mensuales AS (
    SELECT 
        MONTH(fecha_venta)AS mes,
        SUM(cantidad * precio_unitario) AS total_mensual_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    mes,
    total_mensual_facturado,
    --Se ejectuan las condiciones del promedio mensual facturado
    CASE 
        WHEN total_mensual_facturado > (SELECT AVG(total_mensual_facturado) FROM ventas_mensuales) THEN 'Por encima'
        WHEN total_mensual_facturado < (SELECT AVG(total_mensual_facturado) FROM ventas_mensuales) THEN 'Por debajo'
        ELSE 'En el promedio'
    END AS comparacion_promedio
FROM ventas_mensuales
ORDER BY mes;


--BLOQUE DE CIERRE
--El producto con ID 2 concentra el 44.8% de los productos comprados en el mes de marzo
--Con respecto al monto total mensual, el producto estrella es el que lleva el ID 1, ya que contempla más del 50% del total mensual (55.8%)
--En general los clientes este mes realizaron la misma cantidad de pedidos (2), pero el cliente con ID 1 contempla un 41% de ganancia total en marzo.
