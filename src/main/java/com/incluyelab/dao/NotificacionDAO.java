package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Notificacion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class NotificacionDAO {
    public List<Notificacion> listar(int usuario) throws SQLException {
        List<Notificacion> lista=new ArrayList<>();
        String sql="SELECT id_notificacion,id_usuario,tipo,titulo,mensaje,leida,fecha_creacion FROM notificaciones WHERE id_usuario=? ORDER BY id_notificacion DESC LIMIT 50";
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){
            ps.setInt(1,usuario);
            try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapear(rs));}
        }
        return lista;
    }
    public void marcarLeida(int usuario,int id)throws SQLException {
        String sql=id==0?"UPDATE notificaciones SET leida=1 WHERE id_usuario=? AND leida=0":"UPDATE notificaciones SET leida=1 WHERE id_usuario=? AND id_notificacion=?";
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){ps.setInt(1,usuario);if(id>0)ps.setInt(2,id);ps.executeUpdate();}
    }
    private Notificacion mapear(ResultSet rs)throws SQLException {
        Notificacion n=new Notificacion();
        n.setIdNotificacion(rs.getInt("id_notificacion"));
        n.setIdUsuario(rs.getInt("id_usuario"));
        n.setTipo(rs.getString("tipo"));
        n.setTitulo(rs.getString("titulo"));
        n.setMensaje(rs.getString("mensaje"));
        n.setLeida(rs.getBoolean("leida"));
        Timestamp fecha=rs.getTimestamp("fecha_creacion");
        n.setFechaCreacion(fecha==null?null:fecha.toLocalDateTime());
        return n;
    }
}
