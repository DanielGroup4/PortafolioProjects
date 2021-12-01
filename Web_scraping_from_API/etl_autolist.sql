DROP TABLE IF EXISTS autolist_volkswagen;

CREATE DATABASE IF NOT EXISTS autolist_volkswagen;

USE autolist_volkswagen;

DROP TABLE IF EXISTS cars_volkswagen_celaya;
CREATE TABLE cars_volkswagen_celaya
(
modelo VARCHAR(25) NOT NULL,
Kilometraje VARCHAR(25) NOT NULL,
anio INT NOT NULL,
distribuidor VARCHAR(250) NOT NULL,
precio FLOAT NOT NULL
);

SELECT *
FROM 
	cars_volkswagen_celaya;

    