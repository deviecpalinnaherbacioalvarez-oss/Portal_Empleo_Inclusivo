-- Parte 6: Web publica con JDBC.
-- Migracion idempotente: agrega columnas publicas de empresa, un indice para las consultas
-- publicas y traslada a MySQL los datos validos que estaban fijos en DirectorioEmpresas.java.
-- No elimina registros, no crea cuentas ficticias y puede ejecutarse varias veces sin duplicar.
USE portal_empleo_inclusivo;

-- 0) Verificacion previa (solo lectura): empresas existentes y su estado actual.
SELECT e.id_empresa, e.razon_social, e.estado_revision, u.estado AS estado_cuenta, e.logo_url
FROM empresas e JOIN usuarios u ON u.id_usuario = e.id_usuario
ORDER BY e.id_empresa;

-- 1) Columnas publicas (solo si no existen).
SET @col_sitio = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='sitio_oficial');
SET @ddl = IF(@col_sitio=0,
    'ALTER TABLE empresas ADD COLUMN sitio_oficial VARCHAR(500) NULL AFTER logo_url',
    'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_pais = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='pais');
SET @ddl = IF(@col_pais=0,
    'ALTER TABLE empresas ADD COLUMN pais VARCHAR(80) NOT NULL DEFAULT ''Peru'' AFTER sitio_oficial',
    'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2) Indice para listar/contar ofertas vigentes por estado, fecha y empresa.
SET @idx_publicas = (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema=DATABASE() AND table_name='ofertas' AND index_name='idx_ofertas_publicas');
SET @ddl = IF(@idx_publicas=0,
    'CREATE INDEX idx_ofertas_publicas ON ofertas(estado,fecha_publicacion,id_empresa)',
    'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3) Datos de DirectorioEmpresas.java (logo local, sitio oficial y ambito) para las marcas que
--    ya tienen una empresa registrada. Se usa una tabla temporal para no repetir valores.
--    Las marcas sin cuenta de empresa NO se insertan: eran referencias visuales, no empleadores.
DROP TEMPORARY TABLE IF EXISTS tmp_directorio_empresas;
CREATE TEMPORARY TABLE tmp_directorio_empresas (
    razon_social VARCHAR(150) PRIMARY KEY,
    logo_url VARCHAR(255) NOT NULL,
    sitio_oficial VARCHAR(500) NOT NULL,
    pais VARCHAR(80) NOT NULL
);
INSERT INTO tmp_directorio_empresas VALUES
    ('Microsoft','assets/logos/microsoft.png','https://www.microsoft.com/','Internacional'),
    ('BCP','assets/logos/bcp.svg','https://www.viabcp.com/','Peru'),
    ('Interbank','assets/logos/interbank.svg','https://interbank.pe/','Peru'),
    ('Alicorp','assets/logos/alicorp.png','https://www.alicorp.com.pe/','Peru'),
    ('Rimac Seguros','assets/logos/rimac.png','https://www.rimac.com/','Peru'),
    ('Entel Peru','assets/logos/entel.webp','https://www.entel.pe/','Peru'),
    ('Sodimac Peru','assets/logos/sodimac.png','https://www.sodimac.com.pe/','Peru'),
    ('Inkafarma','assets/logos/inkafarma.png','https://inkafarma.pe/','Peru'),
    ('Yape','assets/logos/yape.png','https://www.yape.com.pe/','Peru'),
    ('Claro','assets/logos/claro.png','https://www.claro.com.pe/','Peru'),
    ('Movistar','assets/logos/movistar.svg','https://www.movistar.com.pe/','Peru'),
    ('Tottus','assets/logos/tottus.png','https://www.tottus.com.pe/','Peru'),
    ('UPN','assets/logos/upn.svg','https://www.upn.edu.pe/','Peru'),
    ('UTP','assets/logos/utp.svg','https://www.utp.edu.pe/','Peru'),
    ('Mercado Libre','assets/logos/mercadolibre.png','https://www.mercadolibre.com.pe/','Peru'),
    ('Falabella','assets/logos/falabella.png','https://www.falabella.com.pe/','Peru'),
    ('Clínica Internacional','assets/logos/internacional.png','https://www.clinicainternacional.com.pe/','Peru'),
    ('Clínica San Pablo Surco','assets/logos/sanpablo.png','https://www.sanpablo.com.pe/','Peru'),
    ('Pardos Chicken','assets/logos/pardos.png','https://www.pardoschicken.pe/','Peru'),
    ('Amazon','assets/logos/amazon.png','https://www.aboutamazon.com/','Internacional'),
    ('Walmart','assets/logos/walmart.svg','https://corporate.walmart.com/','Internacional'),
    ('SAP','assets/logos/sap.svg','https://www.sap.com/','Internacional'),
    ('ACCIONA','assets/logos/acciona.jpg','https://www.acciona.com/es/','Internacional');

-- Solo completa valores vacios o el logo externo antiguo (logo.clearbit.com, servicio retirado);
-- no sobrescribe datos que la empresa o el administrador ya hayan personalizado.
UPDATE empresas e JOIN tmp_directorio_empresas d ON d.razon_social = e.razon_social
SET e.logo_url = CASE WHEN e.logo_url IS NULL OR e.logo_url = '' OR e.logo_url LIKE 'https://logo.clearbit.com/%'
                      THEN d.logo_url ELSE e.logo_url END,
    e.sitio_oficial = COALESCE(NULLIF(e.sitio_oficial, ''), d.sitio_oficial),
    e.pais = CASE WHEN e.pais = 'Peru' THEN d.pais ELSE e.pais END;

DROP TEMPORARY TABLE IF EXISTS tmp_directorio_empresas;

-- 4) Verificacion posterior (solo lectura).
SELECT id_empresa, razon_social, logo_url, sitio_oficial, pais FROM empresas ORDER BY id_empresa;
