USE boston_establishment_db;

-- top 10 most violations by neighborhood name and zipcode

SELECT 
    n.name AS neighborhood,
    n.zip_code,
    COUNT(v.violation_id) AS total_violations
FROM Violation v
JOIN Inspection i ON v.inspection_id = i.inspection_id
JOIN License l ON i.license_id = l.license_id
JOIN Establishment e ON l.property_id = e.property_id
JOIN Neighborhood n ON e.neighborhood_id = n.neighborhood_id
GROUP BY n.neighborhood_id, n.name, n.zip_code
ORDER BY total_violations DESC
LIMIT 10;

-- top 10 most inspections by neighborhood name and zipcode

SELECT
    n.name          AS neighborhood,
    n.zip_code,
    COUNT(i.inspection_id) AS total_inspections
FROM Inspection i
JOIN License l       ON i.license_id      = l.license_id
JOIN Establishment e ON l.property_id     = e.property_id
JOIN Neighborhood n  ON e.neighborhood_id = n.neighborhood_id
GROUP BY n.neighborhood_id, n.name, n.zip_code
ORDER BY total_inspections DESC
LIMIT 10;
