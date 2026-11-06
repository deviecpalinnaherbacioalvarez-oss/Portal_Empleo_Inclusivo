package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Usuario;
import com.incluyelab.security.Passwords;
import com.incluyelab.security.Roles;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {
    public static final class ResultadoLogin {
        public enum Estado { EXITO, INVALIDO, BLOQUEADO, TEMPORAL_EXPIRADA }
        private final Estado estado; private final Usuario usuario; private final int intentosRestantes; private final long segundosBloqueo;
        private ResultadoLogin(Estado estado,Usuario usuario,int intentosRestantes,long segundosBloqueo){this.estado=estado;this.usuario=usuario;this.intentosRestantes=intentosRestantes;this.segundosBloqueo=segundosBloqueo;}
        public static ResultadoLogin exito(Usuario usuario){return new ResultadoLogin(Estado.EXITO,usuario,3,0);}
        public static ResultadoLogin invalido(int restantes){return new ResultadoLogin(Estado.INVALIDO,null,restantes,0);}
        public static ResultadoLogin bloqueado(long segundos){return new ResultadoLogin(Estado.BLOQUEADO,null,0,segundos);}
        public static ResultadoLogin temporalExpirada(){return new ResultadoLogin(Estado.TEMPORAL_EXPIRADA,null,0,0);}
        public Estado getEstado(){return estado;} public Usuario getUsuario(){return usuario;} public int getIntentosRestantes(){return intentosRestantes;} public long getSegundosBloqueo(){return segundosBloqueo;}
    }
    public Usuario obtenerActivo(int id) throws SQLException {
        Usuario u = new Usuario();
        String sql = "SELECT id_usuario,nombre,correo,contrasena,rol,estado,requiere_cambio_clave,correo_verificado FROM usuarios WHERE id_usuario=? AND estado='activo'";
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                u.setIdUsuario(rs.getInt("id_usuario"));
                u.setNombre(rs.getString("nombre"));
                u.setCorreo(rs.getString("correo"));
                u.setRol(rs.getString("rol"));
                u.setEstado(rs.getString("estado"));
                u.setRequiereCambioClave(rs.getBoolean("requiere_cambio_clave"));
                try { u.setCorreoVerificado(rs.getBoolean("correo_verificado")); } catch (SQLException ignored) { u.setCorreoVerificado(true); }
                u.setCredencialVersion(Passwords.version(rs.getString("contrasena")));
            }
        }
        if ("POSTULANTE".equals(u.getRol())) {
            try {
                u.setConadisEstado(new VerificacionConadisDAO().estado(id));
            } catch (Exception ex) {
                u.setConadisEstado("SIN_ENVIAR");
            }
        } else {
            u.setConadisEstado("NO_APLICA");
        }
        return u;
    }

    public ResultadoLogin autenticar(String correo, String contrasena) throws SQLException {
        if(correo==null||contrasena==null||correo.length()>150||contrasena.length()>100)return ResultadoLogin.invalido(-1);
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try(PreparedStatement ps=cn.prepareStatement("SELECT id_usuario,nombre,correo,contrasena,rol,estado,requiere_cambio_clave,correo_verificado,intentos_fallidos,bloqueado_hasta,clave_temporal_expira,(bloqueado_hasta IS NOT NULL AND bloqueado_hasta>NOW()) bloqueado,GREATEST(0,TIMESTAMPDIFF(SECOND,NOW(),bloqueado_hasta)) segundos FROM usuarios WHERE correo=? FOR UPDATE")){
                ps.setString(1,correo.trim().toLowerCase());
                try(ResultSet rs=ps.executeQuery()){
                    if(!rs.next()||!"activo".equals(rs.getString("estado"))){cn.commit();return ResultadoLogin.invalido(-1);}
                    int id=rs.getInt("id_usuario");
                    if(rs.getBoolean("bloqueado")){long segundos=rs.getLong("segundos");cn.commit();return ResultadoLogin.bloqueado(Math.max(1,segundos));}
                    int intentos=rs.getTimestamp("bloqueado_hasta")!=null?0:rs.getInt("intentos_fallidos");
                    if(Passwords.matches(contrasena,rs.getString("contrasena"))){
                        Timestamp expira=rs.getTimestamp("clave_temporal_expira");
                        if(rs.getBoolean("requiere_cambio_clave")&&expira!=null&&!expira.after(new Timestamp(System.currentTimeMillis()))){cn.commit();return ResultadoLogin.temporalExpirada();}
                        try(PreparedStatement reset=cn.prepareStatement("UPDATE usuarios SET intentos_fallidos=0,bloqueado_hasta=NULL,motivo_bloqueo='' WHERE id_usuario=?")){reset.setInt(1,id);reset.executeUpdate();}
                        Usuario usuario=mapear(rs);cn.commit();return ResultadoLogin.exito(usuario);
                    }
                    intentos++;
                    if(intentos>=3){try(PreparedStatement lock=cn.prepareStatement("UPDATE usuarios SET intentos_fallidos=3,bloqueado_hasta=DATE_ADD(NOW(),INTERVAL 1 HOUR),motivo_bloqueo='Tres intentos fallidos consecutivos de inicio de sesión.' WHERE id_usuario=?")){lock.setInt(1,id);lock.executeUpdate();}try(PreparedStatement aviso=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) VALUES(?,'ACTIVIDAD_SOSPECHOSA','Cuenta bloqueada por seguridad','Detectamos tres intentos fallidos y bloqueamos temporalmente tu cuenta durante una hora.')")){aviso.setInt(1,id);aviso.executeUpdate();}cn.commit();return ResultadoLogin.bloqueado(3600);}
                    try(PreparedStatement fail=cn.prepareStatement("UPDATE usuarios SET intentos_fallidos=?,bloqueado_hasta=NULL WHERE id_usuario=?")){fail.setInt(1,intentos);fail.setInt(2,id);fail.executeUpdate();}
                    cn.commit();return ResultadoLogin.invalido(3-intentos);
                }
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}
        }
    }

    public int registrar(Usuario usuario) throws SQLException { return registrar(usuario,null,null,null); }
    public int registrar(Usuario usuario,String rui,String foto) throws SQLException { return registrar(usuario,rui,foto,null); }
    public int registrar(Usuario usuario,String rui,String foto,String ruc) throws SQLException {
        if (usuario == null || !Roles.esRegistroPublico(usuario.getRol())) {
            throw new IllegalArgumentException("El registro publico solo permite cuentas de postulante o empresa.");
        }
        Passwords.requireStrong(usuario.getContrasena());
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try{
                int id;
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO usuarios(nombre,correo,contrasena,rol,estado,correo_verificado) VALUES(?,?,?,?,?,0)",Statement.RETURN_GENERATED_KEYS)){
                    ps.setString(1,usuario.getNombre());ps.setString(2,usuario.getCorreo());
                    ps.setString(3,Passwords.hash(usuario.getContrasena()));ps.setString(4,usuario.getRol());ps.setString(5,"activo");ps.executeUpdate();
                    try(ResultSet rs=ps.getGeneratedKeys()){if(!rs.next())throw new SQLException("No se genero la cuenta");id=rs.getInt(1);}
                }
                if("EMPRESA".equals(usuario.getRol())){
                    // Sin RUC (llamadas antiguas) se conserva el marcador de ficha incompleta.
                    String rucEmpresa=ruc==null?"00000000000":ruc;
                    if(ruc!=null){
                        try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM empresas WHERE ruc=?")){
                            ps.setString(1,ruc);
                            try(ResultSet rs=ps.executeQuery()){if(rs.next())throw new IllegalArgumentException("Ese RUC ya pertenece a una empresa registrada. Ingresa con esa cuenta o revisa el número.");}
                        }
                    }
                    try(PreparedStatement ps=cn.prepareStatement("INSERT INTO empresas(id_usuario,razon_social,ruc,sector,sello_inclusivo,estado_revision) VALUES(?,?,?,'','Pendiente','pendiente')")){
                        ps.setInt(1,id);ps.setString(2,usuario.getNombre());ps.setString(3,rucEmpresa);ps.executeUpdate();
                    }
                }
                if("POSTULANTE".equals(usuario.getRol()))new VerificacionConadisDAO().enviarSolicitud(cn,id,rui,foto);
                cn.commit();return id;
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}
        }
    }

    public List<Usuario> listar() throws SQLException {
        List<Usuario> usuarios = new ArrayList<>();
        try (Connection cn = Conexion.getConnection();
             CallableStatement ps = cn.prepareCall("{CALL sp_usuario_listar()}");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                usuarios.add(mapearListado(rs));
            }
        }
        return usuarios;
    }

    public void cambiarContrasena(Usuario usuario, String actual, String nueva) throws SQLException {
        Passwords.requireStrong(nueva);
        try (Connection cn = Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = cn.prepareStatement("SELECT contrasena,rol,requiere_cambio_clave,clave_temporal_expira FROM usuarios WHERE id_usuario=? AND estado='activo' FOR UPDATE")) {
                    ps.setInt(1, usuario.getIdUsuario());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !usuario.getRol().equals(rs.getString("rol"))) {
                            throw new IllegalArgumentException("Tu acceso cambio. Inicia sesion nuevamente.");
                        }
                        String stored = rs.getString("contrasena");
                        Timestamp expira=rs.getTimestamp("clave_temporal_expira");
                        if(rs.getBoolean("requiere_cambio_clave")&&expira!=null&&!expira.after(new Timestamp(System.currentTimeMillis())))throw new IllegalArgumentException("La contraseña temporal venció. Solicita una nueva a Soporte Técnico.");
                        if (!Passwords.version(stored).equals(usuario.getCredencialVersion()) || !Passwords.matches(actual, stored)) {
                            throw new IllegalArgumentException("La contrasena actual no es correcta. No se realizaron cambios.");
                        }
                        if (Passwords.matches(nueva, stored)) {
                            throw new IllegalArgumentException("Elige una contrasena diferente a la actual.");
                        }
                    }
                }
                try (PreparedStatement ps = cn.prepareStatement("UPDATE usuarios SET contrasena=?,intentos_fallidos=0,bloqueado_hasta=NULL,motivo_bloqueo='',requiere_cambio_clave=0,clave_temporal_expira=NULL WHERE id_usuario=?")) {
                    ps.setString(1, Passwords.hash(nueva));
                    ps.setInt(2, usuario.getIdUsuario());
                    if (ps.executeUpdate() != 1) throw new SQLException("No se actualizo la cuenta");
                }
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) VALUES(?,'CLAVE_CAMBIADA','Contraseña actualizada','Tu contraseña fue cambiada correctamente. Si no realizaste esta acción, repórtala a Soporte Técnico.')")){ps.setInt(1,usuario.getIdUsuario());ps.executeUpdate();}
                cn.commit();
            } catch (SQLException | RuntimeException ex) { cn.rollback(); throw ex; }
        }
    }

    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setNombre(rs.getString("nombre"));
        u.setCorreo(rs.getString("correo"));
        u.setCredencialVersion(Passwords.version(rs.getString("contrasena")));
        u.setRol(rs.getString("rol"));
        u.setEstado(rs.getString("estado"));
        u.setRequiereCambioClave(rs.getBoolean("requiere_cambio_clave"));
        try { u.setCorreoVerificado(rs.getBoolean("correo_verificado")); } catch (SQLException ignored) { u.setCorreoVerificado(true); }
        return u;
    }

    private Usuario mapearListado(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setNombre(rs.getString("nombre"));
        u.setCorreo(rs.getString("correo"));
        u.setRol(rs.getString("rol"));
        u.setEstado(rs.getString("estado"));
        u.setRequiereCambioClave(rs.getBoolean("requiere_cambio_clave"));
        u.setCorreoVerificado(rs.getBoolean("correo_verificado"));
        return u;
    }
}
