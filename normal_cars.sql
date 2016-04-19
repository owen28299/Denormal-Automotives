DROP USER IF EXISTS normal_user;

CREATE USER normal_user;

DROP DATABASE IF EXISTS normal_cars;

CREATE DATABASE normal_cars OWNER normal_user;


\c denormal_cars;


DROP TABLE IF EXISTS manufacturers CASCADE;
DROP TABLE IF EXISTS models CASCADE;
DROP TABLE IF EXISTS years CASCADE;
DROP TABLE IF EXISTS car_models CASCADE;


\i './scripts/denormal_data.sql';
\d+;

-- Manufacturers table
CREATE TABLE manufacturers (
  id SERIAL NOT NULL UNIQUE PRIMARY KEY,
  make_title varchar(125),
  make_code varchar(125)
);

INSERT INTO manufacturers (make_title, make_code)
  SELECT DISTINCT make_title, make_code
  FROM car_models;

-- Models table
CREATE TABLE models (
  id SERIAL NOT NULL UNIQUE PRIMARY KEY,
  model_title varchar(125),
  model_code varchar(125),
  manufacturer integer REFERENCES manufacturers,
  make_title varchar(125),
  make_code varchar(125)
);

INSERT INTO models (model_title, model_code, make_title, make_code)
  SELECT DISTINCT model_title, model_code, make_title, make_code
  FROM car_models;

SELECT manufacturers.id
FROM manufacturers, models
WHERE models.make_title = manufacturers.make_title;

SELECT * FROM models;

-- -- years table
-- CREATE TABLE years (
--   id SERIAL NOT NULL UNIQUE PRIMARY KEY,
--   year integer NOT NULL
-- );

-- INSERT INTO years (year)
--   SELECT DISTINCT year FROM car_models
--   ORDER BY year ASC;

-- -- SELECT * FROM years;


