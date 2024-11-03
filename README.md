# Analisis de patrones de gasto en alimentos y compras diarias esenciales en el Perú.
![New Project](https://github.com/user-attachments/assets/a3e3b856-36ce-4f73-83d8-5ac19d50c64d)

Este proyecto tiene como objetivo analizar cómo las familias gastan su dinero en alimentos, con especial atención a la identificación de los artículos más importantes que compran a diario. Mediante consultas SQL y grandes conjuntos de datos, este análisis descubrirá patrones de gasto, priorizará los artículos esenciales de uso diario y brindará información sobre el comportamiento de compra de alimentos a un nivel granular. Los datos utilizados en este proyecto fueron obtenidos de los siguientes sitios web oficiales:

- [RENIEC](https://www.reniec.gob.pe/portal/masServiciosLinea.htm) 
- [INEI](https://www.inei.gob.pe/estadisticas-indice-tematico/) [Encuesta Nacional de Presupuestos Familiares (ENAPREF) 2019 - 2020] (https://drive.google.com/drive/folders/1QJlqf5QCj1drn3D8XQE0sbR1KUoWrlAb?usp=drive_link)
***
Poseo de un amplio conocimiento en SQL queries, que incluyen la creación de bases de datos, la manipulación de tablas y la gestión de datos. Mi experiencia abarca el uso de `CREATE DATABASE`, `USE DATABASE`, `CREATE TABLE` y `DROP TABLE` para la configuración de bases de datos y tablas, así como la modificación de estructuras existentes con `ALTER TABLE` para agregar o eliminar claves y restricciones. Además, tengo una experiencia significativa en la ejecución de consultas esenciales como `INSERT INTO`, `SELECT`, `GROUP BY`, `SUM` e `INNER JOIN`, lo que permite una recuperación y agregación de datos eficiente. También soy hábil en operaciones más avanzadas, como `CREATE VIEW`, `CREATE TRIGGER`, `SHOW TRIGGERS` y `LOAD DATA INFILE` para la gestión y automatización de datos. Mi competencia se extiende al trabajo con índices, optimizando consultas mediante `CREATE INDEX`, `DROP INDEX`, `SHOW INDEXES` y mas.
***

Ademas en lugar de insertar los datos de manera manual, utilicé el siguiente código **SQL** para importar los datos desde los archivos CSV directamente a la base de datos MySQL:
```sql
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ubigeo-reniec(ubigeo_reniec).csv'
INTO TABLE ubigeo_database
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

## Tabla INEI

| ID  | Mes | Ubigeo  | Estrato | Producto                      | Unidad  | Marca         | Lugar                     | Monto | Pago         |
|-----|-----|---------|---------|-------------------------------|---------|---------------|---------------------------|-------|--------------|
| 1301 | 12  | 240101  | Medio   | Huevo de Gallina Rosado        | UNIDAD  | SIN MARCA - SM | Bodega al por menor        | 2     | Precio Normal |
| 1302 | 12  | 240101  | Medio   | Leche Evaporada                | LATA    | GLORIA        | Bodega al por menor        | 3     | Precio Normal |
| 1303 | 12  | 240101  | Medio   | Arroz Corriente                | KILO    | SIN MARCA - SM | Bodega al por menor        | 3     | Precio Normal |
| 1304 | 12  | 240101  | Medio   | Gallina Eviscerada             | GRAMO   | SIN MARCA - SM | Mercado - Puesto de Mercado | 10    | Precio Normal |
| 1305 | 12  | 240101  | Medio   | Tomate Redondo                 | GRAMO   | SIN MARCA - SM | Mercado - Puesto de Mercado | 1     | Precio Normal |


## Tabla RENIEC

| ID de Ubicación | Ubigeo  | Distrito       | Provincia | Departamento | Población |
|-----------------|---------|----------------|-----------|--------------|-----------|
| 1               | 100101  | Ica            | Ica       | Ica          | 134249    |
| 2               | 100102  | La Tinguiña    | Ica       | Ica          | 36909     |
| 3               | 190104  | Catacaos       | Piura     | Piura        | 74562     |
| 4               | 190106  | La Unión       | Piura     | Piura        | 41736     |
| 5               | 100104  | Parcona        | Ica       | Ica          | 56336     |


## FUNCIÓN TRIGGER
Para asegurar que los datos eliminados de la tabla principal **inei_project** no se pierdan permanentemente, se creó un **trigger** llamado `Recycle_Bin_table`. 

```sql
DELIMITER $$
CREATE TRIGGER Recycle_Bin_table
    BEFORE DELETE ON inei_project
    FOR EACH ROW
BEGIN
    INSERT INTO Recycle_Bin (recycle_bin_id, ubigeo, estrato, product_name, marca, lugar, monto_total) 
    VALUES (OLD.project_id, OLD.ubigeo, OLD.estrato, OLD.product_name, OLD.marca, OLD.lugar, OLD.monto_total);
END $$
DELIMITER ;
```
Este trigger guarda automáticamente una copia de los registros eliminados en una tabla de respaldo llamada **Recycle_Bin**.

| ID   | Ubigeo  | Estrato    | Producto | Marca          | Lugar                                     | Monto |
|------|---------|------------|----------|----------------|-------------------------------------------|-------|
| 320585 | 160101  | Medio Alto | UTO      | SIN MARCA - SM | IGLESIA - CAPILLA - CENTRO PASTORAL        | 1     |
| 701769 | 250101  | Medio Bajo | UTO      | SIN MARCA - SM | AMBULANTE - EXCEPTO DE VENTA DE COMIDA     | 1     |
| 701806 | 250101  | Medio Bajo | UTO      | SIN MARCA - SM | PERSONA PARTICULAR                        | 0     |

***
Por ejemplo, ahora podemos examinar el query y su resultado (la tabla) donde primero utilicé `SELECT` para especificar las columnas que quería mostrar, junto con sus respectivas abreviaturas. Me he referido a `inei_project` como `I` y a `peru_location` como `P`. La operación `INNER JOIN` funciona fusionando dos tablas en base a una columna común, lo que en este caso nos permitió identificar los `DEPARTAMENTOS`, `DISTRITO`, `PRODUCTO` y `ESTRATO` que más frecuentemente compran en `Oferta` o `Combo`. A continuación, agrupamos los datos por `estrato`, `nombre_producto`, `lugar`, etc., y los ordenamos por los lugares con mayor frecuencia de compra.

```sql
SELECT COUNT(I.lugar)AS Frecuencia, I.estrato, I.product_name, I.lugar, I.tipo_pago, P.departamento, P.distrito 
FROM inei_project AS I
INNER JOIN peru_location AS P ON I.ubigeo = P.Ubigeo
WHERE  I.tipo_pago IN ('Oferta', 'Combo')
GROUP BY I.estrato, I.product_name, I.lugar, I.tipo_pago, P.departamento, P.distrito 
ORDER BY Frecuencia DESC
LIMIT 5;
```
## Resultados del INNER JOIN
En la tabla podemos obervar que el departamento de **Piura** y distrito de **Tambo Grando** es el que mas frecuencia tiene en la compra de productos en formato combo, en las bodegas al por menor, en productos como la **Canela a Granel** con una frecuencia de 47 veces y de esa forma tambien identificamos como tambien en el distrito de **Tambo Grande** el clavo de olor envasado es 

|   Frecuencia | estrato    | product_name           | lugar               | tipo_pago   | departamento   | distrito     |
|-------------:|:-----------|:-----------------------|:--------------------|:------------|:---------------|:-------------|
|           47 | Bajo       | CANELA ENTERA A GRANEL | BODEGA AL POR MENOR | Combo       | Piura          | Tambo Grande |
|           37 | Medio Alto | CLAVO DE OLOR ENVASADO | BODEGA AL POR MENOR | Combo       | Piura          | Piura        |
|           36 | Medio Alto | CANELA ENTERA A GRANEL | BODEGA AL POR MENOR | Combo       | Piura          | Piura        |
|           35 | Medio Bajo | CANELA ENTERA A GRANEL | BODEGA AL POR MENOR | Combo       | Piura          | Piura        |
|           32 | Bajo       | CLAVO DE OLOR ENVASADO | BODEGA AL POR MENOR | Combo       | Piura          | Tambo Grande |


## TOP 10 PRODUCTOS MAS RELEVANTES PARA LAS FAMILIAS PERUANAS
A partir de la Encuesta Nacional de Presupuestos Familiares (ENAPREF) 2019 - 2020, realizada por el INEI y que involucró a más de un millón de familias, se puede determinar que el **2.60% de los hogares** priorizan el gasto en pasajes para movilizarse a través del país. 
Los datos fueron obtenidos mediante una Query, haciendo uso de **MySQL**, lo que permitió acceder a la información de manera eficiente. Posteriormente, estos datos se modelaron en **Power BI** para facilitar su interpretación y mejorar su visualización.
```sql
SELECT COUNT(product_name)AS top, product_name FROM inei_project
GROUP BY product_name
ORDER BY top DESC
LIMIT 10;
```

|   Rank | Product Name                     |
|-------:|:---------------------------------|
|  37579 | PASAJE ADULTO URBANO             |
|  36213 | HUEVO DE GALLINA ROSADO A GRANEL |
|  28834 | PAN FRANCES                      |
|  24576 | ALMUERZO MENU                    |
|  23519 | CEBOLLA ROJA                     |
|  21508 | LIMON AGRIO                      |
|  20869 | ZANAHORIA ENTERA                 |
|  20483 | ARROZ SUPERIOR A GRANEL          |
|  19826 | PAPA BLANCA                      |
|  17766 | AZUCAR RUBIA A GRANEL            |
***
![Top Most Common Gra](https://github.com/user-attachments/assets/d32cff81-4540-4611-a42d-2ecf86500f26)
