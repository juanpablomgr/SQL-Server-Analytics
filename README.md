# Proyecto SQL-Server-Commercial-Analytics
Proyecto Integral de SQL Server para Analitica de Negocios
## Resumen (overview)
### Sobre el negocio
Corwell Group es una empresa de distribución y venta retail de multicategoría con operaciones y presencia en Estados Unidos.

El departamento de estrategia comercial de Corwell Group desea identificar en qué productos, categorías y mercados regionales debe enfocar sus esfuerzos de crecimiento y rentabilidad, priorizando decisiones de portafolio sobre una base de datos sólida en lugar de intuición.

### Objetivo del proyecto
_Utilizar el lenguaje **SQL** dentro del entorno de **SQL Server Management Studio**_ para estructurar, normalizar y realizar análisis exploratorio de la información transaccional del negocio con el fin de entregar al área comercial recomendaciones accionables que permitan implementar mejoras practicas en su estrategia comercial, optimizar sus procesos y aumentar la rentabilidad._

### Herramientas y Metodología

- **Motor de Base De Datos**: SQL Server Management Studio (SMSS)
- **Lenguaje**: SQL (DDL, DML, DQL)
- **Metodología**: Limpieza de Datos (Data Cleaning), Análisis Exploratorio de Datos(EDA) y Generación de Insights Accionables.


## Estructura del Proyecto
- [Sobre los Datos](#sobre-los-datos)
- [Tareas](#tareas)
- [Arquitectura y Modelado de Datos](#arquitectura-y-modelado-de-datos)
- [Limpieza de Datos](#limpieza-de-datos)
- [Análisis Exploratorio de Datos e Insights](#análisis-exploratorio-de-datos-e-insights)
- [Conclusiones y Recomendaciones](#conclusiones-y-recomendaciones)

## Sobre los datos

El proyecto utiliza un dataset que está compuesto por una tabla con 200,000 registros distribuidos en 14 columnas, el cual contiene información sobre las transacciones de ventas de una empresa retail como: fecha de transacción, información del cliente, producto, cantidad, precio unitario, ingreso y ganancia.

Se puede acceder al dataset original [aquí](https://www.kaggle.com/datasets/yashyennewar/product-sales-dataset-2023-2024).

![sobre-los-datos](./Picture/sobre_los_datos.png)

A continuación se muestra la estructura de las tablas del dataset:

### Estructura del archivo `sales.csv`

| Columna | Descripción |
|----------|-------------|
| Order_ID | Identificador único de cada pedido. |
| Order_Date | Fecha en la que se realizó la transacción. |
| Customer_Name | Nombre del cliente que realizó la compra. |
| City | Ciudad de residencia del cliente. |
| State | Estado de residencia del cliente. |
| Region | Región geográfica donde se ubica el cliente (Este, Oeste, Sur o Centro). |
| Country | País donde se realizó la venta (Estados Unidos). |
| Category | Categoría principal del producto (por ejemplo, Accesorios, Ropa y Vestimenta). |
| Sub_Category | Subcategoría del producto dentro de la categoría principal (por ejemplo, Ropa deportiva, Bolsos). |
| Product_Name | Nombre o descripción del producto comercializado. |
| Quantity | Cantidad de unidades compradas. |
| Unit_Price | Precio unitario del producto, expresado en dólares estadounidenses (USD). |
| Revenue | Ingresos totales generados por la venta, calculados como **Cantidad × Precio Unitario**. |
| Profit | Ganancia neta obtenida en la transacción. |

## Tareas (Task)

En este proyecto, se ayudará al departamento comercial de Corwell Group a responder lo siguiente:

1. **Ingreso y Margen Total por Cateogoría de Producto:** 
¿Cuál es el ingreso total y la ganancia total generados por cada categoría de producto, y qué porcentaje de margen representa cada una?

2. **Mejores Productos del Catálogo Por Margen:** ¿Cuáles son los 10 productos que generan mayor ingreso para la empresa?

3. **Ventas Totales por Región:** ¿Cómo se comparan las ventas totales, la ganancia y el número de órdenes entre las 4 regiones donde opera Corwell Group?

4. **Rentabilidad de los productos:** ¿Cómo se puede clasificar a cada producto según su nivel de rentabilidad (alta, media o baja) para priorizar decisiones comerciales?

5. **Evolución Mensual de Ingresos:** ¿Cómo ha evolucionado el ingreso mes a mes durante 2023 y 2024? ¿Existen patrones de estacionalidad?

6. **Distribución de Ingresos por Estado:** ¿Qué estados concentran el 80% del ingreso total de la empresa? ¿Vale la pena distribuir el esfuerzo comercial por igual entre todos los estados?

7. **Frecuencia de compra por cliente:** ¿Qué proporción de clientes ha realizado más de una compra, frente a los que solo compraron una vez?

8. **Tasa de crecimiento mensual por categoría:** ¿Cuál es la tasa de crecimiento mes a mes del ingreso por categoría de producto, y qué categorías muestran una tendencia sostenida de crecimiento o caída?

9. **Ranking de productos por categoría:** ¿Cuáles son los productos más y menos rentables dentro de cada categoría, ordenados por ranking interno?

10. **Detección de caída de ventas:** ¿Existen productos con una caída sostenida de ventas durante 2 o más meses consecutivos que ameriten una alerta temprana?

11. **Segmentación de clientes por valor de compra:** ¿Cómo se segmentan los clientes según su valor de compra acumulado (en cuartiles), y qué porcentaje del ingreso total aporta el cuartil superior?

12. **Contribución regional al margen de ganancia:** ¿Cuál es la contribución acumulada de cada región al margen de ganancia total de la empresa?

13. **Matriz de desempeño Categoría Región:**¿Qué combinaciones de categoría y región presentan el mejor y el peor desempeño conjunto de ingreso y margen?

14. **Detección de outliersen Precio Unitario:**¿Existen productos con un precio unitario anormalmente alto o bajo respecto al promedio de su subcategoría, que ameriten revisión de pricing?

## Arquitectura y Modelado de Datos

El dataset original consistía en un archivo plano desnormalizado en formato (.csv). Para optimizar el almacenamiento y facilitar el análisis, se optó por diseñar un modelo relacional de datos para el almacenamiento y segmentación de la infrormación. Este modelo  se compone de las siguientes tablas:

- `Dim_Customers`: (Dimensión de Clientes) Contiene nombres y apellidos del cliente.
- `Dim_Geography`: (Dimensión de Geografía) Contiene información geográfica como ciudad, estado, región y país.
- `Dim_Products`: (Dimensión de Productos) Contiene información de los productos como nombre, categoría y subcategoría.
- `Fact_Sales`: (Tabla de Hechos de Ventas) Contiene información sobre las ventas como fecha de transacción, cantidad, precio unitario, ingreso y ganancia.

```sql
-- ==============================
-- 1. NORMALIZACION DE LA DATA
-- ==============================

-- ===============================================
-- a) Tabla Dimensional de Clientes (Dim_Customer)
-- ===============================================

-- Creación de tabla Dim_Customer

CREATE TABLE Dim_Customer (
	Customer_ID		INT IDENTITY(101,1) NOT NULL,
	Customer_Name	VARCHAR(100) NOT NULL,
	CONSTRAINT PK_Dim_Customer PRIMARY KEY (Customer_ID) );

-- Inserción de Data en Dim_Customer

INSERT INTO Dim_Customer (Customer_Name)
	SELECT 
		DISTINCT Customer_Name
	FROM sales
;

-- ===============================================
-- b) Tabla Dimensional de Productos (Dim_Product)
-- ===============================================

-- Creación de tabla Dim_Product

CREATE TABLE Dim_Product (
	Product_ID		INT IDENTITY(1,1) NOT NULL,
	Product_Name	VARCHAR(100) NOT NULL,
	Sub_Category	VARCHAR(50),
	Category		VARCHAR(50),
	CONSTRAINT PK_Dim_Product PRIMARY KEY (Product_ID) ) ;

-- Inserción de Data en Dim_Product

INSERT INTO Dim_Product (Product_Name, Sub_Category, Category)
	SELECT 
		DISTINCT Product_Name,
		Sub_Category,
		Category
	FROM sales
	ORDER BY Category ASC, Sub_Category ASC, Product_Name ASC;

-- ===============================================
-- c) Tabla Dimensional de Geography (Dim_Geography)
-- ===============================================

-- Creación de tabla Dim_Geography

CREATE TABLE Dim_Geography (
	Geo_ID			INT IDENTITY(1,1) NOT NULL,
	City			VARCHAR(100),
	State			VARCHAR(50),
	Region			VARCHAR(20),
	Country			VARCHAR(50),
	CONSTRAINT PK_Dim_Geography PRIMARY KEY (Geo_ID) ) ;

-- Inserción de Data en Dim_Geography

INSERT INTO Dim_Geography (City, State, Region, Country)
	SELECT
		DISTINCT City,
		State,
		Region,
		Country
	FROM sales 
	ORDER BY Region ASC, State ASC, City ASC

-- ===============================================
-- d) Tabla de Hechos de Ventas (Fact_Sales)
-- ===============================================

-- Creación Tabla De Hechos de Ventas (Fact_Sales)

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

-- Inserción de Data en Fact_Sales

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
```

A continuación se muestra el diagrama entidad-relación del modelo relacional de datos:

![Diagrama Entidad-Relación](./Picture/Diagrama_Entidad_Relacion.png)

## Limpieza de datos
Antes de realizar el análisis, es fundamental asegurar que los datos estén limpios y completos. Se deben verificar la integridad de los datos, la consistencia de las fórmulas y la calidad de los registros. Los pasos realizados en esta etapa fueron:

### 1. Verificación de valores nulos o faltantes:

Se verificó la existencia de valores faltantes en los campos clave dentro de la tabla `sales`: 
- `Order_ID`
- `Order_Date`
- `Customer_Name`
- `City`
- `Quantity`
- `Unit_Price`
- `Revenue`
- `Profit`

No se encontraron valores nulos o faltantes.


```sql
-- =============================
-- Valores Nulos o Faltantes
-- =============================

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
```
![Valores_Nulos](./Picture/valores_nulos.png)

### 2. Verificación de valores duplicados:
A continuación, se procede a verificar la existencia de valores duplicados en los campos clave. No se encontraron duplicados.

```sql
-- =============================
-- Valores Duplicados
-- =============================

-- Verificacion de valores duplicados en la tabla Fact_Sales

SELECT Order_ID, COUNT(1) as ValoresDuplicados
FROM Fact_Sales
GROUP BY Order_ID
HAVING COUNT(1) > 1;
```
![Valores_Nulos](./Picture/valores_duplicados.png)

### 3. Verificación de inconsistencias:
A continuación, se procede a verificar incosistencias en los campos clave. No se encontraron incosistencias

```sql
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
;
```
![Valores_Inconsistentes](./Picture/valores_inconsistencia.png)

## Análisis Exploratorio de Datos e Insights

### 1.  Ingreso y Margen Total por Categoria de Producto

#### ¿Cual es el ingreso total y la ganancia total generados por cada categoría de producto, y que porcentaje de margen representa cada una?

Se determinó el Ingreso y Margen Total utilizando las funciones SUM, GROUP BY, y CAST para transformar los valores a formatos decimales. 

Además se aplicó la función FORMAT para modificar la visualización de los valores en miles.

Para poder relacionar los datos de la tabla Fact_Sales con los de la tabla Dim_Product, se realizó una inner join entre ambas tablas utilizando el campo Product_ID.

```sql
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
```

![pregunta1](./Picture/pregunta1.png)

**Insight:** 

- La categoría _Accessories_ tuvo el mayor porcentaje de margen con 34.0 % seguido de cerca por _Clothing & Apparel_ con 32.53 %. Sin embargo, ambas categorías representan el menor ingreso de todas, con $10.1 Millones y $27.1 Millones respectivamente.
- Por otro lado, la categoría _Electronics_ se identifico como la que posee el menor porcentaje de margen con 14.03% y a su vez es la que tiene mayores ingresos con $57.5 Millones.
- Se sugiere una revisión de la estructura de Costos de la categoría _Electronics_ al ser la categoría que más factura pero que menos margen brinda a la empresa.
- El negocio podría enfocarse en potenciar el margen de la categoría _Electronics_ y además modificar la estrategia comercial para las categorías _Accessories_ y _Clothing & Apparel_ con el objetivo de aumentar la rentabilidad general del negocio.


### 2.  Mejores Productos del Catálogo por Margen

Se encontró los 10 productos con mayores ingresos de la empresa utilizando las funciones TOP, SUM, GROUP BY y ORDER BY.

#### ¿Cuales son los productos que generan mayor margen para la empresa?

```sql
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
ORDER BY SUM(f.Revenue) DESC
```

![pregunta2](./Picture/pregunta2.png)

Insight: 

-  El producto _Tempur-Pedic Mattress_ es el líder en ventas y en margen de ganancia con $9.06 Millones y 23.55% respectivamente. Seguido de Instant Pot con $8.90 Millones y 18.98% de Margen. 
- Se identificó que 5 de los 10 productos más vendidos pertenecen a la categoría _Electronics_, todos estos con un margen que ronda entre los 13.9% y 14.1% que justamente representa un valor bajo frente a otras categorías
- La empresa podría priorizar el crecimiento de sus productos líderes como _Tempur-Pedic Mattress_ y  _Storage Rack_ que combinan Ingresos y Margenes Altos superiores al 23%, mientras se analiza la estrategia de precios y costos de los productos de la categoría _Electronics_ ya que genera menor ganancia relativa por venta.


### 3. Ventas Totales Por Región

#### ¿Como se comparan las ventas totales, la ganancia y la cantidad de de órdenes entre las 4 regiones donde opera el negocio?

Se determinó el Ingreso, Margen, Porcentaje de Margen y cantidad de Ordenes por Región utilizando las funciones SUM, COUNT, GROUP BY y ORDER BY para comparar las relaciones entre las distintas regiones donde opera el negocio.

```sql
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
```
![pregunta3](./Picture/pregunta3.png)

**Insight:** 

- La región Este se posiciona como la principal fuente de ingresos com $44.98M y 57034 órdenes, superando casi por el doble a la región Oeste que posee $25.10M y 37935 órdenes. Asi mismo, la región Este posee el peor margen de las 4 regiones con 20.50% y South generó el menor ingreso ($23.58M) pero alcanzó el mejor margen porcentual (23.58%).
- Se sugiere la realización de un estudio de rentabiliad en la región Este para identificar si se debe a un mercado con mayor presencia de categorías de bajo margen como Electronics.
- Si South tiene el mayor margen con menor operación de ventas, se debería evaluar el enfoque comercial utilizado para ver si es viable aplicarlo a la región Este sin sacrificar su volumen de ventas.


### 4. Rentabilidad de los productos

#### ¿Como se puede clasificar a cada producto según su nivel de rentabilidad (alta, media o baja) para priorizar decisiones comerciales?

Se encontró la rentabilidad de los productos mediante una clasificación de margen alto, medio y bajo. Se utilizaron las funciones SUM, GROUP BY, ORDER BY y CASE WHEN.

- El margen alto corresponde a un porcentaje mayor o igual a 33%.
- El margen medio corresponde a un porcentaje mayor o igual a 17% y menor a 33%.
- El margen bajo corresponde a un porcentaje menor a 17%.

```sql
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
```

![pregunta4_1](./Picture/pregunta4_1.png)

![pregunta4_2](./Picture/pregunta4_2.png)


**Insight:**
- Los productos clasificados con rentabilidad alta son en su gran mayoría del segmento de Accesories con márgenes entre 33.63% a a 34.37%. Mientras que los del segmento Medio son principalmente de Clothin & Apparel con márgenes cercanos al 32.00% y Home & Furniture con márgenes entre 18% y 24%.
- En el segmento de margen bajo se encuentra la categoría Electronics con un márgen aproximado de 13.9%.
- La empresa podría tratar a Clothin & Apparel con una prioridad comercial similar a la de Accesories pues poseen margenes bastante cercanos.
- Tratar a los productos cercanos a posicionarse en el segmento de margen bajo como Instant Pot y Kithen Aid Mixer priorizando su volumen de venta para evitar la caída en la clasificación.

### 5. Evolución Mensual de Ingresos

¿Como ha evolucionado el ingreso mes a mes durante 2023 y 2024? ¿Existe algun patron de estacionalidad?

Se obtuvo la evolucion mes a mes de los Ingresos y el Margen a través de la funciones YEAR, MONTH, DATENAME para desagregar las fechas y SUM, COUNT y GROUP BY para generar las agrupaciones numéricas.

```sql
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
```

![pregunta5_final](./Picture/pregunta5_final.png)
 
 **Insight:**

 - En 2023 los ingresos se mantuvieron estables durante los primeros 9 meses, alcanzando un punto más alto en Noviembre con $10.48M y cerrando el año con $9.36M.
 - En 2024 se ve un incremento generalizado en los ingresos, siendo Octubre ($14.09M) y Noviembre ($15.71M) los meses de mayores ventas. Sin embargo, diciembre registro una caída considerable con $10.53M.
 - Se pudo determinar por tanto una estacionalidad marcada en el último trimestre del año ya que se concentra la mayor cantidad de ventas de todo el año.
 - Se pudo identificar al mes de Febrero como el mes más débil del año en cuanto a Ingresos, Margen y Ordenes.
 - Al realizar una comparación mes a mes entre 2023 y 2024, los crecimientos son mínimos o nulos y hasta en algunos casos (enero, julio, diciembre) se registraron caídas leves.
 - La empresa debería concentrar su presupuesto de inventario y logística en el cuarto trimestre del año (Oct-Nov-Dic), que representa aproximadamente el 35-40% del ingreso anual.
 - También se debería construir campañas de reactivación comercial para febrero, puesto que es el punto más frágil de nuestra operación comercial anual y tiene un gran margen de mejora.
