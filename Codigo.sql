-- Jorge Antony Zarate Davila
-- Lima Perú

/* 
Crearemos tablas con una estructura adecuada y definiremos relaciones precisas para cada columna, 
utilizando tipos de datos como VARCHAR, TEXT, e INT. Además, emplearemos instrucciones como 
PRIMARY KEY, AUTO_INCREMENT, y NOT NULL para establecer restricciones. También usaremos el comando 
IF NOT EXISTS al crear tablas para asegurar que solo se creen si aún no existen.
*/
CREATE TABLE IF NOT EXISTS inei_project (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mes VARCHAR(10),
    ubigeo VARCHAR(55) NOT NULL,
    estrato VARCHAR(55),
    product_name TEXT NOT NULL,
    unidad_medida VARCHAR(55),
    sistema_unidades VARCHAR(55),
    marca VARCHAR(55),
    medicina VARCHAR(55),
    lugar TEXT NOT NULL,
    monto_total VARCHAR(55),
    tipo_pago VARCHAR(55)
);

CREATE TABLE IF NOT EXISTS peru_location (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    ubigeo VARCHAR(55),
    distrito VARCHAR(55),
    provincia VARCHAR(55),
    departamento VARCHAR(55),
    poblacion INT
);

CREATE TABLE IF NOT EXISTS Recycle_Bin (
    recycle_bin_id INT PRIMARY KEY,
    ubigeo VARCHAR(55) NOT NULL,
    estrato VARCHAR(55),
    product_name VARCHAR(255) NOT NULL,
    marca VARCHAR(55),
    lugar VARCHAR(255) NOT NULL,
    monto_total VARCHAR(55),
    FOREIGN KEY (ubigeo) REFERENCES inei_project(ubigeo)
);

/*
En este caso, utilizamos el comando ALTER TABLE para realizar dos operaciones. La primera es cambiar el 
nombre de la columna 'id' a 'project_id', y la segunda es añadir una nueva CONSTRAINT que convierte la columna 
'ubigeo' en una FOREIGN KEY.
*/
ALTER TABLE inei_project 
    RENAME COLUMN id TO project_id,
    ADD CONSTRAINT fk_ubigeo FOREIGN KEY (ubigeo) REFERENCES peru_location(ubigeo);

/* 
En esta ocasión, podemos usar el comando ALTER TABLE para cambiar el tipo de dato de una columna. En este caso, 
se trata de la columna ubigeo, que cambia de tipo VARCHAR(55) NOT NULL a TINYINT.
*/
ALTER TABLE inei_project
	MODIFY ubigeo TINYINT;

/* 
En este caso, utilizamos el comando ALTER TABLE para realizar tres operaciones en la tabla 'peru_location'. 
Primero, eliminamos la clave primaria existente con DROP PRIMARY KEY. Luego, añadimos una nueva columna 
'location_id' como clave primaria con AUTO_INCREMENT y NOT NULL, garantizando la unicidad de cada registro. 
Finalmente, cambiamos el tipo de dato de la columna 'distrito' a VARCHAR(55) para ajustar su longitud.
*/
ALTER TABLE peru_location 
    DROP PRIMARY KEY,
    ADD location_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    MODIFY distrito VARCHAR(55);

/* 
Es una buena práctica utilizar índices, por ello decidí crear dos de ellos para optimizar las consultas en 
las tablas 'inei_project' y 'peru_location'.
*/
CREATE INDEX inei_pro_lug_idx ON inei_project (product_name, lugar);
CREATE INDEX inei_dis_dep_idx ON peru_location (distrito, departamento);

/* 
El comando cuenta el cada valor en la columna `unidad_medida` de la tabla `inei_project`, 
excluyendo los valores 'VEZ' y 'ATADO'. Luego, agrupa los resultados por cada valor único de `unidad_medida`
y los ordena en orden descendente según su frecuencia de aparición. 
*/
SELECT unidad_medida, COUNT(unidad_medida) AS top FROM inei_project
GROUP BY unidad_medida
HAVING unidad_medida NOT IN ('VEZ', 'ATADO')
ORDER BY top DESC
LIMIT 10;

/*
Creamos dos vistas para analizar los datos de 'inei_project'. La vista 'top_20_places' muestra los 20 lugares 
con más registros, mientras que 'estrato_per_located' presenta el conteo de estratos por ubicación específica 
(departamento y distrito) para los 30 principales, uniendo ambas tablas por la columna 'ubigeo'.
*/
CREATE VIEW top_20_places AS
    SELECT COUNT(ubigeo) AS numero, lugar
    FROM inei_project
    GROUP BY lugar
    ORDER BY numero DESC
    LIMIT 20;

CREATE VIEW estrato_per_located AS
    SELECT COUNT(I.estrato), I.estrato, P.departamento, P.distrito 
    FROM inei_project AS I
    INNER JOIN peru_location AS P ON I.ubigeo = P.ubigeo 
    GROUP BY I.estrato, P.departamento, P.distrito
    ORDER BY COUNT(I.estrato) DESC
    LIMIT 30;

/*
Creamos un trigger llamado 'Recycle_Bin_table' que se activa antes de cada eliminación en 'inei_project'. 
Este trigger inserta los datos eliminados en la tabla 'Recycle_Bin', guardando un respaldo de las columnas clave 
de cada fila eliminada (como 'ubigeo', 'estrato', y otros campos) en 'Recycle_Bin'.
*/
DELIMITER $$
CREATE TRIGGER Recycle_Bin_table
    BEFORE DELETE ON inei_project
    FOR EACH ROW
BEGIN
    INSERT INTO Recycle_Bin (recycle_bin_id, ubigeo, estrato, product_name, marca, lugar, monto_total) 
    VALUES (OLD.project_id, OLD.ubigeo, OLD.estrato, OLD.product_name, OLD.marca, OLD.lugar, OLD.monto_total);
END $$
DELIMITER ;

/*
Este comando inserta datos en la tabla 'temp_peru_location' desde la tabla 'peru_location'. 
Específicamente, selecciona las columnas 'ubigeo', 'distrito', 'provincia', 'departamento' y 'poblacion' 
de 'peru_location' y las copia en 'temp_peru_location'.

Se utiliza un comando `INSERT INTO ... SELECT ...` para realizar la transferencia de datos de forma eficiente. 
De esta manera, se puede hacer un respaldo o trabajar temporalmente con una copia de los datos de 'peru_location' 
sin afectar la tabla original.
*/
INSERT INTO temp_peru_location (ubigeo, distrito, provincia, departamento, poblacion)
    SELECT ubigeo, distrito, provincia, departamento, poblacion FROM peru_location;

/*
Estos comandos actualizan valores en la tabla 'inei_project' para estandarizar o corregir datos específicos.

El primer comando cambia el valor de 'sistema_unidades' a 'No Definido' en las filas donde antes era 'No Corresponde'. 
Esto ayuda a mantener consistencia en los datos para valores similares.

El segundo comando actualiza la columna 'marca', asignando 'SIN MARCA - SM' en las filas donde el campo 'marca' 
está vacío (''). Para otros valores de 'marca', deja el contenido original sin cambios. Esta técnica usa un 
`CASE` para aplicar condiciones dentro de la actualización.
*/
UPDATE inei_project
SET sistema_unidades = 'No Definido'
WHERE sistema_unidades = 'No Corresponde';

UPDATE inei_project
SET marca = CASE 
    WHEN marca = '' THEN 'SIN MARCA - SM'
    ELSE marca
END;

/*
Este comando carga aproximadamente 1.9 millónes de registros en la tabla 'peru_location' desde el archivo CSV ubicado en 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ubigeo-reniec(ubigeo_reniec).csv'. 

Se especifica que los campos están delimitados por comas y encerrados entre comillas dobles. 
Cada fila en el archivo termina con un salto de línea, y la primera fila (generalmente de encabezados) es ignorada.
*/
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ubigeo-reniec(ubigeo_reniec).csv'
INTO TABLE peru_location
FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

/*
Estos comandos extraen información clave para analizar la relación entre productos, lugares y su comportamiento 
de venta, útil para comprender patrones comerciales en 'inei_project' al unir información geográfica de 'peru_location'.

El primer comando obtiene los 10 registros principales de productos vendidos en 'Oferta' o 'Combo', agrupados 
por características como estrato, producto, lugar y detalles de ubicación (departamento y distrito). La columna 
'Frecuencia' muestra cuántas veces se registran estas combinaciones, ordenadas en orden descendente.

El segundo comando proporciona un análisis de ingresos al sumar 'monto_total' de productos por estrato, lugar, 
producto, distrito y departamento. Se filtran únicamente los registros con ingresos iguales o superiores a 500. 
El resultado, ordenado de mayor a menor, muestra los 30 principales ingresos para identificar oportunidades de 
mayor valor en el mercado.

Estas consultas son ideales para evaluar tanto la popularidad de ciertos tipos de pago como el rendimiento financiero 
según localización y tipo de producto, ofreciendo un análisis geoestratégico detallado.
*/
SELECT COUNT(I.lugar) AS Frecuencia, I.estrato, I.product_name, I.lugar, I.tipo_pago, P.departamento, P.distrito 
FROM inei_project AS I
INNER JOIN peru_location AS P ON I.ubigeo = P.ubigeo
WHERE I.tipo_pago IN ('Oferta', 'Combo')
GROUP BY I.estrato, I.product_name, I.lugar, I.tipo_pago, P.departamento, P.distrito 
ORDER BY Frecuencia DESC
LIMIT 10;

SELECT I.estrato, I.product_name, I.lugar, SUM(I.monto_total), P.distrito, P.departamento 
FROM inei_project AS I 
INNER JOIN peru_location AS P ON I.ubigeo = P.ubigeo
GROUP BY I.estrato, I.product_name, I.lugar, P.distrito, P.departamento
HAVING SUM(I.monto_total) >= 500
ORDER BY SUM(I.monto_total) DESC
LIMIT 30;

/*
Este comando elimina registros específicos en 'inei_project' donde el 'project_id' coincide con los valores 
'320585', '701769' o '701806', removiendo estos registros de forma permanente de la tabla.
*/
DELETE FROM inei_project 
WHERE project_id IN ('320585', '701769', '701806');

/*
El primer comando elimina la tabla 'peru_location2' si existe, limpiando la base de datos de tablas innecesarias. 
El segundo comando elimina el índice 'inei_pro_lug_idx' en 'inei_project', útil si el índice ya no se necesita o 
para optimizar futuras consultas.
*/
DROP TABLE IF EXISTS peru_location2;
DROP INDEX inei_pro_lug_idx ON inei_project;

SELECT * FROM inei_project
LIMIT 10;

