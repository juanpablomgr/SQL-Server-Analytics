-- =============================
-- 2. Limpieza de Datos
-- =============================

-- =============================
-- Valores Nulos o Faltantes
-- =============================

-- Verificacion de valores faltantes en la tabla Dim_Customer

SELECT COUNT(1) as ValoresFaltantesCustomer
FROM Dim_Customer
WHERE Customer_Name is NULL;

-- Verificacion de valores faltantes en la tabla Dim_Product

SELECT COUNT(1) as ValoresFaltantesProduct
FROM Dim_Product
WHERE Product_Name is NULL
		or Category is NULL
		or Sub_Category is NULL;

-- Verificacion de valores faltantes en la tabla Dim_Geography

SELECT COUNT(1) as ValoresFaltantesGeo
FROM Dim_Geography
WHERE City is NULL 
		or State IS NULL
		or Region IS NULL
		or Country IS NULL;

-- Verificacion de valores faltantes en la tabla Fact_Sales

SELECT COUNT(1) as ValoresFaltantesFact
FROM Fact_Sales
WHERE  Order_ID IS NULL
	OR Order_Date IS NULL
    OR Quantity IS NULL
    OR Unit_Price IS NULL
    OR Revenue IS NULL
    OR Profit IS NULL;

-- =============================
-- Valores Duplicados
-- =============================

-- Verificacion de valores duplicados en la tabla Fact_Sales

SELECT COUNT(*) AS ValoresDuplicados
FROM (
    SELECT Order_ID
    FROM Fact_Sales
    GROUP BY Order_ID
    HAVING COUNT(1) > 1
) AS Duplicados;

-- ================================
-- Verificacion de Inconsistencias
-- ===============================

-- Verificacion de Formulas en Campos Calculados de Revenue

SELECT COUNT(1) AS CalculoIncorrecto
FROM sales
WHERE ROUND(Unit_Price * Quantity, 2) <> Revenue;

-- Verificacion de inconsistencia (se debe verificar que Profit no exceda a Revenue)

SELECT COUNT(1) AS Inconsistencia_Profit_Revenue
FROM sales
WHERE Profit > Revenue;


-- ==========================================
-- Analisis Exploratorio de Datos e Insights
-- =========================================

--- 1. Ingreso y Margen Total por Categoria de Producto
-- ¿Cual es el ingreso total y la ganancia total generados por cada categoría de producto, y que porcentaje de margen representa cada una?

SELECT 
	p.Category,
	FORMAT(SUM(f.Revenue), 'N2') AS  IngresoTotal,  -- Formato de Separacion
	FORMAT(SUM(f.Profit), 'N2') AS MargenTotal,		-- Formato de Separacion
	CAST(	
		(SUM(f.Profit) * 100.0)/ SUM(f.Revenue) AS DECIMAL(10,2) 
		) AS [PctMargen (%)]
FROM Fact_Sales AS f
INNER JOIN Dim_Product AS p ON p.Product_ID  = f.Product_ID
GROUP BY p.Category
ORDER BY 
	[PctMargen (%)] DESC;

--- Pregunta 2: Mejores Productos del Catalogo por Margen
-- ¿Cuales son los productos que generan mayor margen para la empresa?

SELECT TOP 10
	p.Product_Name,
	FORMAT(SUM(f.Revenue), 'N2') AS  IngresoTotal,
	FORMAT(SUM(f.Profit), 'N2') AS MargenTotal,
	CAST(	
		(SUM(f.Profit) * 100.0)/ SUM(f.Revenue) AS DECIMAL(10,2) 
		) AS [PctMargen (%)]
FROM Fact_Sales AS f
JOIN Dim_Product as p ON p.Product_ID = f.Product_ID
GROUP BY p.Product_Name
ORDER BY SUM(f.Revenue) DESC --- Ordenamos por 'SUM(f.Revenue)' para incluir los valores num�ricos en el ordenamiento
							 --- y no los textuales puesto que se utilizo 'FORMAT'

--- Pregunta 3: Ventas Totales Por Region
-- ¿Como se comparan las ventas totales, la ganancia y la cantidad de de ordenes entre las 4 regiones donde opera el negocio?

SELECT 
	g.Region,
	FORMAT(SUM(f.Revenue), 'N2') AS  IngresoTotal,
	FORMAT(SUM(f.Profit), 'N2') AS MargenTotal,
	CAST(	
		(SUM(f.Profit) * 100.0)/ SUM(f.Revenue) AS DECIMAL(10,2) 
		) AS [PctMargen (%)],
	COUNT(DISTINCT f.Order_ID) AS CntOrdenes
FROM Fact_Sales AS f
INNER JOIN Dim_Geography AS g ON g.Geo_ID = f.Geo_ID
GROUP BY g.Region
ORDER BY SUM(f.Revenue) DESC

-- Pregunta 4: Rentabilidad de los productos
-- ¿Como se puede clasificar a cada producto seg�n su nivel de rentabilidad (alta, media o baja) para priorizar decisiones comerciales?

SELECT 
	p.Product_Name,
	FORMAT(SUM(f.Revenue), 'N2') AS  IngresoTotal,
	FORMAT(SUM(f.Profit), 'N2') AS MargenTotal,
	CAST(	
		(SUM(f.Profit) * 100.0)/ SUM(f.Revenue) AS DECIMAL(10,2) 
		) AS [PctMargen (%)],
	CASE 
		WHEN (SUM(f.Profit) * 100.0)/ SUM(f.Revenue) >= 33 THEN 'Alto'
		WHEN (SUM(f.Profit) * 100.0)/ SUM(f.Revenue) >= 17 THEN 'Medio'
		ELSE 'Bajo'
	END AS ClasificacionRentabilidad
FROM Fact_Sales  AS f
INNER JOIN Dim_Product AS p ON p.Product_ID = f.Product_ID
GROUP BY p.Product_Name
ORDER BY [PctMargen (%)] DESC, SUM(f.Profit) DESC, SUM(f.Revenue) DESC

-- Pregunta 5: Evolucion Mensual de Ingresos
-- ¿Como ha evolucionado el ingreso mes a mes durante 2023 y 2024? ¿Existe algun patron de estacionalidad?

WITH VentasMensuales as(
	SELECT 
		YEAR(f.Order_Date) AS Anio,
		MONTH(f.Order_Date) AS NumMes,
		DATENAME(MONTH, f.Order_Date) AS Mes,
		SUM(f.Revenue) AS IngresoTotal,
		SUM(f.Profit) AS MargenTotal,
		COUNT(DISTINCT Order_ID) as TotalOrdenes
	FROM Fact_Sales AS f
	GROUP BY YEAR(f.Order_Date), MONTH(f.Order_Date), DATENAME(MONTH, f.Order_Date)
)
SELECT 
	Anio,
	NumMes,
	Mes,
	FORMAT(IngresoTotal, 'N2') as IngresoTotalMes,
	FORMAT(MargenTotal, 'N2') as MargenTotalMes,
	TotalOrdenes,
	FORMAT( LAG(IngresoTotal, 1) OVER(ORDER BY Anio, NumMes) , 'N2') AS IngresoMesAnterior,
	CAST(
		(IngresoTotal -	LAG(IngresoTotal, 1) OVER(ORDER BY Anio, NumMes) ) * 100.0 /
		LAG(IngresoTotal, 1) OVER(ORDER BY Anio, NumMes) 
		AS DECIMAL(10,2)) AS [CrecimientoIngresoMesAnterior(%)]
FROM VentasMensuales
ORDER BY Anio ASC, NumMes ASC

-- Pregunta 6: Concentración de Ingresos por Estado (Análisis Pareto)

-- ¿Que estados concentran el 80% del ingreso total de la empresa? ¿Vale la pena distribuir el esfuerzo comercial por igual entre los 47 estados?


WITH IngresoPorEstado AS (
	SELECT
		g.State as Estado,
		SUM(f.Revenue) as IngresoEstado
	FROM Fact_Sales as f
	INNER JOIN Dim_Geography as g on f.Geo_ID = g.Geo_ID
	GROUP BY g.State
),
IngresoAcumulado AS (
	SELECT 
		Estado,
		IngresoEstado,
		SUM(IngresoEstado) OVER (ORDER BY IngresoEstado DESC) as IngresoAcumulado,
		SUM(IngresoEstado) OVER() AS IngresoTotalGral
	FROM IngresoPorEstado
)
SELECT
	Estado,
	FORMAT ( IngresoEstado, 'N2') AS IngresoEstado_,
	CAST( ( IngresoEstado * 100.0 ) / ( IngresoTotalGral) AS DECIMAL(10,2) ) as PctIndividual,
	FORMAT ( IngresoAcumulado, 'N2' ) AS IngresoAcumulado_,
	CAST ( ( IngresoAcumulado * 100.0 ) / ( IngresoTotalGral) AS DECIMAL(10,2) ) as PctAcumulado,
	FORMAT ( IngresoTotalGral, 'N2' ) AS IngresoTotalGral_
FROM IngresoAcumulado
ORDER BY IngresoEstado DESC;

-- Pregunta 7: Fidelidad de Clientes
-- ¿Que proporcion de clientes ha realizado mas de una compra, frente a los que solo compraron una vez?

WITH Clasificacion_Cliente as (
	SELECT
		c.Customer_Name,
		COUNT(DISTINCT f.Order_ID) AS Total_Compras,
		CASE 
			WHEN COUNT(DISTINCT f.Order_ID) > 1 Then 'Recurrente'
			ELSE 'Unico'
		END AS Tipo_Cliente
	FROM Fact_Sales as f
	INNER JOIN Dim_Customer as c ON c.Customer_ID = f.Customer_ID
	GROUP BY c.Customer_Name
)
SELECT 
	Tipo_Cliente,
	COUNT(1) AS CantidadClientes,
	SUM(COUNT(1)) OVER() AS TotalClientes, 
	CAST(
		COUNT(1) * 100.0 / 
		SUM(COUNT(1)) OVER() 
		AS decimal(10,2) ) AS PctClientes
FROM Clasificacion_Cliente
GROUP BY Tipo_Cliente
ORDER BY CantidadClientes DESC;

-- Pregunta 8: Tasa de Crecimiento Mensual por Categoría
-- ¿Cuál es la tasa de crecimiento mes a mes del ingreso por categoría de producto, y qué categorías muestran una tendencia sostenida?

WITH VentasMensualesCategoria as(
	SELECT 
		p.Category,
		YEAR(f.Order_Date) AS Anio,
		MONTH(f.Order_Date) AS NumMes,
		DATENAME(MONTH, f.Order_Date) AS Mes,
		SUM(f.Revenue) AS IngresoTotal
	FROM Fact_Sales AS f
	INNER JOIN Dim_Product as p on p.Product_ID = f.Product_ID
	GROUP BY p.Category, YEAR(f.Order_Date), MONTH(f.Order_Date), DATENAME(MONTH, f.Order_Date)
),
CrecimientoMensual as (
SELECT 
	Category, 
	Anio,
	NumMes,
	Mes,
	FORMAT(IngresoTotal, 'N2') as IngresoTotalMes,
	FORMAT( LAG(IngresoTotal, 1) OVER(PARTITION BY Category ORDER BY Anio, NumMes) , 'N2') AS IngresoMesAnterior,
	CAST(
		(IngresoTotal -	LAG(IngresoTotal, 1) OVER(PARTITION BY Category ORDER BY Anio, NumMes) ) * 100.0 
		/ LAG(IngresoTotal, 1) OVER(PARTITION BY Category  ORDER BY Anio, NumMes) 
		AS DECIMAL(10,2)) AS Pct_Crecim_Mes_Anterior
FROM VentasMensualesCategoria
)
SELECT
	Category,
	ROUND( AVG(Pct_Crecim_Mes_Anterior), 2) AS CrecimientoPromMensual,
	SUM(CASE
			WHEN Pct_Crecim_Mes_Anterior > 0 THEN 1 
			ELSE 0
		END) AS CntMesEnCrecimiento,
	SUM(CASE
			WHEN Pct_Crecim_Mes_Anterior < 0 THEN 1 
			ELSE 0
		END) AS CntMesEnCaida
FROM CrecimientoMensual
WHERE Pct_Crecim_Mes_Anterior is NOT NULL
GROUP BY Category
ORDER BY CrecimientoPromMensual DESC

-- Pregunta 9: Matriz de Desempeño Categoría-Región
-- ¿Qué combinaciones de categoría y región presentan el mejor y el peor desempeño conjunto de ingreso y margen?

SELECT
	p.Category,
	g.Region,
	FORMAT(SUM(f.Revenue), 'N2') as IngresoTotal,
	FORMAT(SUM(f.Profit), 'N2') as MargenTotal, 
	CAST( SUM(f.Profit) * 100.0 /sum(f.Revenue) AS DECIMAL(10,2) ) AS PctMargen,
	RANK() OVER(ORDER BY SUM(f.Profit) * 100.0 /sum(f.Revenue) DESC ) AS RankingMargen
FROM Fact_Sales as f
INNER JOIN Dim_Product AS p on p.Product_ID = f.Product_ID
INNER JOIN Dim_Geography AS g on g.Geo_ID = f.Geo_ID
GROUP BY p.Category, g.Region
