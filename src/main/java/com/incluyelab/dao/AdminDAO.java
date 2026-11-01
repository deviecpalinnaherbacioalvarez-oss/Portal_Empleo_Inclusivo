package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.security.Passwords;
import com.incluyelab.security.Roles;
import java.sql.*;
import java.math.BigDecimal;
import java.util.Map;

/** Administrative writes share a transaction to preserve linked accounts and records. */
public class AdminDAO {
    public boolean esAdministradorActivo(int id) throws SQLException {
        try (Connection cn = Conexion.getConnection()) {
            return exists(cn, "SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='ADMIN' AND estado='activo'", id);
        }
    }

    public void guardar(String entidad, int id, Map<String, String> v, int actor) throws SQLException {
        if ("empresas".equals(entidad)) throw new IllegalArgumentException("Utiliza la revision de empresas.");
        try (Connection cn = Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                autorizar(cn, actor);
                if (id > 0) bloquear(cn, entidad, id);
                switch (entidad) {
                    case "usuarios": guardarUsuario(cn, id, v, actor); break;
                    case "empresas": throw new IllegalArgumentException("Las empresas se registran y se revisan en Solicitudes.");
                    case "ofertas": guardarOferta(cn, id, v); break;
                    case "postulaciones": guardarPostulacion(cn, id, v); break;
                    default: throw new IllegalArgumentException("Seccion no valida.");
                }
                cn.commit();
            } catch (SQLException | RuntimeException ex) { cn.rollback(); throw ex; }
        }
    }

    public void eliminar(String entidad, int id, int actor) throws SQLException {
        if ("empresas".equals(entidad)) throw new IllegalArgumentException("Utiliza la revision de empresas.");
        try (Connection cn = Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                autorizar(cn, actor);
                bloquear(cn, entidad, id);
                if ("usuarios".equals(entidad) && id == actor) throw new IllegalArgumentException("No puedes eliminar tu propia cuenta.");
                // Foreign keys deliberately prevent deleting records with dependent history.
                ejecutar(cn, "DELETE FROM " + tabla(entidad) + " WHERE " + clave(entidad) + "=?", id);
                cn.commit();
            } catch (SQLException | RuntimeException ex) { cn.rollback(); throw ex; }
        }
    }

    public void darBaja(int id,int actor)throws SQLException {
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{autorizar(cn,actor);if(id==actor)throw new IllegalArgumentException("No puedes desactivar tu propia cuenta.");try(PreparedStatement ps=cn.prepareStatement("UPDATE usuarios SET estado='inactivo',bloqueado_hasta=NULL WHERE id_usuario=? AND estado='activo'")){ps.setInt(1,id);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("La cuenta ya está inactiva o no existe.");}cn.commit();}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    private void guardarUsuario(Connection cn, int id, Map<String, String> v, int actor) throws SQLException {
        String rol = v.get("rol");
        if (!Roles.esValido(rol)) throw new IllegalArgumentException("Rol no autorizado.");
        if (id == 0 && !Roles.esInterno(rol))
            throw new IllegalArgumentException("El Administrador Central solo puede crear cuentas internas.");
        if (id == actor && (!"ADMIN".equals(rol) || !"activo".equals(v.get("estado")))) {
            throw new IllegalArgumentException("Tu propia cuenta debe conservar el rol Administrador y el estado activo.");
        }
        if (id > 0) {
            String rolActual;
            try (PreparedStatement ps=cn.prepareStatement("SELECT rol FROM usuarios WHERE id_usuario=? FOR UPDATE")) {
                ps.setInt(1,id);
                try (ResultSet rs=ps.executeQuery()) {
                    if(!rs.next()) throw new IllegalArgumentException("La cuenta ya no existe.");
                    rolActual=rs.getString(1);
                }
            }
            if (Roles.EMPRESA.equals(rolActual))
                throw new IllegalArgumentException("Las cuentas empresariales son administradas por sus representantes.");
            if (Roles.POSTULANTE.equals(rolActual) && !Roles.POSTULANTE.equals(rol))
                throw new IllegalArgumentException("El rol Postulante no puede modificarse desde Administracion.");
            if (Roles.esInterno(rolActual) && !Roles.esInterno(rol))
                throw new IllegalArgumentException("Una cuenta interna solo puede recibir otro rol interno autorizado.");
            if (id == actor && !rolActual.equals(rol))
                throw new IllegalArgumentException("No puedes modificar tu propio rol.");
            ejecutar(cn,"UPDATE usuarios SET nombre=?,correo=?,rol=?,estado=? WHERE id_usuario=?",v.get("nombre"),v.get("correo"),rol,v.get("estado"),id);
            if (!v.get("contrasena").isEmpty()) ejecutar(cn,"UPDATE usuarios SET contrasena=?,intentos_fallidos=0,bloqueado_hasta=NULL WHERE id_usuario=?",Passwords.hash(v.get("contrasena")),id);
        } else {
            id = insertar(cn,"INSERT INTO usuarios(nombre,correo,contrasena,rol,estado) VALUES(?,?,?,?,?)",v.get("nombre"),v.get("correo"),Passwords.hash(v.get("contrasena")),rol,v.get("estado"));
        }
    }

    private void guardarOferta(Connection cn, int id, Map<String, String> v) throws SQLException {
        int empresa = Integer.parseInt(v.get("idEmpresa"));
        if (!exists(cn,"SELECT 1 FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE e.id_empresa=? AND u.rol='EMPRESA' AND u.estado='activo' AND e.estado_revision='aprobada'",empresa))
            throw new IllegalArgumentException("Selecciona una empresa aprobada y activa.");
        BigDecimal salario = new BigDecimal(v.get("salario"));
        if (id == 0) ejecutar(cn,"INSERT INTO ofertas(id_empresa,titulo,modalidad,ubicacion,adaptaciones,descripcion,salario,estado,apoyos) VALUES(?,?,?,?,?,?,?,?,?)",empresa,v.get("titulo"),v.get("modalidad"),v.get("ubicacion"),v.get("adaptaciones"),v.get("descripcion"),salario,v.get("estado"),v.get("apoyos"));
        else ejecutar(cn,"UPDATE ofertas SET id_empresa=?,titulo=?,modalidad=?,ubicacion=?,adaptaciones=?,descripcion=?,salario=?,estado=?,apoyos=? WHERE id_oferta=?",empresa,v.get("titulo"),v.get("modalidad"),v.get("ubicacion"),v.get("adaptaciones"),v.get("descripcion"),salario,v.get("estado"),v.get("apoyos"),id);
    }

    private void guardarPostulacion(Connection cn, int id, Map<String, String> v) throws SQLException {
        if (id > 0) {
            ejecutar(cn,"UPDATE postulaciones SET estado=? WHERE id_postulacion=?",v.get("estado"),id);
            return;
        }
        int usuario = Integer.parseInt(v.get("idUsuario")), oferta = Integer.parseInt(v.get("idOferta"));
        if (!exists(cn,"SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='POSTULANTE' AND estado='activo' FOR UPDATE",usuario))
            throw new IllegalArgumentException("Selecciona un postulante activo.");
        if (!exists(cn,"SELECT 1 FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE o.id_oferta=? AND o.estado='activa' AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA' FOR UPDATE",oferta))
            throw new IllegalArgumentException("Selecciona una oferta activa.");
        if (exists(cn,"SELECT 1 FROM postulaciones WHERE id_usuario=? AND id_oferta=?",usuario,oferta))
            throw new IllegalArgumentException("El usuario ya postulo a esta oferta.");
        ejecutar(cn,"INSERT INTO postulaciones(id_usuario,id_oferta,estado) VALUES(?,?,?)",usuario,oferta,v.get("estado"));
    }

    private void autorizar(Connection cn, int actor) throws SQLException {
        if (!exists(cn,"SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='ADMIN' AND estado='activo' FOR UPDATE",actor))
            throw new IllegalArgumentException("La cuenta ya no tiene acceso administrativo.");
    }
    private void bloquear(Connection cn, String entidad, int id) throws SQLException {
        if (!exists(cn,"SELECT 1 FROM " + tabla(entidad) + " WHERE " + clave(entidad) + "=? FOR UPDATE",id))
            throw new IllegalArgumentException("El registro ya no existe. Actualiza el listado.");
    }
    private String tabla(String entidad) {
        switch (entidad) { case "usuarios": case "empresas": case "ofertas": case "postulaciones": return entidad;
            default: throw new IllegalArgumentException("Seccion no valida."); }
    }
    private String clave(String entidad) {
        switch (entidad) { case "usuarios": return "id_usuario"; case "empresas": return "id_empresa";
            case "ofertas": return "id_oferta"; case "postulaciones": return "id_postulacion";
            default: throw new IllegalArgumentException("Seccion no valida."); }
    }
    private void parametros(PreparedStatement ps, Object... values) throws SQLException {
        for (int i=0;i<values.length;i++) ps.setObject(i+1,values[i]);
    }
    private boolean exists(Connection cn, String sql, Object... values) throws SQLException {
        try (PreparedStatement ps=cn.prepareStatement(sql)) { parametros(ps,values); try(ResultSet rs=ps.executeQuery()) { return rs.next(); } }
    }
    private void ejecutar(Connection cn, String sql, Object... values) throws SQLException {
        try (PreparedStatement ps=cn.prepareStatement(sql)) { parametros(ps,values); ps.executeUpdate(); }
    }
    private int insertar(Connection cn, String sql, Object... values) throws SQLException {
        try (PreparedStatement ps=cn.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)) {
            parametros(ps,values); ps.executeUpdate(); try (ResultSet rs=ps.getGeneratedKeys()) {
                if (!rs.next()) throw new SQLException("No se genero el identificador."); return rs.getInt(1);
            }
        }
    }
}
