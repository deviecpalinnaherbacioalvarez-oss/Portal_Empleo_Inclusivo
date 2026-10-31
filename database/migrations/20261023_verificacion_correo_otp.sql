-- =====================================================================
-- MIGRACIÓN: Módulo de Verificación de Correo por Código OTP (One-Time Password)
-- IncluyeLab - Portal de Empleo Inclusivo
-- =====================================================================

USE portal_empleo_inclusivo;

-- 1. Asegurar columna correo_verificado en la tabla usuarios
SET @col_exists := (
    SELECT COUNT(*) 
    FROM information_schema.columns 
    WHERE table_schema = DATABASE() 
      AND table_name = 'usuarios' 
      AND column_name = 'correo_verificado'
);

SET @sql := IF(@col_exists = 0, 
    'ALTER TABLE usuarios ADD COLUMN correo_verificado TINYINT(1) NOT NULL DEFAULT 1 AFTER estado', 
    'SELECT 1'
);
PREPARE stmt FROM @sql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt;

-- 2. Crear tabla dedicada para el registro y auditoría de Códigos OTP
CREATE TABLE IF NOT EXISTS codigos_otp (
    id_otp INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    correo VARCHAR(150) NOT NULL,
    codigo VARCHAR(6) NOT NULL,
    tipo ENUM('VERIFICACION_CORREO', 'RECUPERACION_CLAVE', 'ACCESO_2FA') NOT NULL DEFAULT 'VERIFICACION_CORREO',
    intentos TINYINT NOT NULL DEFAULT 0,
    estado ENUM('PENDIENTE', 'VERIFICADO', 'EXPIRADO', 'BLOQUEADO') NOT NULL DEFAULT 'PENDIENTE',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion DATETIME NOT NULL,
    CONSTRAINT fk_otp_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_otp_usuario_tipo (id_usuario, tipo, estado),
    INDEX idx_otp_correo (correo, estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Asegurar que las cuentas demo existentes permanezcan verificadas
UPDATE usuarios SET correo_verificado = 1 WHERE correo_verificado = 0 AND id_usuario <= 15;
