package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.PerfilPostulante;
import java.sql.*;

public class PerfilPostulanteDAO {
    public PerfilPostulante obtener(int usuario) throws SQLException {
        PerfilPostulante p=new PerfilPostulante(); p.setIdUsuario(usuario);
        try(Connection cn=Conexion.getConnection()){
            try(PreparedStatement ps=cn.prepareStatement("SELECT u.nombre,u.correo,p.telefono,p.habilidades,p.adaptacion_requerida,p.titular,p.ubicacion,p.acerca_de,p.foto_url,p.cv_nombre,p.cv_archivo FROM usuarios u LEFT JOIN perfiles_postulantes p ON p.id_usuario=u.id_usuario WHERE u.id_usuario=? AND u.rol='POSTULANTE'")){
                ps.setInt(1,usuario); try(ResultSet rs=ps.executeQuery()){if(!rs.next())return null;
                    p.setNombre(rs.getString("nombre"));p.setCorreo(rs.getString("correo"));p.setTelefono(rs.getString("telefono"));
                    p.setHabilidades(rs.getString("habilidades"));p.setAdaptacionRequerida(rs.getString("adaptacion_requerida"));
                    p.setTitular(rs.getString("titular"));p.setUbicacion(rs.getString("ubicacion"));p.setAcercaDe(rs.getString("acerca_de"));
                    p.setFotoUrl(rs.getString("foto_url"));p.setCvNombre(rs.getString("cv_nombre"));p.setCvArchivo(rs.getString("cv_archivo"));
                }
            }
            try(PreparedStatement ps=cn.prepareStatement("SELECT * FROM experiencias_postulante WHERE id_usuario=? ORDER BY id_experiencia DESC")){ps.setInt(1,usuario);try(ResultSet rs=ps.executeQuery()){while(rs.next()){PerfilPostulante.Experiencia x=new PerfilPostulante.Experiencia();x.setId(rs.getInt("id_experiencia"));x.setCargo(rs.getString("cargo"));x.setOrganizacion(rs.getString("organizacion"));x.setInicio(rs.getString("fecha_inicio"));x.setFin(rs.getString("fecha_fin"));x.setDescripcion(rs.getString("descripcion"));p.agregarExperiencia(x);}}}
            try(PreparedStatement ps=cn.prepareStatement("SELECT * FROM educacion_postulante WHERE id_usuario=? ORDER BY id_educacion DESC")){ps.setInt(1,usuario);try(ResultSet rs=ps.executeQuery()){while(rs.next()){PerfilPostulante.Educacion x=new PerfilPostulante.Educacion();x.setId(rs.getInt("id_educacion"));x.setInstitucion(rs.getString("institucion"));x.setCarrera(rs.getString("carrera"));x.setInicio(rs.getString("fecha_inicio"));x.setFin(rs.getString("fecha_fin"));x.setDescripcion(rs.getString("descripcion"));p.agregarEducacion(x);}}}
            try(PreparedStatement ps=cn.prepareStatement("SELECT * FROM certificaciones_postulante WHERE id_usuario=? ORDER BY id_certificacion DESC")){ps.setInt(1,usuario);try(ResultSet rs=ps.executeQuery()){while(rs.next()){PerfilPostulante.Certificacion x=new PerfilPostulante.Certificacion();x.setId(rs.getInt("id_certificacion"));x.setNombre(rs.getString("nombre"));x.setEmisor(rs.getString("emisor"));x.setFecha(rs.getString("fecha_emision"));x.setUrl(rs.getString("credencial_url"));p.agregarCertificacion(x);}}}
        }
        com.incluyelab.model.VerificacionConadis v=new VerificacionConadisDAO().obtenerPorUsuario(usuario);
        if(v!=null&&v.isRevisionRrhh()&&"APROBADA".equals(v.getEstado()))p.setDatosConadis(v);
        return p;
    }

    public void guardarResumen(int usuario,String nombre,String telefono,String titular,String ubicacion,String acerca,String habilidades,String adaptacion) throws SQLException {
        validar(nombre,170,"nombre");validar(telefono,20,"telefono");validar(titular,160,"titular");validar(ubicacion,120,"ubicacion");validar(acerca,5000,"presentacion");validar(habilidades,1000,"habilidades");validarOpcional(adaptacion,1000,"adaptaciones");
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{
            try(PreparedStatement guardia=cn.prepareStatement("SELECT u.nombre,EXISTS(SELECT 1 FROM verificaciones_conadis v WHERE v.id_usuario=u.id_usuario AND v.revision_rrhh=1 AND v.estado='APROBADA') bloqueado FROM usuarios u WHERE u.id_usuario=? FOR UPDATE")){guardia.setInt(1,usuario);try(ResultSet rs=guardia.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Perfil no disponible.");if(rs.getBoolean(2)&&!nombre.equals(rs.getString(1)))throw new IllegalArgumentException("El nombre validado por RRHH no puede modificarse.");}}
            try(PreparedStatement ps=cn.prepareStatement("UPDATE usuarios SET nombre=? WHERE id_usuario=? AND rol='POSTULANTE'")){ps.setString(1,nombre);ps.setInt(2,usuario);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("Perfil no disponible.");}
            try(PreparedStatement ps=cn.prepareStatement("INSERT INTO perfiles_postulantes(id_usuario,telefono,habilidades,adaptacion_requerida,titular,ubicacion,acerca_de) VALUES(?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE telefono=VALUES(telefono),habilidades=VALUES(habilidades),adaptacion_requerida=VALUES(adaptacion_requerida),titular=VALUES(titular),ubicacion=VALUES(ubicacion),acerca_de=VALUES(acerca_de)")){
                ps.setInt(1,usuario);ps.setString(2,telefono);ps.setString(3,habilidades);ps.setString(4,adaptacion);ps.setString(5,titular);ps.setString(6,ubicacion);ps.setString(7,acerca);ps.executeUpdate();}
            cn.commit();
        }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    public void guardarCv(int usuario,String nombre,String archivo) throws SQLException {
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement("INSERT INTO perfiles_postulantes(id_usuario,cv_nombre,cv_archivo,cv_actualizado) VALUES(?,?,?,NOW()) ON DUPLICATE KEY UPDATE cv_nombre=VALUES(cv_nombre),cv_archivo=VALUES(cv_archivo),cv_actualizado=NOW()")){ps.setInt(1,usuario);ps.setString(2,nombre);ps.setString(3,archivo);ps.executeUpdate();}
    }
    public void guardarFoto(int usuario,String archivo) throws SQLException {
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement("INSERT INTO perfiles_postulantes(id_usuario,foto_url) VALUES(?,?) ON DUPLICATE KEY UPDATE foto_url=VALUES(foto_url)")){ps.setInt(1,usuario);ps.setString(2,archivo);ps.executeUpdate();}
    }
    public void agregarExperiencia(int u,String cargo,String org,String inicio,String fin,String desc)throws SQLException{validar(cargo,150,"cargo");validar(org,150,"organizacion");validar(inicio,30,"inicio");validar(fin,30,"fin");validar(desc,2000,"descripcion");insertar(u,"INSERT INTO experiencias_postulante(id_usuario,cargo,organizacion,fecha_inicio,fecha_fin,descripcion) VALUES(?,?,?,?,?,?)",cargo,org,inicio,fin,desc);}
    public void agregarEducacion(int u,String institucion,String carrera,String inicio,String fin,String desc)throws SQLException{validar(institucion,180,"institucion");validar(carrera,180,"carrera");validar(inicio,30,"inicio");validar(fin,30,"fin");validar(desc,2000,"descripcion");insertar(u,"INSERT INTO educacion_postulante(id_usuario,institucion,carrera,fecha_inicio,fecha_fin,descripcion) VALUES(?,?,?,?,?,?)",institucion,carrera,inicio,fin,desc);}
    public void agregarCertificacion(int u,String nombre,String emisor,String fecha,String url)throws SQLException{validar(nombre,200,"certificacion");validar(emisor,150,"emisor");validar(fecha,30,"fecha");validarOpcional(url,500,"enlace");if(!url.isEmpty()&&!url.matches("https?://.+"))throw new IllegalArgumentException("El enlace de la credencial debe empezar con http:// o https://.");insertar(u,"INSERT INTO certificaciones_postulante(id_usuario,nombre,emisor,fecha_emision,credencial_url) VALUES(?,?,?,?,?)",nombre,emisor,fecha,url);}
    public void eliminar(int usuario,String tipo,int id)throws SQLException{String tabla,clave;switch(tipo){case"experiencia":tabla="experiencias_postulante";clave="id_experiencia";break;case"educacion":tabla="educacion_postulante";clave="id_educacion";break;case"certificacion":tabla="certificaciones_postulante";clave="id_certificacion";break;default:throw new IllegalArgumentException("Seccion no valida.");}try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement("DELETE FROM "+tabla+" WHERE "+clave+"=? AND id_usuario=?")){ps.setInt(1,id);ps.setInt(2,usuario);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("Elemento no encontrado.");}}
    private void insertar(int u,String sql,String...v)throws SQLException{try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){ps.setInt(1,u);for(int i=0;i<v.length;i++)ps.setString(i+2,v[i]);ps.executeUpdate();}}
    private void validar(String v,int max,String campo){if(v==null||v.trim().isEmpty()||v.length()>max)throw new IllegalArgumentException("Revisa el campo "+campo+".");}
    private void validarOpcional(String v,int max,String campo){if(v!=null&&v.length()>max)throw new IllegalArgumentException("Revisa el campo "+campo+".");}
}
