USE portal_empleo_inclusivo;

SET @sql=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='intentos_fallidos')=0,
    'ALTER TABLE usuarios ADD COLUMN intentos_fallidos TINYINT UNSIGNED NOT NULL DEFAULT 0',
    'SELECT 1');
PREPARE seguridad_stmt FROM @sql; EXECUTE seguridad_stmt; DEALLOCATE PREPARE seguridad_stmt;

SET @sql=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='bloqueado_hasta')=0,
    'ALTER TABLE usuarios ADD COLUMN bloqueado_hasta DATETIME NULL',
    'SELECT 1');
PREPARE seguridad_stmt FROM @sql; EXECUTE seguridad_stmt; DEALLOCATE PREPARE seguridad_stmt;
