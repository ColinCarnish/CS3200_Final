use boston_establishment_db;

select * from Violation_Code;
select * from Violation;

SELECT *
FROM Establishment e
WHERE e.business_name LIKE "%potluck%";

SELECT *
FROM Establishment e
JOIN License l
  ON e.property_id = l.property_id
JOIN Inspection i 
  ON i.license_id = l.license_id
WHERE e.business_name LIKE "%yume%";

SELECT count(*)
FROM Establishment e
JOIN License l
  ON e.property_id = l.property_id
JOIN Inspection i 
  ON i.license_id = l.license_id
WHERE e.business_name = "WHOLE FOODS MARKET" and result = 'HE_Fail';

select count(*) from Inspection i where (i.result = 'HE_Fail' or i.result = 'HE_FailExt');
select count(*) from Inspection;

SELECT 
  e.business_name, COUNT(v.violation_id) * 1.0 / COUNT(DISTINCT i.inspection_id) AS violations_per_inspection
FROM Establishment e
JOIN License l
  ON e.property_id = l.property_id
JOIN Inspection i 
  ON i.license_id = l.license_id
LEFT JOIN Violation v
  ON v.inspection_id = i.inspection_id
GROUP BY e.business_name
ORDER BY violations_per_inspection desc
limit 15;
# 'Brighton Sushi and Fry', '16.00000'
# 'Holly Crab', '15.66667'
# 'Bell In Hand', '13.22222'
# 'ZHU', '13.00000'
# 'LIMONCELLO', '12.53846'
# 'Jiang Nan', '12.25000'
# 'Halal Indian Cuisine', '12.22222'
# 'Giacomo\'s Ristorante', '12.22222'
# 'Dans Mini Dogs', '12.06061'
# 'BOSTON SAIL LOFT', '12.00000'



SELECT 
vc.code,
  COUNT(*) AS violation_count
FROM Violation v
JOIN Inspection i on v.inspection_id = i.inspection_id
JOIN Violation_Code vc on v.code_id = vc.code_id
GROUP BY vc.code
ORDER BY violation_count desc
limit 10;

# '590.004/4-602.13-C', '3391'
# '590.006/6-501.111-PF', '2727'
# '590.006/6-201.11-C', '2398'
# '590.006/6-501.14-C', '2085'
# '590.004/4-601.11-PF', '2078'
# '590.003/3-501.16-P', '1838'
# '590.003/3-302.12-C', '1790'
# '590.005/5-205.15-C', '1721'
# '590.006/6-501.11-C', '1710'
# '590.003/3-304.14-C', '1551'