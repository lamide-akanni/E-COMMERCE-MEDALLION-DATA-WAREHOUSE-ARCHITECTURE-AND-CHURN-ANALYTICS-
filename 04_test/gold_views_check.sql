SELECT
    o.name AS view_name,
    m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE s.name = 'gold' AND o.type = 'V'
ORDER BY o.name;
