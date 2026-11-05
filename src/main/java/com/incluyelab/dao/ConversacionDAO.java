package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.MensajePostulacion;
import com.incluyelab.model.Postulacion;
import com.incluyelab.model.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ConversacionDAO {
    public Postulacion obtenerPostulacion(int idPostulacion, Usuario actor) throws SQLException {
        String sql = "SELECT p.id_postulacion,p.id_usuario,p.id_oferta,u.nombre postulante,u.correo," +
                "o.titulo oferta,e.razon_social empresa,p.estado,DATE_FORMAT(p.fecha_postulacion,'%d/%m/%Y %H:%i') fecha_postulacion " +
                "FROM postulaciones p JOIN usuarios u ON u.id_usuario=p.id_usuario " +
                "JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa " +
                "WHERE p.id_postulacion=? AND ((?='POSTULANTE' AND p.id_usuario=?) OR (?='EMPRESA' AND e.id_usuario=?))";
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1,idPostulacion); ps.setString(2,actor.getRol()); ps.setInt(3,actor.getIdUsuario());
            ps.setString(4,actor.getRol()); ps.setInt(5,actor.getIdUsuario());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Postulacion p=new Postulacion();
                p.setIdPostulacion(rs.getInt("id_postulacion")); p.setIdUsuario(rs.getInt("id_usuario"));
                p.setIdOferta(rs.getInt("id_oferta")); p.setPostulante(rs.getString("postulante"));
                p.setCorreo(rs.getString("correo")); p.setOferta(rs.getString("oferta"));
                p.setEmpresa(rs.getString("empresa")); p.setEstado(rs.getString("estado"));
                p.setFechaPostulacion(rs.getString("fecha_postulacion"));
                return p;
            }
        }
    }

    public List<MensajePostulacion> listar(int idPostulacion, Usuario actor) throws SQLException {
        if (obtenerPostulacion(idPostulacion,actor)==null) throw new SecurityException("Conversación no disponible.");
        List<MensajePostulacion> mensajes=new ArrayList<>();
        String sql="SELECT m.id_mensaje,m.id_postulacion,m.id_remitente,u.nombre nombre_remitente,u.rol rol_remitente,"+
                "m.mensaje,m.leido,m.fecha_creacion FROM mensajes_postulacion m JOIN usuarios u ON u.id_usuario=m.id_remitente "+
                "WHERE m.id_postulacion=? ORDER BY m.id_mensaje";
        try(Connection cn=Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                try(PreparedStatement leer=cn.prepareStatement("UPDATE mensajes_postulacion SET leido=1 WHERE id_postulacion=? AND id_remitente<>? AND leido=0")) {
                    leer.setInt(1,idPostulacion); leer.setInt(2,actor.getIdUsuario()); leer.executeUpdate();
                }
                try(PreparedStatement ps=cn.prepareStatement(sql)) {
                    ps.setInt(1,idPostulacion);
                    try(ResultSet rs=ps.executeQuery()) { while(rs.next()) mensajes.add(mapear(rs)); }
                }
                cn.commit();
            } catch(SQLException ex) { cn.rollback(); throw ex; }
            finally { cn.setAutoCommit(true); }
        }
        return mensajes;
    }

    public void enviar(int idPostulacion, Usuario actor, String texto) throws SQLException {
        String mensaje=texto==null?"":texto.trim();
        if(mensaje.isEmpty() || mensaje.length()>2000) throw new IllegalArgumentException("El mensaje debe contener entre 1 y 2000 caracteres.");
        try(Connection cn=Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                int destinatario=destinatario(cn,idPostulacion,actor);
                if(destinatario==0) throw new SecurityException("Conversación no disponible.");
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO mensajes_postulacion(id_postulacion,id_remitente,mensaje) VALUES(?,?,?)")) {
                    ps.setInt(1,idPostulacion); ps.setInt(2,actor.getIdUsuario()); ps.setString(3,mensaje); ps.executeUpdate();
                }
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) VALUES(?,'NUEVO_MENSAJE','Nuevo mensaje en una postulación',?)")) {
                    ps.setInt(1,destinatario); ps.setString(2,"Tienes un nuevo mensaje sobre la postulación."); ps.executeUpdate();
                }
                cn.commit();
            } catch(SQLException|RuntimeException ex) { cn.rollback(); throw ex; }
            finally { cn.setAutoCommit(true); }
        }
    }

    private int destinatario(Connection cn,int idPostulacion,Usuario actor)throws SQLException {
        String sql="SELECT CASE WHEN ?='POSTULANTE' AND p.id_usuario=? THEN e.id_usuario "+
                "WHEN ?='EMPRESA' AND e.id_usuario=? THEN p.id_usuario ELSE 0 END destinatario "+
                "FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa "+
                "WHERE p.id_postulacion=?";
        try(PreparedStatement ps=cn.prepareStatement(sql)) {
            ps.setString(1,actor.getRol()); ps.setInt(2,actor.getIdUsuario()); ps.setString(3,actor.getRol());
            ps.setInt(4,actor.getIdUsuario()); ps.setInt(5,idPostulacion);
            try(ResultSet rs=ps.executeQuery()) { return rs.next()?rs.getInt("destinatario"):0; }
        }
    }

    private MensajePostulacion mapear(ResultSet rs)throws SQLException {
        MensajePostulacion m=new MensajePostulacion();
        m.setIdMensaje(rs.getLong("id_mensaje")); m.setIdPostulacion(rs.getInt("id_postulacion"));
        m.setIdRemitente(rs.getInt("id_remitente")); m.setNombreRemitente(rs.getString("nombre_remitente"));
        m.setRolRemitente(rs.getString("rol_remitente")); m.setMensaje(rs.getString("mensaje")); m.setLeido(rs.getBoolean("leido"));
        Timestamp fecha=rs.getTimestamp("fecha_creacion"); m.setFechaCreacion(fecha==null?null:fecha.toLocalDateTime());
        return m;
    }
}
