-- Non-destructive migration: explicit support declarations for phase 1.
USE portal_empleo_inclusivo;
SET @existe_apoyos = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema=DATABASE() AND table_name='ofertas' AND column_name='apoyos');
SET @sql_apoyos = IF(@existe_apoyos=0,
    'ALTER TABLE ofertas ADD COLUMN apoyos VARCHAR(512) NOT NULL DEFAULT ''''',
    'SELECT 1');
PREPARE stmt_apoyos FROM @sql_apoyos;
EXECUTE stmt_apoyos;
DEALLOCATE PREPARE stmt_apoyos;

-- Only annotate the original demonstration text, not arbitrary offers.
-- Exact matches avoid inventing support for user-authored or edited content.
UPDATE ofertas SET apoyos=CASE adaptaciones
    WHEN 'Horario flexible, lector de pantalla, reuniones grabadas' THEN 'lector,flexible'
    WHEN 'Rampa, ascensor, escritorio ergonomico' THEN 'rampas,ascensores'
    WHEN 'Lector de pantalla, horario flexible, reuniones con subtitulos' THEN 'lector,subtitulos,flexible'
    WHEN 'Trabajo remoto, comunicacion escrita, pausas sensoriales' THEN 'escrita'
    WHEN 'Ascensor, rutas accesibles, interprete LS previa coordinacion' THEN 'ascensores'
    WHEN 'Software lector, capacitacion inclusiva, horario flexible' THEN 'lector,flexible'
    WHEN 'Rampas, senalizacion clara, acompanamiento inicial' THEN 'rampas'
    WHEN 'Subtitulos, lector de pantalla, reuniones grabadas' THEN 'lector,subtitulos'
    ELSE apoyos END
WHERE apoyos='' AND @existe_apoyos=0;
