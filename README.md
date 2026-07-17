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

## Limpieza de datos
Antes de realizar el análisis, es fundamental asegurar que los datos estén limpios y completos. Se deben verificar la integridad de los datos, la consistencia de las fórmulas y la calidad de los registros. Los pasos realizados en esta etapa fueron:

### Verificación de valores nulos o faltantes:

Se verificó la existencia de valores faltantes en los campos clave dentro de la tabla `sales`: 
- `Order_ID`
- `Order_Date`
- `Customer_Name`
- `City`
- `Quantity`
- `Unit_Price`
- `Revenue`
- `Profit`

#### Verificación de valores nulos en tabla sales

#### 2. Verificación de valores duplicados:
#### 3. Verificación de inconsistencias: