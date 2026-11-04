package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Postulacion;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PostulacionDAO {
    public void registrar(int idUsuario, int idOferta) throws SQLException {
        try (Connection cn = Conexion.getConnection();
             CallableStatement ps = cn.prepareCall("{CALL sp_postulacion_crear(?,?)}")) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idOferta);
            ps.execute();
        }
    }

    public List<Postulacion> listarPorUsuario(int idUsuario) throws SQLException {
        return listarProcedimiento("USUARIO",idUsuario,0);
    }

    public List<Postulacion> listarTodas() throws SQLException {
        return listarProcedimiento("TODAS",0,0);
    }

    public List<Postulacion> listarPorEmpresa(int idUsuarioEmpresa) throws SQLException {
        return listarProcedimiento("EMPRESA",idUsuarioEmpresa,0);
    }

    public Postulacion obtenerParaEmpresa(int idPostulacion,int idUsuarioEmpresa) throws SQLException {
        List<Postulacion> lista=listarProcedimiento("EMPRESA_ID",idPostulacion,idUsuarioEmpresa);
        return lista.isEmpty()?null:lista.get(0);
    }

    public Postulacion obtenerPorId(int idPostulacion) throws SQLException {
        List<Postulacion> lista=listarProcedimiento("ID",idPostulacion,0);
        return lista.isEmpty()?null:lista.get(0);
    }

    public void cambiarEstadoEmpresa(int idPostulacion,int idUsuarioEmpresa,String estado) throws SQLException {
        if(!java.util.Arrays.asList("en revision","aceptado").contains(estado))throw new IllegalArgumentException("Estado no valido.");
        try(Connection cn=Conexion.getConnection();CallableStatement ps=cn.prepareCall("{CALL sp_postulacion_actualizar_empresa(?,?,?)}")){ps.setInt(1,idPostulacion);ps.setInt(2,idUsuarioEmpresa);ps.setString(3,estado);ps.execute();}
    }

    public void eliminarPorEmpresa(int idPostulacion,int idUsuarioEmpresa) throws SQLException {
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try{
                try(CallableStatement ps=cn.prepareCall("{CALL sp_postulacion_eliminar_empresa(?,?)}")){ps.setInt(1,idPostulacion);ps.setInt(2,idUsuarioEmpresa);ps.execute();}
                cn.commit();
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}finally{cn.setAutoCommit(true);}
        }
    }

    public void eliminarPorUsuario(int idPostulacion,int idUsuario) throws SQLException {
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{try(CallableStatement ps=cn.prepareCall("{CALL sp_postulacion_eliminar_usuario(?,?)}")){ps.setInt(1,idPostulacion);ps.setInt(2,idUsuario);ps.execute();}cn.commit();}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}finally{cn.setAutoCommit(true);}}
    }

    private List<Postulacion> listarProcedimiento(String modo,int id1,int id2)throws SQLException{
        List<Postulacion> lista=new ArrayList<>();
        try(Connection cn=Conexion.getConnection();CallableStatement ps=cn.prepareCall("{CALL sp_postulacion_listar(?,?,?)}")){
            ps.setString(1,modo);ps.setInt(2,id1);ps.setInt(3,id2);
            try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapear(rs));}
        }
        return lista;
    }
    private Postulacion mapear(ResultSet rs)throws SQLException{
        Postulacion p=new Postulacion();p.setIdPostulacion(rs.getInt("id_postulacion"));p.setIdUsuario(rs.getInt("id_usuario"));p.setIdOferta(rs.getInt("id_oferta"));
        p.setPostulante(rs.getString("postulante"));p.setOferta(rs.getString("oferta"));p.setEmpresa(rs.getString("empresa"));p.setEstado(rs.getString("estado"));
        p.setFechaPostulacion(rs.getString("fecha_postulacion"));p.setCorreo(rs.getString("correo"));p.setTitular(rs.getString("titular"));p.setUbicacion(rs.getString("ubicacion"));p.setHabilidades(rs.getString("habilidades"));p.setCvNombre(rs.getString("cv_nombre"));return p;
    }
}
