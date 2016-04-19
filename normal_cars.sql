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
  FROM car_models
  ORDER BY make_title;

-- SELECT * FROM manufacturers;

-- Models table
CREATE TABLE models (
  id SERIAL NOT NULL UNIQUE PRIMARY KEY,
  model_title varchar(125),
  model_code varchar(125),
  manufacturer integer REFERENCES manufacturers
);


INSERT INTO models (model_title, model_code, manufacturer)
  WITH car_models2 AS (
    SELECT DISTINCT
    model_title, model_code, make_title
    FROM car_models
    ORDER BY model_title ASC
  ),
  manufacturers AS (
    WITH new_car_models AS(
      SELECT DISTINCT model_title, model_code, make_title, make_code FROM
      car_models
      ORDER BY model_title ASC
      ),
    manufacturers2 AS(
      SELECT make_title, make_code, id
      FROM manufacturers
      )
    SELECT manufacturers2.id, manufacturers2.make_title
    FROM manufacturers2, new_car_models
    WHERE new_car_models.make_title = manufacturers2.make_title
      AND new_car_models.make_code = manufacturers2.make_code
  )
SELECT DISTINCT
car_models2.model_title, car_models2.model_code, manufacturers.id
FROM car_models2 JOIN manufacturers ON
car_models2.make_title = manufacturers.make_title;


SELECT * FROM models LIMIT 25;

-- -- years table
-- CREATE TABLE years (
--   id SERIAL NOT NULL UNIQUE PRIMARY KEY,
--   year integer NOT NULL
-- );

-- INSERT INTO years (year)
--   SELECT DISTINCT year FROM car_models
--   ORDER BY year ASC;

-- -- SELECT * FROM years;


