package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Postulacion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PostulacionDAO {
    public void registrar(int idUsuario, int idOferta) throws SQLException {
        String sql = "INSERT INTO postulaciones(id_usuario, id_oferta, estado) "
                + "SELECT ?, o.id_oferta, 'pendiente' FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN usuarios postulante ON postulante.id_usuario=? AND postulante.rol='POSTULANTE' AND postulante.estado='activo' JOIN verificaciones_conadis vc ON vc.id_usuario=postulante.id_usuario AND vc.estado='APROBADA' AND (vc.fecha_caducidad IS NULL OR vc.fecha_caducidad>=CURDATE()) WHERE o.id_oferta=? AND o.estado='activa' AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA' "
                + "AND NOT EXISTS (SELECT 1 FROM postulaciones p WHERE p.id_usuario=? AND p.id_oferta=o.id_oferta)";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idUsuario);
            ps.setInt(3, idOferta);
            ps.setInt(4, idUsuario);
            if (ps.executeUpdate() == 0) {
                throw new SQLException("Ya postulaste a esta oferta o la oferta no esta disponible.");
            }
        }
    }

    public List<Postulacion> listarPorUsuario(int idUsuario) throws SQLException {
        return listar("WHERE p.id_usuario=?", idUsuario);
    }

    public List<Postulacion> listarTodas() throws SQLException {
        return listar("");
    }

    public List<Postulacion> listarPorEmpresa(int idUsuarioEmpresa) throws SQLException {
        return listar("WHERE e.id_usuario=?", idUsuarioEmpresa);
    }

    public Postulacion obtenerParaEmpresa(int idPostulacion,int idUsuarioEmpresa) throws SQLException {
        List<Postulacion> lista=listar("WHERE p.id_postulacion=? AND e.id_usuario=?",idPostulacion,idUsuarioEmpresa);
        return lista.isEmpty()?null:lista.get(0);
    }

    public Postulacion obtenerPorId(int idPostulacion) throws SQLException {
        List<Postulacion> lista=listar("WHERE p.id_postulacion=?",idPostulacion);
        return lista.isEmpty()?null:lista.get(0);
    }

    public void cambiarEstadoEmpresa(int idPostulacion,int idUsuarioEmpresa,String estado) throws SQLException {
        if(!java.util.Arrays.asList("en revision","aceptado").contains(estado))throw new IllegalArgumentException("Estado no valido.");
        String sql="UPDATE postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa SET p.estado=? WHERE p.id_postulacion=? AND e.id_usuario=?";
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){ps.setString(1,estado);ps.setInt(2,idPostulacion);ps.setInt(3,idUsuarioEmpresa);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("Postulacion no disponible.");}
    }

    public void eliminarPorEmpresa(int idPostulacion,int idUsuarioEmpresa) throws SQLException {
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try{
                int destinatario;String oferta;String empresa;
                String sql="SELECT p.id_usuario,o.titulo,e.razon_social FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa WHERE p.id_postulacion=? AND e.id_usuario=? FOR UPDATE";
                try(PreparedStatement ps=cn.prepareStatement(sql)){ps.setInt(1,idPostulacion);ps.setInt(2,idUsuarioEmpresa);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La postulación no existe o no tienes permiso para eliminarla.");destinatario=rs.getInt(1);oferta=rs.getString(2);empresa=rs.getString(3);}}
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) VALUES(?,'POSTULACION_ELIMINADA','Postulación eliminada',?)")){ps.setInt(1,destinatario);ps.setString(2,"La empresa "+empresa+" eliminó tu postulación a "+oferta+".");ps.executeUpdate();}
                borrarPostulacion(cn,idPostulacion);
                cn.commit();
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}finally{cn.setAutoCommit(true);}
        }
    }

    public void eliminarPorUsuario(int idPostulacion,int idUsuario) throws SQLException {
        eliminarPropia(idPostulacion,"SELECT id_postulacion FROM postulaciones WHERE id_postulacion=? AND id_usuario=? FOR UPDATE",idUsuario);
    }

    private void eliminarPropia(int idPostulacion,String autorizacion,int propietario) throws SQLException {
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try{
                try(PreparedStatement ps=cn.prepareStatement(autorizacion)){ps.setInt(1,idPostulacion);ps.setInt(2,propietario);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La postulación no existe o no tienes permiso para eliminarla.");}}
                borrarPostulacion(cn,idPostulacion);
                cn.commit();
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}
            finally{cn.setAutoCommit(true);}
        }
    }
    private void borrarPostulacion(Connection cn,int idPostulacion)throws SQLException{
        try(PreparedStatement ps=cn.prepareStatement("DELETE FROM evaluaciones_rrhh WHERE id_postulacion=?")){ps.setInt(1,idPostulacion);ps.executeUpdate();}
        try(PreparedStatement ps=cn.prepareStatement("DELETE FROM postulaciones WHERE id_postulacion=?")){ps.setInt(1,idPostulacion);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("No se pudo eliminar la postulación.");}
    }

    private List<Postulacion> listar(String where, int... valores) throws SQLException {
        List<Postulacion> lista = new ArrayList<>();
        String sql = "SELECT p.id_postulacion, p.id_usuario, p.id_oferta, u.nombre postulante,u.correo, o.titulo oferta, "
                + "e.razon_social empresa, p.estado, DATE_FORMAT(p.fecha_postulacion, '%d/%m/%Y %H:%i') fecha_postulacion,"
                + "COALESCE(pp.titular,'') titular,COALESCE(pp.ubicacion,'') ubicacion,COALESCE(pp.habilidades,'') habilidades,COALESCE(pp.cv_nombre,'') cv_nombre "
                + "FROM postulaciones p INNER JOIN usuarios u ON p.id_usuario=u.id_usuario "
                + "INNER JOIN ofertas o ON p.id_oferta=o.id_oferta "
                + "INNER JOIN empresas e ON o.id_empresa=e.id_empresa LEFT JOIN perfiles_postulantes pp ON pp.id_usuario=u.id_usuario " + where
                + " ORDER BY p.id_postulacion DESC";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            for (int i=0;i<valores.length;i++) ps.setInt(i+1,valores[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Postulacion p = new Postulacion();
                    p.setIdPostulacion(rs.getInt("id_postulacion"));
                    p.setIdUsuario(rs.getInt("id_usuario"));
                    p.setIdOferta(rs.getInt("id_oferta"));
                    p.setPostulante(rs.getString("postulante"));
                    p.setOferta(rs.getString("oferta"));
                    p.setEmpresa(rs.getString("empresa"));
                    p.setEstado(rs.getString("estado"));
                    p.setFechaPostulacion(rs.getString("fecha_postulacion"));
                    p.setCorreo(rs.getString("correo"));p.setTitular(rs.getString("titular"));p.setUbicacion(rs.getString("ubicacion"));p.setHabilidades(rs.getString("habilidades"));p.setCvNombre(rs.getString("cv_nombre"));
                    lista.add(p);
                }
            }
        }
        return lista;
    }
}
