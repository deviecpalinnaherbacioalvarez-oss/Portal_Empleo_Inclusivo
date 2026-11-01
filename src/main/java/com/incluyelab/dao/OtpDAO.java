package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.security.Passwords;
import java.security.SecureRandom;
import java.sql.*;

public class OtpDAO {
    private static final SecureRandom RANDOM = new SecureRandom();

    public static class ResultadoOtp {
        private final boolean exito;
        private final String mensaje;

        private ResultadoOtp(boolean exito, String mensaje) {
            this.exito = exito;
            this.mensaje = mensaje;
        }

        public static ResultadoOtp exito() {
            return new ResultadoOtp(true, "Correo electrónico verificado correctamente.");
        }

        public static ResultadoOtp error(String mensaje) {
            return new ResultadoOtp(false, mensaje);
        }

        public boolean isExito() { return exito; }
        public String getMensaje() { return mensaje; }
    }

    /**
     * Genera un código OTP criptográficamente seguro de 6 dígitos, con vigencia de 15 minutos.
     */
    public String generarOtp(int idUsuario, String correo, String tipo) throws SQLException {
        if (tipo == null || tipo.trim().isEmpty()) tipo = "VERIFICACION_CORREO";
        int num = 100000 + RANDOM.nextInt(900000);
        String codigo = String.valueOf(num);

        try (Connection cn = Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                // Invalidar códigos pendientes anteriores del mismo tipo
                try (PreparedStatement ps = cn.prepareStatement(
                        "UPDATE codigos_otp SET estado='EXPIRADO' WHERE id_usuario=? AND tipo=? AND estado='PENDIENTE'")) {
                    ps.setInt(1, idUsuario);
                    ps.setString(2, tipo);
                    ps.executeUpdate();
                }

                // Insertar nuevo código OTP con expiración a 15 minutos
                try (PreparedStatement ps = cn.prepareStatement(
                        "INSERT INTO codigos_otp(id_usuario, correo, codigo, tipo, intentos, estado, fecha_expiracion) " +
                        "VALUES(?, ?, ?, ?, 0, 'PENDIENTE', DATE_ADD(NOW(), INTERVAL 15 MINUTE))")) {
                    ps.setInt(1, idUsuario);
                    ps.setString(2, correo.trim().toLowerCase());
                    ps.setString(3, Passwords.hash(codigo));
                    ps.setString(4, tipo);
                    ps.executeUpdate();
                }

                cn.commit();
                return codigo;
            } catch (SQLException | RuntimeException ex) {
                cn.rollback();
                throw ex;
            }
        }
    }

    /**
     * Valida el código OTP ingresado por el usuario con protección anti-fuerza bruta (máximo 5 intentos).
     */
    public ResultadoOtp verificarOtp(int idUsuario, String codigoIngresado) throws SQLException {
        if (codigoIngresado == null || !codigoIngresado.trim().matches("^[0-9]{6}$")) {
            return ResultadoOtp.error("Ingresa el código numérico completo de 6 dígitos.");
        }
        codigoIngresado = codigoIngresado.trim();

        try (Connection cn = Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                int idOtp;
                String codigoReal;
                int intentos;
                boolean expirado;

                try (PreparedStatement ps = cn.prepareStatement(
                        "SELECT id_otp, codigo, intentos, (NOW() > fecha_expiracion) AS expirado " +
                        "FROM codigos_otp WHERE id_usuario=? AND tipo='VERIFICACION_CORREO' AND estado='PENDIENTE' " +
                        "ORDER BY id_otp DESC LIMIT 1 FOR UPDATE")) {
                    ps.setInt(1, idUsuario);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            cn.commit();
                            return ResultadoOtp.error("No hay ningún código de verificación activo. Solicita un nuevo código.");
                        }
                        idOtp = rs.getInt("id_otp");
                        codigoReal = rs.getString("codigo");
                        intentos = rs.getInt("intentos");
                        expirado = rs.getBoolean("expirado");
                    }
                }

                if (expirado) {
                    try (PreparedStatement ps = cn.prepareStatement("UPDATE codigos_otp SET estado='EXPIRADO' WHERE id_otp=?")) {
                        ps.setInt(1, idOtp);
                        ps.executeUpdate();
                    }
                    cn.commit();
                    return ResultadoOtp.error("El código ha caducado (duración 15 min). Por favor presiona 'Reenviar código'.");
                }

                if (intentos >= 5) {
                    try (PreparedStatement ps = cn.prepareStatement("UPDATE codigos_otp SET estado='BLOQUEADO' WHERE id_otp=?")) {
                        ps.setInt(1, idOtp);
                        ps.executeUpdate();
                    }
                    cn.commit();
                    return ResultadoOtp.error("Has superado el límite de intentos fallidos. Solicita un nuevo código OTP.");
                }

                if (!Passwords.matches(codigoIngresado, codigoReal)) {
                    int nuevosIntentos = intentos + 1;
                    String nuevoEstado = nuevosIntentos >= 5 ? "BLOQUEADO" : "PENDIENTE";
                    try (PreparedStatement ps = cn.prepareStatement("UPDATE codigos_otp SET intentos=?, estado=? WHERE id_otp=?")) {
                        ps.setInt(1, nuevosIntentos);
                        ps.setString(2, nuevoEstado);
                        ps.setInt(3, idOtp);
                        ps.executeUpdate();
                    }
                    cn.commit();
                    int restantes = Math.max(0, 5 - nuevosIntentos);
                    return ResultadoOtp.error("Código OTP incorrecto." + (restantes > 0 ? " Te quedan " + restantes + " intentos." : " Se ha bloqueado este código; solicita uno nuevo."));
                }

                // Código correcto: marcar como VERIFICADO y actualizar usuario
                try (PreparedStatement ps = cn.prepareStatement("UPDATE codigos_otp SET estado='VERIFICADO' WHERE id_otp=?")) {
                    ps.setInt(1, idOtp);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = cn.prepareStatement("UPDATE usuarios SET correo_verificado=1 WHERE id_usuario=?")) {
                    ps.setInt(1, idUsuario);
                    ps.executeUpdate();
                }

                cn.commit();
                return ResultadoOtp.exito();
            } catch (SQLException | RuntimeException ex) {
                cn.rollback();
                throw ex;
            }
        }
    }

    public boolean existeOtpPendiente(int idUsuario, String tipo) throws SQLException {
        if (tipo == null || tipo.trim().isEmpty()) tipo = "VERIFICACION_CORREO";
        String sql = "SELECT 1 FROM codigos_otp WHERE id_usuario=? AND tipo=? AND estado='PENDIENTE' AND NOW() <= fecha_expiracion ORDER BY id_otp DESC LIMIT 1";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setString(2, tipo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
