-- Simplifica el catálogo conservando los 13 registros.
USE portal_empleo_inclusivo;
SET @columnas_discapacidades = (
    SELECT GROUP_CONCAT(CONCAT('DROP COLUMN `', COLUMN_NAME, '`') ORDER BY ORDINAL_POSITION SEPARATOR ', ')
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'discapacidades'
      AND COLUMN_NAME IN ('funcionalidades', 'implementacion', 'implementada')
);
SET @sql_discapacidades = IF(@columnas_discapacidades IS NULL,
    'SELECT ''La tabla ya tiene solo id_discapacidad, codigo y nombre'' AS resultado',
    CONCAT('ALTER TABLE discapacidades ', @columnas_discapacidades));
PREPARE simplificar_discapacidades FROM @sql_discapacidades;
EXECUTE simplificar_discapacidades;
DEALLOCATE PREPARE simplificar_discapacidades;
