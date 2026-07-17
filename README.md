# Proyecto SQL-Server-Commercial-Analytics
Proyecto Integral de SQL Server para Analitica de Negocios
## Resumen (overview)
_Corwell Group es una empresa de distribución y venta retail de multicategoría con operaciones y presencia en Estados Unidos._

_El departamento de estrategia comercial de Corwell Group desea identificar en qué productos, categorías y mercados regionales debe enfocar sus esfuerzos de crecimiento y rentabilidad, priorizando decisiones de portafolio sobre una base de datos sólida en lugar de intuición._

_El objetivo del proyecto es utilizar el lenguaje **SQL** dentro del entorno de **SQL Server Management Studio**_ para estructurar, normalizar y analizar la información transaccional del negocio con el fin de entregar al área comercial recomendaciones accionables que permitan implementar mejoras practicas en su estrategia comercial, optimizar sus procesos y aumentar la rentabilidad._

## Estructura del Proyecto
- [Sobre los Datos](#sobre-los-datos)
- [Tareas](#tareas)
- [Arquitectura y Modelado de Datos](#arquitectura-y-modelado-de-datos)
- [Limpieza de Datos](#limpieza-de-datos)
- [Análisis Exploratorio de Datos e Insights](#análisis-exploratorio-de-datos-e-insights)
- [Conclusiones y Recomendaciones](#conclusiones-y-recomendaciones)

## Sobre los datos

Este proyecto utiliza datos provenientes de un único archivo .csv el cual contiene información sobre las transacciones de ventas de una empresa retail.

El dataset está compuesto por 200,000 registros, se puede acceder al dataset original [aquí](https://www.kaggle.com/datasets/yashyennewar/product-sales-dataset-2023-2024).

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

