CREATE TABLE IF NOT EXISTS inei_project (
	id int primary key auto_increment,
	mes varchar(10),
    ubigeo varchar(55) NOT NULL,
    estrato varchar(55),
    product_name text NOT NULL,
    unidad_medida varchar(55),
    sistema_unidades varchar(55),
    marca varchar(55),
    medicina varchar(55),
    lugar text NOT NULL,
    monto_total varchar(55),
    tipo_pago varchar(55),
    FOREIGN KEY (ubigeo) REFERENCES peru_location(bigeo)
);
CREATE TABLE inei_project (
	id int primary key auto_increment,
	Ubigeo VARCHAR(55),
    Distrito VARCHAR(55),
    Provincia VARCHAR(55),
    Departamento VARCHAR(55),
    Poblacion int
);
CREATE TABLE IF NOT EXISTS Recycle_Bin (
	recycle_bin_id int primary key,
    ubigeo varchar(55) NOT NULL,
    estrato varchar(55),
    product_name varchar(255) NOT NULL,
    marca varchar(55),
    lugar varchar(255) NOT NULL,
    monto_total varchar(55),
    FOREIGN KEY (ubigeo) REFERENCES inei_project(ubigeo)
);

SELECT * FROM recycle_bin
LIMIT 20;

ALTER TABLE recycle_bin
ADD CONSTRAINT FK_recycle_bin_ubigeo
FOREIGN KEY (ubigeo) REFERENCES inei_project(ubigeo);

DELETE FROM inei_project 
WHERE project_id IN ('320585', '701769', '701806');

DROP TABLE recycle_bin;

SELECT project_id, lugar, monto_total FROM inei_project
WHERE project_id = (
	SELECT project_id FROM inei_project
    WHERE product_name = ' U A'
)
LIMIT 20;

SELECT COUNT(project_id) , product_name FROM inei_project
GROUP BY product_name
HAVING COUNT(project_id) = 1
LIMIT 20;



DELETE FROM inei_project 
WHERE id = '496637';



ALTER TABLE inei_project ADD CONSTRAINT fk_ubigeo 
FOREIGN KEY (ubigeo) REFERENCES peru_location(Ubigeo);

CREATE INDEX fk_index_ubigeo ON peru_location(Ubigeo);


DROP INDEX inei_pro_lug_idx ON inei_project;


SHOW INDEXES FROM peru_location;

ALTER TABLE peru_location2 RENAME peru_location;

ALTER TABLE inei_project
ADD CONSTRAINT fk_ubigeo FOREIGN KEY (ubigeo) REFERENCES ubigeo_database(Ubigeo);

SELECT * FROM inei_project 
WHERE unidad_medida IS NULL AND TRIM(unidad_medida) <> ''
LIMIT 400;


SELECT count(distrito) FROM peru_location2
LIMIT 10;


SELECT COUNT(I.lugar)AS Frecuencia, I.estrato, I.product_name, I.lugar, I.tipo_pago, P.departamento, P.distrito 
FROM inei_project AS I
INNER JOIN peru_location AS P ON I.ubigeo = P.Ubigeo
WHERE  I.tipo_pago IN ('Oferta', 'Combo')
GROUP BY I.estrato, I.product_name, I.lugar, I.tipo_pago, P.departamento, P.distrito 
ORDER BY Frecuencia DESC
LIMIT 10;

SELECT * FROM peru_location
LIMIT 20;

SELECT * FROM recycle_bin
LIMIT 112;

CREATE VIEW estrato_per_located AS
	SELECT COUNT(I.estrato), I.estrato, P.departamento, P.distrito FROM inei_project AS I
	INNER JOIN peru_location AS P ON I.ubigeo = P.Ubigeo 
	GROUP BY I.estrato, P.departamento, P.distrito
	ORDER BY COUNT(I.estrato) DESC
	LIMIT 30
;

UPDATE inei_proje
SET sistema_unidades = 'No Definido'
WHERE sistema_unidades = 'No Corresponde';

UPDATE inei_project
SET marca = CASE 
	WHEN marca = '' THEN 'SIN MARCA - SM'
    ELSE marca
END;

ALTER TABLE inei_project DROP COLUMN mes_abreviado;

UPDATE inei_project
SET mes = CASE mes
    WHEN 'Ago.' THEN '8'
    WHEN 'Dic.' THEN '12'
    WHEN 'Ene.' THEN '1'
    WHEN 'Feb.' THEN '2'
    WHEN 'Jul.' THEN '7'
    WHEN 'Jun.' THEN '6'
    WHEN 'Nov.' THEN '11'
    WHEN 'Oct.' THEN '10'
    WHEN 'Set.' THEN '9'
    ELSE mes
END;

SELECT * FROM peru_location
LIMIT 10;



SELECT COUNT(product_name) AS Products, estrato FROM inei_project
HAVING estrato = Alto
LIMIT 100;

SELECT I.estrato, I.product_name, I.lugar, SUM(I.monto_total), P.distrito, P.departamento FROM inei_project AS I 
INNER JOIN peru_location AS P ON I.ubigeo = P.Ubigeo
GROUP BY I.estrato, I.product_name, I.lugar, P.distrito, P.departamento
HAVING SUM(I.monto_total) >= 500
ORDER BY SUM(I.monto_total) DESC
LIMIT 30;


SELECT COUNT(I.product_name) AS Top, I.product_name FROM inei_project AS I
INNER JOIN peru_location AS P ON I.ubigeo = P.Ubigeo
GROUP BY I.product_name
ORDER BY Top DESC
LIMIT 30;

SELECT COUNT(*) FROM inei_project;

SELECT COUNT(product_name)AS top, product_name FROM inei_project
GROUP BY product_name
ORDER BY top DESC;


SHOW TRIGGERS LIKE 'Recycle_Bin_table';



SELECT * FROM inei_project
WHERE tipo_pago <> 'Precio Normal' AND 'No Definido'
LIMIT 10;

SELECT COUNT(*), product_name FROM inei_project
group by product_name
LIMIT 20;

SELECT project_id, product_name FROM inei_project
WHERE product_name = ' UTO'
LIMIT 100;



CREATE VIEW top_20_places AS
	SELECT COUNT(ubigeo) AS numero, lugar
	FROM inei_project
	GROUP BY lugar
	ORDER BY numero DESC
	LIMIT 20
;



SELECT I.ubigeo, I.estrato, I.product_name, I.lugar, I.monto_total, U.distrito, U.provincia, U.departamento 
FROM inei_project AS I
INNER JOIN peru_location AS U ON I.ubigeo = U.ubigeo
WHERE I.monto_total BETWEEN 500 AND 1000 
AND U.departamento <> 'Callao'
LIMIT 10;


ALTER TABLE ubigeo_database RENAME peru_location;

CREATE INDEX inei_pro_lug_idx ON inei_project (product_name, lugar);
CREATE INDEX inei_dis_dep_idx ON ubigeo_database (Distrito, Departamento);




SELECT *
FROM inei_project
WHERE LENGTH(lugar) >= 140
LIMIT 100;

ALTER TABLE peru_location 
modify Distrito varchar(55);

ALTER TABLE peru_location DROP primary key;

ALTER TABLE peru_location ADD location_id int primary key auto_increment not null; 

ALTER TABLE inei_doject RENAME inei_project;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ubigeo-reniec(ubigeo_reniec).csv'
INTO TABLE ubigeo_database
FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

INSERT INTO temp_peru_location
(ubigeo, distrito, provincia, departamento, poblacion)
SELECT ubigeo, distrito, provincia, departamento, poblacion
FROM peru_location;

CREATE TABLE peru_location2 (
	location_id int primary key auto_increment not null,
	ubigeo varchar(55),
	distrito varchar(55), 
	provincia varchar(55), 
	departamento varchar(55), 
	poblacion int
);

DROP TABLE peru_location2;

ALTER TABLE inei_project RENAME COLUMN id TO project_id;

DELIMITER $$
CREATE TRIGGER Recycle_Bin_table
    BEFORE DELETE ON inei_project
    FOR EACH ROW
BEGIN
    INSERT INTO Recycle_Bin (recycle_bin_id, ubigeo, estrato, product_name, marca, lugar, monto_total) 
    VALUES (OLD.project_id, OLD.ubigeo, OLD.estrato, OLD.product_name, OLD.marca, OLD.lugar, OLD.monto_total);
END $$
DELIMITER ;




