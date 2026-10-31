-- Replace only the original fictional seed, preserving its ID, offers and login.
-- Microsoft is a reference brand; this is NOT a real Microsoft employer account.
USE portal_empleo_inclusivo;
START TRANSACTION;
UPDATE usuarios u INNER JOIN empresas e ON e.id_usuario=u.id_usuario
SET u.nombre='Microsoft (cuenta demo)'
WHERE e.id_empresa=1 AND e.razon_social='TechForGood Peru'
  AND u.correo='empresa@incluyelab.pe' AND u.nombre='TechForGood Peru';
UPDATE empresas e INNER JOIN usuarios u ON u.id_usuario=e.id_usuario
SET e.razon_social='Microsoft',e.logo_url='assets/logos/microsoft.png',
    e.ruc='00000000000',e.sello_inclusivo='Pendiente'
WHERE e.id_empresa=1 AND e.razon_social='TechForGood Peru' AND u.correo='empresa@incluyelab.pe';
COMMIT;
