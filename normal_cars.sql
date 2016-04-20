DROP USER IF EXISTS normal_user;

CREATE USER normal_user;

DROP DATABASE IF EXISTS normal_cars;

CREATE DATABASE normal_cars OWNER normal_user;


\c normal_cars;


DROP TABLE IF EXISTS manufacturers CASCADE;
DROP TABLE IF EXISTS models CASCADE;
DROP TABLE IF EXISTS years CASCADE;
DROP TABLE IF EXISTS car_models CASCADE;


\i './scripts/denormal_data.sql';
\d+;

-- Manufacturers table
CREATE TABLE manufacturers (
  id SERIAL PRIMARY KEY,
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
  id SERIAL PRIMARY KEY,
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


-- years table
CREATE TABLE years (
  id SERIAL PRIMARY KEY,
  year integer NOT NULL
);

INSERT INTO years (year)
  SELECT DISTINCT year FROM car_models
  ORDER BY year ASC;

-- car model years table
CREATE TABLE car_model_years (
  id SERIAL PRIMARY KEY,
  model integer REFERENCES models,
  year integer REFERENCES years
);

INSERT INTO car_model_years (model, year)
  WITH models2 AS (
    SELECT id, model_title, model_code
    FROM models
    ),
  years2 AS (
    SELECT id, year
    FROM years
    ),
  car_models3 AS (
    SELECT model_title, model_code, year
    FROM car_models
    )
SELECT DISTINCT models2.id , years2.id FROM models2, years2, car_models3
WHERE models2.model_title = car_models3.model_title
  AND models2.model_code = car_models3.model_code
  AND years2.year = car_models3.year;

-- In normal.sql Create a query to get a list of all make_title values in the car_models table. (should have 71 results
-- SELECT make_title FROM manufacturers;

-- In normal.sql Create a query to list all model_title values where the make_code is 'VOLKS' (should have 27 results)
-- SELECT model_title from models, manufacturers WHERE
--   manufacturers.make_code = 'VOLKS' AND
--   models.manufacturer = manufacturers.id;


-- In normal.sql Create a query to list all make_code, model_code, model_title, and year from car_models where the make_code is 'LAM' (should have 136 rows)

\timing
----Using CROSS JOINS

-- SELECT manufacturers.make_code, models.model_code, models.model_title, years.year
-- FROM car_model_years, models, years, manufacturers WHERE
--   car_model_years.model = models.id
--   AND  car_model_years.year = years.id
--   AND models.manufacturer = manufacturers.id
--   AND manufacturers.make_code = 'LAM';

----Using INNER JOINS

-- SELECT manufacturers.make_code, models.model_code, models.model_title, years.year
-- FROM manufacturers
-- INNER JOIN models
-- ON manufacturers.id = models.manufacturer
-- AND manufacturers.make_code = 'LAM'
-- INNER JOIN car_model_years
-- ON car_model_years.model = models.id
-- INNER JOIN years
-- ON car_model_years.year = years.id;


-- In normal.sql Create a query to list all fields from all car_models in years between 2010 and 2015 (should have 7884 rows)

----Using cross joins

-- SELECT manufacturers.make_title,
--        manufacturers.make_code,
--        models.model_title,
--        models.model_code,
--        years.year
-- FROM manufacturers,
--      models,
--      years,
--      car_model_years
-- WHERE car_model_years.model = models.id AND
--       manufacturers.id = models.manufacturer AND
--       car_model_years.year = years.id AND
--       years.year BETWEEN 2010 AND 2015

----Using inner joins

-- SELECT manufacturers.make_title,
--        manufacturers.make_code,
--        models.model_title,
--        models.model_code,
--        years.year
-- FROM manufacturers
-- INNER JOIN models
-- ON manufacturers.id = models.manufacturer
-- INNER JOIN car_model_years
-- ON models.id = car_model_years.model
-- INNER JOIN years
-- ON years.id = car_model_years.year
-- AND years.year BETWEEN 2010 AND 2015;