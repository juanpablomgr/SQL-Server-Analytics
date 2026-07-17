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

------------------------------------------------------------------
-- Limpieza de Datos ---------------------------------------------
------------------------------------------------------------------

------------------------------
-- Valores Nulos o Faltantes
------------------------------

-- Verificacion de valores faltantes en la tabla Dim_Customer

SELECT COUNT(1) as ValoresFaltantesCustomer
FROM Dim_Customer
WHERE Customer_Name is NULL;

-- Verificación de valores faltantes en la tabla Dim_Product

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
    OR Customer_Name IS NULL
    OR Product_Name IS NULL
    OR City IS NULL
    OR Quantity IS NULL
    OR Unit_Price IS NULL
    OR Revenue IS NULL
    OR Profit IS NULL;

------------------------
-- Valores Duplicados
------------------------
-- Verificacion de valores duplicados en la tabla Fact_Sales

SELECT Order_ID, COUNT(1) as ValoresDuplicados
FROM Fact_Sales
GROUP BY Order_ID
HAVING COUNT(1) > 1;


-------------------------------------
-- Verificacion de Inconsistencias
-------------------------------------

-- Verificacion de Formulas en Campos Calculados de Revenue

SELECT COUNT(1) AS CalculoIncorrecto
FROM sales
WHERE ROUND(Unit_Price * Quantity, 2) <> Revenue;

-- Verificacion de inconsistencia (se debe cumplir Profit < Revenue)

SELECT COUNT(1) AS Inconsistencia_Profit_Revenue
FROM sales
WHERE Profit > Revenue;


--------------------------------------------------------------------
-- PREGUNTAS DE NEGOCIO ---------------------------------------------
--------------------------------------------------------------------

--- Pregunta 1: Ingreso y Margen Total por Categoria de Producto
-- ¿Cual es el ingreso total y la ganancia total generados por cada categoría de producto, y que porcentaje de margen representa cada una?
SELECT 
	p.Category,
	FORMAT(SUM(f.Revenue), 'N2') AS  IngresoTotal,  -- Formato de Separación
	FORMAT(SUM(f.Profit), 'N2') AS MargenTotal,		-- Formato de Separación
	CAST(	
		(SUM(f.Profit) * 100.0)/ SUM(f.Revenue) AS DECIMAL(10,2) 
		) AS [PctMargen (%)]
FROM Fact_Sales AS f
INNER JOIN Dim_Product AS p ON p.Product_ID  = f.Product_ID
GROUP BY p.Category
ORDER BY 
	[PctMargen (%)] DESC;

--- Pregunta 2: Mejores Productos del Catalogo por Margen
-- ¿Cuales son los productos que generan mayor ingreso para la empresa?

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
ORDER BY SUM(f.Revenue) DESC --- Ordenamos por 'SUM(f.Revenue)' para incluir los valores numéricos en el ordenamiento
							 --- y no los textuales puesto que se utilizó 'FORMAT'

--- Pregunta 3: Ventas Totales Por Region
-- ¿Como se comparan las ventas totales, la ganancia y la cantidad de de órdenes entre las 4 regiones donde opera el negocio?

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
-- ¿Como se puede clasificar a cada producto según su nivel de rentabilidad (alta, media o baja) para priorizar decisiones comerciales?

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

-- Pregunta 5: Evolución Mensual de Ingresos
-- ¿Como ha evolucionado el ingreso mes a mes durante 2023 y 2024? ¿Existe algun patron de estacionalidad?

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

-- Pregunta 6: Estados que concentran el 80% del ingreso total (análisis Pareto)

-- ¿Qué estados concentran el 80% del ingreso total de la empresa? ¿Vale la pena distribuir el esfuerzo comercial por igual entre los 47 estados?


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
¿Qué proporción de clientes ha realizado más de una compra, frente a los que solo compraron una vez?

¿Cuál es la tasa de crecimiento mes a mes del ingreso por categoría de producto, y qué categorías muestran una tendencia sostenida de crecimiento o caída?
¿Cuáles son los productos más y menos rentables dentro de cada categoría, ordenados por ranking interno?
¿Existen productos con una caída sostenida de ventas durante 2 o más meses consecutivos que ameriten una alerta temprana?
¿Cómo se segmentan los clientes según su valor de compra acumulado (en cuartiles), y qué porcentaje del ingreso total aporta el cuartil superior?
¿Cuál es la contribución acumulada de cada región al margen de ganancia total de la empresa?
¿Qué combinaciones de categoría y región presentan el mejor y el peor desempeño conjunto de ingreso y margen?
¿Existen productos con un precio unitario anormalmente alto o bajo respecto al promedio de su subcategoría, que ameriten revisión de pricing? */
