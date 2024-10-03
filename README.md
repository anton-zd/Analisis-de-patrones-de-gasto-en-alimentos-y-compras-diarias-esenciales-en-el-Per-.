# Analisis de patrones de gasto en alimentos y compras diarias esenciales en el Perú.
![New Project](https://github.com/user-attachments/assets/a3e3b856-36ce-4f73-83d8-5ac19d50c64d)

Este proyecto tiene como objetivo analizar cómo las familias gastan su dinero en alimentos, con especial atención a la identificación de los artículos más importantes que compran a diario. Mediante consultas SQL y grandes conjuntos de datos, este análisis descubrirá patrones de gasto, priorizará los artículos esenciales de uso diario y brindará información sobre el comportamiento de compra de alimentos a un nivel granular. Los datos utilizados en este proyecto fueron obtenidos de los siguientes sitios web oficiales:

- [RENIEC](https://www.reniec.gob.pe/portal/masServiciosLinea.htm)
- [INEI](https://www.inei.gob.pe/estadisticas-indice-tematico/)

Ademas en lugar de insertar los datos de manera manual, utilicé el siguiente código **SQL** para importar los datos desde los archivos CSV directamente a la base de datos MySQL:

```sql
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ubigeo-reniec(ubigeo_reniec).csv'
INTO TABLE ubigeo_database
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

Posteriormente, después de haber limpiado las tablas utilizando las bibliotecas de **Python** como **pandas**, se obtuvieron tablas mucho más limpias y organizadas, facilitando su posterior procesamiento en MySQL. Estos datos fueron manipulados y analizados utilizando consultas SQL para obtener insights significativos.


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


## Tabla RECYLCE BIN
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
Al utilizar la consulta SQL propuesta, podemos fusionar las tablas inei_project y peru_location a través de un inner join basado en la columna ubigeo. Esto nos permite combinar información de productos y gastos con datos geográficos, proporcionando un análisis más completo. De este modo, es posible obtener mejores resultados y visualizar patrones de gasto según las regiones del país. Esta integración de datos enriquece nuestras capacidades analíticas, permitiendo identificar tendencias y comportamientos con mayor precisión.

```sql
SELECT I.ubigeo, I.estrato, I.product_name, I.lugar, I.monto_total, U.distrito, U.provincia, U.departamento 
FROM inei_project AS I
INNER JOIN peru_location AS U ON I.ubigeo = U.ubigeo
WHERE I.monto_total BETWEEN 500 AND 1000 
AND U.departamento <> 'Callao'
LIMIT 10;
```
## Resultados del INNER JOIN

| Ubigeo  | Estrato    | Producto             | Lugar                                  | Monto | Distrito  | Provincia | Depto. |
|---------|------------|----------------------|----------------------------------------|-------|-----------|-----------|--------|
| 200101  | Medio Alto | MORRAL DE CUERO       | TIENDA - VENTA ARTICULOS DE CUERO       | 540   | Puno      | Puno      | Puno   |
| 200104  | Medio      | PLANCHA DENTAL        | CENTRO ODONTOLOGICO - CONSULTORIO       | 500   | Capachica | Puno      | Puno   |
| 200104  | Medio      | GASTO DE MISA         | IGLESIA - CAPILLA                      | 500   | Capachica | Puno      | Puno   |
| 140101  | Medio Bajo | SERVICIO DE DECORACION| No Definido                            | 500   | Lima      | Lima      | Lima   |
| 140101  | Alto       | TELEVISOR SMART       | TOTTUS                                 | 950   | Lima      | Lima      | Lima   |
