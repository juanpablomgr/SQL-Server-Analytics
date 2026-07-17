CREATE DATABASE CorwellAnalytics;

USE CorwellAnalytics;

-- Creacion de la tabla "sales" para insertar la data cruda
IF OBJECT_ID ('sales','U') IS NOT NULL
	DROP TABLE sales;

CREATE TABLE sales (
	Order_ID		INT,
	Order_Date		VARCHAR(10),
	Customer_Name	VARCHAR(100),
	City			VARCHAR(100),
	State			VARCHAR(50),
	Region			VARCHAR(20),
	Country			VARCHAR(50),
	Category		VARCHAR(50),
	Sub_Category	VARCHAR(50),
	Product_Name	VARCHAR(100),
	Quantity		INT, 
	Unit_Price		DECIMAL(10,2), 
	Revenue			DECIMAL(12,2), 
	Profit			DECIMAL(12,2)
)
;



-- Inserción de la data

BULK INSERT sales
FROM 'C:\Users\Usuario\Downloads\Product Sales Dataset (2023-2024)\product_sales_dataset_final.csv' -- Reemplaza con la ruta real
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,           -- Ignora el encabezado del CSV
    FIELDTERMINATOR = ',',  -- Cambia por ';' si tu CSV usa punto y coma
    ROWTERMINATOR = '\n' -- Salto de l?nea est?ndar (LF) o '\n'
   -- ENCODING = 'UTF-8'      -- Importante si tienes acentos o tildes
 
);

SELECT COUNT(1) AS cnt_de_registros
FROM sales

---------------------------------
-- NORMALIZACIOPN DE LA DATA
---------------------------------

DROP TABLE IF EXISTS Fact_Sales;
DROP TABLE IF EXISTS Dim_Customer;
DROP TABLE IF EXISTS Dim_Product;
DROP TABLE IF EXISTS Dim_Geography;
GO

--- Tabla Dimensional de Clientes (Dim_Customer)

CREATE TABLE Dim_Customer (
	Customer_ID		INT IDENTITY(101,1) NOT NULL,
	Customer_Name	VARCHAR(100) NOT NULL,
	CONSTRAINT PK_Dim_Customer PRIMARY KEY (Customer_ID) );

INSERT INTO Dim_Customer (Customer_Name)
	SELECT 
		DISTINCT Customer_Name
	FROM sales
;

select * from Dim_Customer;

--- Tabla Dimensional de Productos (Dim_Productos)


CREATE TABLE Dim_Product (
	Product_ID		INT IDENTITY(1,1) NOT NULL,
	Product_Name	VARCHAR(100) NOT NULL,
	Sub_Category	VARCHAR(50),
	Category		VARCHAR(50),
	CONSTRAINT PK_Dim_Product PRIMARY KEY (Product_ID) ) ;

INSERT INTO Dim_Product (Product_Name, Sub_Category, Category)
	SELECT 
		DISTINCT Product_Name,
		Sub_Category,
		Category
	FROM sales
	ORDER BY Category ASC, Sub_Category ASC, Product_Name ASC;

--- Tabla Dimensional de Geography (Dim_Geography)

CREATE TABLE Dim_Geography (
	Geo_ID			INT IDENTITY(1,1) NOT NULL,
	City			VARCHAR(100),
	State			VARCHAR(50),
	Region			VARCHAR(20),
	Country			VARCHAR(50),
	CONSTRAINT PK_Dim_Geography PRIMARY KEY (Geo_ID) ) ;

INSERT INTO Dim_Geography (City, State, Region, Country)
	SELECT
		DISTINCT City,
		State,
		Region,
		Country
	FROM sales 
	ORDER BY Region ASC, State ASC, City ASC

--- Tabla De Hechos de Ventas (Fact_Sales)

CREATE TABLE Fact_Sales (
	Order_ID		INT NOT NULL,
	Customer_ID		INT NOT NULL,
	Product_ID		INT NOT NULL,
	Geo_ID			INT NOT NULL,
	Order_Date		DATE NOT NULL,
	Quantity		INT,
	Unit_Price		DECIMAL(10,2),
	Revenue			DECIMAL(10,2),
	Profit			DECIMAL(10,2),
	CONSTRAINT PK_Fact_Sales PRIMARY KEY (Order_ID),
	CONSTRAINT FK_Fact_Customer FOREIGN KEY (Customer_ID)
		REFERENCES Dim_Customer(Customer_ID),
	CONSTRAINT FK_Fact_Product FOREIGN KEY (Product_ID)
		REFERENCES Dim_Product(Product_ID),
	CONSTRAINT FK_Fact_Geo FOREIGN KEY (Geo_ID)
		REFERENCES Dim_Geography(Geo_ID),
	CONSTRAINT CHK_Quantity CHECK(Quantity > 0),
	CONSTRAINT CHK_Unit_Price CHECK(Unit_Price >= 0),
	CONSTRAINT CHK_Revenue CHECK(Revenue >= 0)
);

INSERT INTO Fact_Sales(Order_ID, Customer_ID, Product_ID, Geo_ID, Order_Date, Quantity, Unit_Price, Revenue, Profit)
SELECT
		s.Order_ID,
		c.Customer_ID,
		p.Product_ID,
		g.Geo_ID,
		FORMAT(CAST(s.Order_Date as date), 'yyyy-MM-dd') AS Order_Date,
		s.Quantity,
		s.Unit_Price,
		s.Revenue,
		s.Profit
FROM sales s
JOIN Dim_Customer c ON c.Customer_Name = s.Customer_Name
JOIN Dim_Product p ON p.Product_Name = s.Product_Name
					AND p.Sub_Category = s.Sub_Category
					AND p.Category = s.Category
JOIN Dim_Geography g ON g.City = s.City
					AND g.State = s.State
					AND g.Region = s.Region
					AND g.Country = s.Country;

select COUNT(1) from Fact_Sales

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

