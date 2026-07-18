SELECT TOP 7 *
FROM sales


SELECT COUNT(1) from Fact_Sales

SELECT COUNT(*) FROM Fact_Sales f
LEFT JOIN Dim_Customer c ON f.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

SELECT COUNT(*) FROM Fact_Sales f
LEFT JOIN Dim_Product p ON f.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;

SELECT COUNT(*) FROM Fact_Sales f
LEFT JOIN Dim_Geography g ON f.Geo_ID = g.Geo_ID
WHERE g.Geo_ID IS NULL;

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

-- Verificaci�n de valores faltantes en la tabla Dim_Product

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
-- An�lisis Exploratorio de Datos e Insights
-- =========================================

--- 1. Ingreso y Margen Total por Categoria de Producto
-- �Cual es el ingreso total y la ganancia total generados por cada categor�a de producto, y que porcentaje de margen representa cada una?

SELECT 
	p.Category,
	FORMAT(SUM(f.Revenue), 'N2') AS  IngresoTotal,  -- Formato de Separaci�n
	FORMAT(SUM(f.Profit), 'N2') AS MargenTotal,		-- Formato de Separaci�n
	CAST(	
		(SUM(f.Profit) * 100.0)/ SUM(f.Revenue) AS DECIMAL(10,2) 
		) AS [PctMargen (%)]
FROM Fact_Sales AS f
INNER JOIN Dim_Product AS p ON p.Product_ID  = f.Product_ID
GROUP BY p.Category
ORDER BY 
	[PctMargen (%)] DESC;

--- Pregunta 2: Mejores Productos del Catalogo por Margen
-- �Cuales son los productos que generan mayor margen para la empresa?

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
							 --- y no los textuales puesto que se utiliz� 'FORMAT'

--- Pregunta 3: Ventas Totales Por Region
-- �Como se comparan las ventas totales, la ganancia y la cantidad de de �rdenes entre las 4 regiones donde opera el negocio?

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
-- �Como se puede clasificar a cada producto seg�n su nivel de rentabilidad (alta, media o baja) para priorizar decisiones comerciales?

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

-- Pregunta 5: Evoluci�n Mensual de Ingresos
-- �Como ha evolucionado el ingreso mes a mes durante 2023 y 2024? �Existe algun patron de estacionalidad?

SELECT 
    YEAR(f.Order_Date) AS Anio,
    MONTH(f.Order_Date) AS NumMes,
    DATENAME(MONTH, f.Order_Date) AS Mes,
    FORMAT(SUM(f.Revenue), 'N2') AS IngresoTotal,
    FORMAT(SUM(f.Profit), 'N2') AS MargenTotal,
    COUNT(DISTINCT f.Order_ID) AS TotalOrdenes
FROM Fact_Sales AS f
GROUP BY YEAR(f.Order_Date), MONTH(f.Order_Date), DATENAME(MONTH, f.Order_Date)
ORDER BY Anio ASC, NumMes ASC;

-- Pregunta 6: Estados que concentran el 80% del ingreso total (an�lisis Pareto)

-- �Qu� estados concentran el 80% del ingreso total de la empresa? �Vale la pena distribuir el esfuerzo comercial por igual entre los 47 estados?


WITH IngresoPorEstado AS (
    SELECT 
        g.State,
        SUM(f.Revenue) AS IngresoEstado
    FROM Fact_Sales AS f
    JOIN Dim_Geography AS g ON g.Geo_ID = f.Geo_ID
    GROUP BY g.State
),
Acumulado AS (
    SELECT 
        State,
        IngresoEstado,
        SUM(IngresoEstado) OVER (ORDER BY IngresoEstado DESC) AS IngresoAcumulado,
        SUM(IngresoEstado) OVER () AS IngresoTotalGeneral
    FROM IngresoPorEstado
)
SELECT 
    State,
    FORMAT(IngresoEstado, 'N2') AS Ingreso_por_Estado,
    CAST((IngresoEstado * 100.0 / IngresoTotalGeneral) AS DECIMAL(10,2)) AS PctIndividual,
    CAST((IngresoAcumulado * 100.0 / IngresoTotalGeneral) AS DECIMAL(10,2)) AS PctAcumulado
FROM Acumulado
ORDER BY IngresoEstado DESC;




/* 
�Qu� proporci�n de clientes ha realizado m�s de una compra, frente a los que solo compraron una vez?

�Cu�l es la tasa de crecimiento mes a mes del ingreso por categor�a de producto, y qu� categor�as muestran una tendencia sostenida de crecimiento o ca�da?
�Cu�les son los productos m�s y menos rentables dentro de cada categor�a, ordenados por ranking interno?
�Existen productos con una ca�da sostenida de ventas durante 2 o m�s meses consecutivos que ameriten una alerta temprana?
�C�mo se segmentan los clientes seg�n su valor de compra acumulado (en cuartiles), y qu� porcentaje del ingreso total aporta el cuartil superior?
�Cu�l es la contribuci�n acumulada de cada regi�n al margen de ganancia total de la empresa?
�Qu� combinaciones de categor�a y regi�n presentan el mejor y el peor desempe�o conjunto de ingreso y margen?
�Existen productos con un precio unitario anormalmente alto o bajo respecto al promedio de su subcategor�a, que ameriten revisi�n de pricing? */
