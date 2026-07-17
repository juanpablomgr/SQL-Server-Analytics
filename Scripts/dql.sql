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

-- Verificación de valores faltantes en la tabla Dim_Customer

SELECT COUNT(1) as ValoresFaltantesCustomer
FROM Dim_Customer
WHERE Customer_Name is NULL;

-- Verificación de valores faltantes en la tabla Dim_Product

SELECT COUNT(1) as ValoresFaltantesProduct
FROM Dim_Product
WHERE Product_Name is NULL
		or Category is NULL
		or Sub_Category is NULL;

-- Verificación de valores faltantes en la tabla Dim_Geography

SELECT COUNT(1) as ValoresFaltantesGeo
FROM Dim_Geography
WHERE City is NULL 
		or State IS NULL
		or Region IS NULL
		or Country IS NULL;

-- Verificación de valores faltantes en la tabla Fact_Sales

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
-- Verificación de valores duplicados en la tabla Fact_Sales

SELECT Order_ID, COUNT(1) as ValoresDuplicados
FROM Fact_Sales
GROUP BY Order_ID
HAVING COUNT(1) > 1;


-------------------------------------
-- Verificación de Inconsistencias
-------------------------------------

-- Verificación de Formulas en Campos Calculados de Revenue

SELECT COUNT(1) AS CalculoIncorrecto
FROM sales
WHERE ROUND(Unit_Price * Quantity, 2) <> Revenue;

-- Verificación de inconsistencia (se debe cumplir Profit < Revenue)

SELECT COUNT(1) AS Inconsistencia_Profit_Revenue
FROM sales
WHERE Profit > Revenue;


--------------------------------------------------------------------
-- PREGUNTAS DE NEGOCIO ---------------------------------------------
--------------------------------------------------------------------

--- Revenue y Profit por Categoría de Producto
-- ¿ Qué categorías de producto son las que generan más ingresos y ganancia ?

SELECT 
	p.Category,
	p.Sub_Category,
	sum(s.Revenue) as RevenueTotal,
	sum(s.Profit) as ProfitTotal
FROM Fact_Sales as s
JOIN Dim_Product as p on p.Product_ID  = s.Product_ID
group by p.Category, p.Sub_Category
ORDER BY 
	sum(s.Revenue) DESC,
	sum(s.Profit) DESC

