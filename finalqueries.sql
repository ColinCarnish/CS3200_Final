use boston_establishment_db;

-- Most commonly cited violation codes by neighborhood
SELECT 
    n.name AS neighborhood_name,
    vc.code AS violation_code,
    vc.description AS violation_description,
    COUNT(*) AS times_cited
FROM Violation v
JOIN Violation_Code vc ON v.code_id = vc.code_id
JOIN Inspection i ON v.inspection_id = i.inspection_id
JOIN License l ON i.license_id = l.license_id
JOIN Establishment e ON l.property_id = e.property_id
JOIN Neighborhood n ON e.neighborhood_id = n.neighborhood_id
GROUP BY n.name, vc.code, vc.description
ORDER BY n.name, times_cited DESC;

-- Establishments with most failed violations (*, **, *** level) 
SELECT 
    e.business_name,
    e.address,
    n.zip_code,
    COUNT(*) AS total_failed_violations
FROM Violation v
JOIN Violation_Code vc ON v.code_id = vc.code_id
JOIN Inspection i ON v.inspection_id = i.inspection_id
JOIN License l ON i.license_id = l.license_id
JOIN Establishment e ON l.property_id = e.property_id
JOIN Neighborhood n ON e.neighborhood_id = n.neighborhood_id
WHERE v.viol_status = 'Fail'
GROUP BY e.property_id, e.business_name, e.address, n.zip_code
ORDER BY total_failed_violations DESC
LIMIT 100;

-- Establishments with the most critical violations (*** level)
SELECT 
    e.business_name,
    e.address,
    n.name AS neighborhood,
    n.zip_code,
    COUNT(*) AS critical_violations
FROM Violation v
JOIN Violation_Code vc ON v.code_id = vc.code_id
JOIN Inspection i ON v.inspection_id = i.inspection_id
JOIN License l ON i.license_id = l.license_id
JOIN Establishment e ON l.property_id = e.property_id
JOIN Neighborhood n ON e.neighborhood_id = n.neighborhood_id
WHERE vc.viol_level = '***'
GROUP BY e.property_id, e.business_name, e.address, n.name, n.zip_code
HAVING COUNT(*) >= 3
ORDER BY critical_violations DESC
LIMIT 25;
