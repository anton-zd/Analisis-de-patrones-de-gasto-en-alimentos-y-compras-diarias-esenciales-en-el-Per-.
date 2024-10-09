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

-- View creation
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

-- Trigger creation for recycle bin
DELIMITER $$
CREATE TRIGGER Recycle_Bin_table
    BEFORE DELETE ON inei_project
    FOR EACH ROW
BEGIN
    INSERT INTO Recycle_Bin (recycle_bin_id, ubigeo, estrato, product_name, marca, lugar, monto_total) 
    VALUES (OLD.project_id, OLD.ubigeo, OLD.estrato, OLD.product_name, OLD.marca, OLD.lugar, OLD.monto_total);
END $$
DELIMITER ;

-- Data manipulation examples
INSERT INTO temp_peru_location (ubigeo, distrito, provincia, departamento, poblacion)
    SELECT ubigeo, distrito, provincia, departamento, poblacion FROM peru_location;

UPDATE inei_project
SET sistema_unidades = 'No Definido'
WHERE sistema_unidades = 'No Corresponde';

UPDATE inei_project
SET marca = CASE 
    WHEN marca = '' THEN 'SIN MARCA - SM'
    ELSE marca
END;

DELETE FROM inei_project 
WHERE project_id IN ('320585', '701769', '701806');

-- Data import example
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ubigeo-reniec(ubigeo_reniec).csv'
INTO TABLE peru_location
FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- Example queries for data analysis
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

-- Final cleanup commands (optional)
DROP TABLE IF EXISTS peru_location2;
DROP INDEX inei_pro_lug_idx ON inei_project;
