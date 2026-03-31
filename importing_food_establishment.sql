-- J. Rachlin
-- Database Design
-- Importing data into MySQL

-- You can use the Table Data Import Wizard, but a faster, better, more reliable approach
-- is to IMPORT .csv files directly into targetted tables. 

-- Run these steps one at a time while connected to the server as ROOT
-- Only ROOT has the right to create new databases.

-- Step 1. Configure the server to allow data to be imported 
--  from anywhere on your local file system

show variables;
show variables where variable_name like '%local%';
set global local_infile=ON;

-- Step 2. Configure the MySQL client to also process
-- locally imported files. To do this:
-- a) Close this connection. Edit your root connection.
-- b) Under the advanced tab add the line OPT_LOCAL_INFILE=1
-- c) Reopen the root connection


-- Step 3. Create the database
DROP DATABASE IF EXISTS food_establishments;
CREATE DATABASE food_establishments;

-- Step 4. Make disgenet the active database
USE food_establishments;


-- Step 5. Create a table schema to hold the data

CREATE TABLE food_establishments (
  businessname text, 
  dbaname text,
  address text,
  city text,
  state text, 
  zip int,
  licstatus text,
  descript text,
  license_add_dt_tm text,
  dayph_cleaned text,
  property_id int,
  latitude float,
  longitude float
);

truncate food_establishments;
LOAD DATA LOCAL 
INFILE '/Users/jakewu-chen/Projects/classes/CS3200/CS3200_Final/food_establishments.csv' -- Windows users:  'C:\\Users\\rachlin\\path\\to\\disgenet\\disgenet.csv'
INTO TABLE food_establishments
FIELDS TERMINATED BY ','  OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;
