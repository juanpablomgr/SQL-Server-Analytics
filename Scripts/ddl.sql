CREATE DATABASE VelmoraAnalytics;

USE VelmoraAnalytics;

-- Creaci�n de la tabla "sales" para insertar la data

CREATE TABLE sales (
Category,
City,
Country,
Customer_ID,
Customer_Name,
Discount,
Market,ji_lu-shu,Order Date,Order ID,Order Priority,Product ID,Product Name,Profit,Quantity,Region,Row ID,Sales,Segment,Ship Date,Ship Mode,Shipping Cost,State,Sub-Category,Year,Market2,weeknum


-- Inserción de la data

BULK INSERT sales
FROM 'D:\ArchivosJP\DataAcademy\Proyectos Data\ProyectoSQLServerAnalytics\SQL-Server-Analytics\Data\global_ecommerce_sales.csv' -- Reemplaza con la ruta real
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,           -- Ignora el encabezado del CSV
    FIELDTERMINATOR = ',',  -- Cambia por ';' si tu CSV usa punto y coma
    ROWTERMINATOR = '\n' -- Salto de l?nea est?ndar (LF) o '\n'
   -- ENCODING = 'UTF-8'      -- Importante si tienes acentos o tildes
 
);

SELECT *
FROM sales
IF OBJECT_ID('Employee', 'U') IS NOT NULL
    DROP TABLE PerformanceRating;



---------------------------------
-- 1. NORMALIZACI�N DE LA DATA
---------------------------------
