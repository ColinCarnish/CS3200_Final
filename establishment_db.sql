DROP DATABASE IF EXISTS boston_establishment_db;
CREATE DATABASE boston_establishment_db;
USE boston_establishment_db;
 
CREATE TABLE Neighborhood (
  neighborhood_id   INT           AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(100)  NOT NULL,       
  zip_code          CHAR(5)       NOT NULL,
  UNIQUE (zip_code)
);
 
 CREATE TABLE Establishment (
  property_id       INT           PRIMARY KEY,
  business_name     VARCHAR(255)  NOT NULL,
  dba_name          VARCHAR(255),
  address           VARCHAR(255)  NOT NULL,
  neighborhood_id   INT           NOT NULL,
  latitude          DECIMAL(9,6),
  longitude         DECIMAL(9,6),
  phone             VARCHAR(20),
  FOREIGN KEY (neighborhood_id) REFERENCES Neighborhood(neighborhood_id)
);
 
CREATE TABLE License (
  license_id        INT           AUTO_INCREMENT PRIMARY KEY,
  property_id       INT           NOT NULL,                      
  licenseno         VARCHAR(50),                  
  license_status    VARCHAR(50)   NOT NULL,       
  license_cat       VARCHAR(10),                 
  description       VARCHAR(255),                
  issued_date       DATETIME,
  expiry_date       DATETIME,
  FOREIGN KEY (property_id) REFERENCES Establishment(property_id)
);
 
CREATE TABLE Inspection (
  inspection_id     INT           AUTO_INCREMENT PRIMARY KEY,
  license_id        INT           NOT NULL,      
  inspection_date   DATETIME      NOT NULL,       
  result            VARCHAR(50)   NOT NULL,       
  FOREIGN KEY (license_id) REFERENCES License(license_id)
);
 
CREATE TABLE Violation_Code (
  code_id           INT           AUTO_INCREMENT PRIMARY KEY,
  code              VARCHAR(50)   NOT NULL UNIQUE,
  description       VARCHAR(255)  NOT NULL,     
  viol_level        ENUM('*','**','***') NOT NULL
);
 
CREATE TABLE Violation (
  violation_id      INT           AUTO_INCREMENT PRIMARY KEY,
  inspection_id     INT           NOT NULL,
  code_id           INT           NOT NULL,
  viol_status       VARCHAR(20),              
  status_date       DATETIME,                     
  comments          TEXT,                
  FOREIGN KEY (inspection_id) REFERENCES Inspection(inspection_id),
  FOREIGN KEY (code_id)       REFERENCES Violation_Code(code_id)
);

-- Establishments --
 
CREATE TABLE stage_establishments (
  businessname        TEXT,
  dbaname             TEXT,
  address             TEXT,
  city                TEXT,
  state               TEXT,
  zip                 VARCHAR(10),
  licstatus           TEXT,
  licensecat          TEXT,
  descript            TEXT,
  license_add_dt_tm   TEXT,
  dayphn_cleaned      TEXT,
  property_id         INT,
  latitude            FLOAT,
  longitude           FLOAT
);
 
LOAD DATA LOCAL
INFILE '/Users/cccar/Downloads/tmprvm4igho.csv'
INTO TABLE stage_establishments
FIELDS TERMINATED BY ','  OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;
 
INSERT IGNORE INTO Neighborhood (name, zip_code)
SELECT DISTINCT
  TRIM(city),
  LPAD(TRIM(zip), 5, '0')
FROM stage_establishments
WHERE zip IS NOT NULL AND TRIM(zip) != '' AND TRIM(zip) != '0';
 
INSERT IGNORE INTO Establishment
  (property_id, business_name, dba_name, address, neighborhood_id, latitude, longitude, phone)
SELECT
  s.property_id,
  TRIM(s.businessname),
  NULLIF(TRIM(s.dbaname), ''),
  TRIM(s.address),
  n.neighborhood_id,
  NULLIF(s.latitude, 0),
  NULLIF(s.longitude, 0),
  NULLIF(TRIM(s.dayphn_cleaned), '')
FROM stage_establishments s
JOIN Neighborhood n ON LPAD(TRIM(s.zip), 5, '0') = n.zip_code
WHERE s.property_id IS NOT NULL AND s.property_id != 0;
 
INSERT INTO License
  (property_id, license_status, license_cat, description, issued_date)
SELECT
  property_id,
  TRIM(licstatus),
  TRIM(licensecat),
  TRIM(descript),
  STR_TO_DATE(SUBSTRING(license_add_dt_tm, 1, 19), '%Y-%m-%d %H:%i:%s')
FROM stage_establishments
WHERE property_id IS NOT NULL AND property_id != 0;
 
DROP TABLE stage_establishments;

-- Violations --

CREATE TABLE stage_violations (
  licenseno     VARCHAR(50),
  expdttm       TEXT,
  result        TEXT,
  resultdttm    TEXT,
  violation     TEXT,
  viol_level    TEXT,
  violdesc      TEXT,
  viol_status   TEXT,
  status_date   TEXT,
  comments      TEXT,
  property_id   INT
);

LOAD DATA LOCAL
INFILE '/Users/cccar/Downloads/food_inspections_cleaned.csv'
INTO TABLE stage_violations
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(@businessname, @dbaname, @legalowner, @namelast, @namefirst,
 licenseno, @issdttm, expdttm, @licstatus, @licensecat, @descript,
 result, resultdttm, violation, viol_level, violdesc, @violdttm,
 viol_status, status_date, comments, @address, @city, @state,
 @zip, property_id, @location);

UPDATE License l
JOIN stage_violations s ON l.property_id = s.property_id
SET
  l.licenseno   = NULLIF(TRIM(s.licenseno), ''),
  l.expiry_date = CASE
    WHEN TRIM(s.expdttm) = '' OR s.expdttm IS NULL THEN NULL
    ELSE STR_TO_DATE(SUBSTRING(s.expdttm, 1, 19), '%Y-%m-%d %H:%i:%s')
  END
WHERE l.licenseno IS NULL;

INSERT IGNORE INTO Violation_Code (code, description, viol_level)
SELECT DISTINCT
  TRIM(violation),
  TRIM(violdesc),
  TRIM(viol_level)
FROM stage_violations
WHERE TRIM(violation) != '' AND TRIM(viol_level) IN ('*','**','***');

INSERT IGNORE INTO Inspection (license_id, inspection_date, result)
SELECT DISTINCT
  l.license_id,
  STR_TO_DATE(SUBSTRING(s.resultdttm, 1, 19), '%Y-%m-%d %H:%i:%s'),
  TRIM(s.result)
FROM stage_violations s
JOIN License l ON l.property_id = s.property_id
WHERE TRIM(s.resultdttm) != '' AND s.resultdttm IS NOT NULL;

INSERT INTO Violation (inspection_id, code_id, viol_status, status_date, comments)
SELECT
  i.inspection_id,
  vc.code_id,
  NULLIF(TRIM(s.viol_status), ''),
  CASE
    WHEN TRIM(s.status_date) = '' OR s.status_date IS NULL THEN NULL
    ELSE STR_TO_DATE(SUBSTRING(s.status_date, 1, 19), '%Y-%m-%d %H:%i:%s')
  END,
  NULLIF(TRIM(s.comments), '')
FROM stage_violations s
JOIN License l ON l.licenseno = TRIM(s.licenseno)
JOIN Inspection i ON
  i.license_id = l.license_id AND
  i.inspection_date = CASE
    WHEN TRIM(s.resultdttm) = '' OR s.resultdttm IS NULL THEN NULL
    ELSE STR_TO_DATE(SUBSTRING(s.resultdttm, 1, 19), '%Y-%m-%d %H:%i:%s')
  END
JOIN Violation_Code vc ON vc.code = TRIM(s.violation)
WHERE TRIM(s.violation) != '';

DROP TABLE stage_violations;

SELECT 'Neighborhood'   AS tbl, COUNT(*) AS n FROM Neighborhood
UNION ALL
SELECT 'Establishment',  COUNT(*) FROM Establishment
UNION ALL
SELECT 'License',        COUNT(*) FROM License
UNION ALL
SELECT 'Inspection',     COUNT(*) FROM Inspection
UNION ALL
SELECT 'Violation_Code', COUNT(*) FROM Violation_Code
UNION ALL
SELECT 'Violation',      COUNT(*) FROM Violation;

