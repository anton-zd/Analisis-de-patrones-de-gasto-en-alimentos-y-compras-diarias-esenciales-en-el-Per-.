# Analisis de patrones de gasto en alimentos y compras diarias esenciales.
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







