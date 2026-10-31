USE portal_empleo_inclusivo;

-- Cuentas academicas de las empresas que tienen al menos una oferta publicada.
-- Clave comun de demostracion: Empresa#2026
UPDATE usuarios u
SET u.contrasena = CASE LOWER(u.correo)
    WHEN 'empresa@incluyelab.pe' THEN 'pbkdf2$600000$qrtkZkdmeXoyvfsp0/hG7A==$7Lef4LXBWSF8i9pk3Q9O19cfhbnOw5u8g8M62+bJDBA='
    WHEN 'talento@bcp.com.pe' THEN 'pbkdf2$600000$r11xuXBz+nprNhnSlE3slg==$xDjqHQ2B7nZUeRgwMvFAc0XPFg7XCjgMC57f+z8sPPo='
    WHEN 'empleos@interbank.pe' THEN 'pbkdf2$600000$ZBNa8p+2Z5/ZApyx5y0KHw==$7sBamU60mP5Vty/mzHCucmCjt/75stNPaDEJ+io25rU='
    WHEN 'personas@alicorp.com.pe' THEN 'pbkdf2$600000$LDiQTNMG7YrYbUscB8d+ZQ==$8qKrxCRztQS/VDpP6sLOISgSz/u4fFv5FqrWo63Ucr0='
    WHEN 'inclusion@rimac.com' THEN 'pbkdf2$600000$iY/9qfKS6jgFpVX9jQuCrQ==$0YD6ToFxdSUFzlsxHFeZP1AIHHFdHJdr9n8Xm2EXzCA='
    WHEN 'talento@entel.pe' THEN 'pbkdf2$600000$MXQp3N5+HTHRxAYXyZ/79w==$bZB+QSoqXy2D2ZAbD0Nb2ho5OEXfvkcUPZY/Eo0/AbQ='
    WHEN 'empleos@sodimac.com.pe' THEN 'pbkdf2$600000$DvhUHGAVyJXv7G3lJZLWBQ==$3HljT9FiyPetaFp6FYvMiLxoB+LLSS4vgat+bR6NYzQ='
    WHEN 'trabaja@inkafarma.pe' THEN 'pbkdf2$600000$XYsX8xqH4zJ1K/hTOxBchg==$eHPJVJOsmJGvoJIJTLXgHYN+EoC9pGRUKHIHo4RJcHI='
    WHEN 'talento@yape.com.pe' THEN 'pbkdf2$600000$DCa7bH93rSbpoS/cwhzqGg==$mrCuLmiPaOBIM19bDMd0sP1kGOMdSl+uPdxOgvLRZXI='
    ELSE u.contrasena
END,
u.estado = 'activo',
u.intentos_fallidos = 0,
u.bloqueado_hasta = NULL
WHERE u.rol = 'EMPRESA'
  AND LOWER(u.correo) IN (
    'empresa@incluyelab.pe', 'talento@bcp.com.pe', 'empleos@interbank.pe',
    'personas@alicorp.com.pe', 'inclusion@rimac.com', 'talento@entel.pe',
    'empleos@sodimac.com.pe', 'trabaja@inkafarma.pe', 'talento@yape.com.pe'
  )
  AND EXISTS (
    SELECT 1 FROM empresas e
    JOIN ofertas o ON o.id_empresa = e.id_empresa
    WHERE e.id_usuario = u.id_usuario
  );
