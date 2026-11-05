package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.security.Passwords;
import com.incluyelab.security.Roles;
import java.sql.*;
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
                if (!"usuarios".equals(entidad)) throw new IllegalArgumentException("Seccion no valida.");
                llamar(cn,"{CALL sp_usuario_eliminar(?)}",id);
                cn.commit();
            } catch (SQLException | RuntimeException ex) { cn.rollback(); throw ex; }
        }
    }

    public void darBaja(int id,int actor)throws SQLException {
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{autorizar(cn,actor);if(id==actor)throw new IllegalArgumentException("No puedes desactivar tu propia cuenta.");llamar(cn,"{CALL sp_usuario_desactivar(?)}",id);cn.commit();}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
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
            String hash=v.get("contrasena").isEmpty()?null:Passwords.hash(v.get("contrasena"));
            llamar(cn,"{CALL sp_usuario_actualizar_interno(?,?,?,?,?,?)}",id,v.get("nombre"),v.get("correo"),hash,rol,v.get("estado"));
        } else {
            try(CallableStatement cs=cn.prepareCall("{CALL sp_usuario_crear_interno(?,?,?,?,?,?)}")){
                parametros(cs,v.get("nombre"),v.get("correo"),Passwords.hash(v.get("contrasena")),rol,v.get("estado"));
                cs.registerOutParameter(6,Types.INTEGER);cs.execute();id=cs.getInt(6);
            }
        }
    }

    private void autorizar(Connection cn, int actor) throws SQLException {
        if (!exists(cn,"SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='ADMIN' AND estado='activo' FOR UPDATE",actor))
            throw new IllegalArgumentException("La cuenta ya no tiene acceso administrativo.");
    }
    private void bloquear(Connection cn, String entidad, int id) throws SQLException {
        if (!"usuarios".equals(entidad) || !exists(cn,"SELECT 1 FROM usuarios WHERE id_usuario=? FOR UPDATE",id))
            throw new IllegalArgumentException("El registro ya no existe. Actualiza el listado.");
    }
    private void parametros(PreparedStatement ps, Object... values) throws SQLException {
        for (int i=0;i<values.length;i++) ps.setObject(i+1,values[i]);
    }
    private boolean exists(Connection cn, String sql, Object... values) throws SQLException {
        try (PreparedStatement ps=cn.prepareStatement(sql)) { parametros(ps,values); try(ResultSet rs=ps.executeQuery()) { return rs.next(); } }
    }
    private void llamar(Connection cn,String sql,Object... values)throws SQLException{
        try(CallableStatement cs=cn.prepareCall(sql)){parametros(cs,values);cs.execute();}
    }
}
