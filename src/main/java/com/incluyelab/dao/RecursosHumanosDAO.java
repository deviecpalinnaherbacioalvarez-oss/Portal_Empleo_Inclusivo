package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.EvaluacionRRHH;
import com.incluyelab.model.Postulacion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class RecursosHumanosDAO {
    private static final String SELECT_EVALUACION =
        "SELECT v.id_evaluacion,v.id_postulacion,v.id_evaluador," +
        "u.nombre AS nombre_postulante,ev.nombre AS nombre_evaluador," +
        "o.titulo AS titulo_oferta,e.razon_social AS razon_social_empresa," +
        "v.observaciones,v.retroalimentacion,v.resultado,v.estado,v.etapa," +
        "v.puntaje_cv,v.puntaje_entrevista,v.puntaje_desempeno,v.porcentaje_compatibilidad," +
        "v.fecha_creacion,v.fecha_actualizacion " +
        "FROM evaluaciones_rrhh v " +
        "JOIN postulaciones p ON p.id_postulacion=v.id_postulacion " +
        "JOIN usuarios u ON u.id_usuario=p.id_usuario " +
        "JOIN usuarios ev ON ev.id_usuario=v.id_evaluador " +
        "JOIN ofertas o ON o.id_oferta=p.id_oferta " +
        "JOIN empresas e ON e.id_empresa=o.id_empresa ";

    private void autorizar(Connection cn,int actor) throws SQLException {
        try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='RECURSOS_HUMANOS' AND estado='activo' FOR UPDATE")){
            ps.setInt(1,actor);
            try(ResultSet rs=ps.executeQuery()){
                if(!rs.next())throw new IllegalArgumentException("Tu cuenta no tiene acceso a Recursos Humanos.");
            }
        }
    }

    public List<Postulacion> candidatos() throws SQLException {
        String sql="SELECT p.id_postulacion,u.nombre AS postulante,u.correo,o.titulo AS oferta," +
            "e.razon_social AS empresa,p.estado,DATE_FORMAT(p.fecha_postulacion,'%d/%m/%Y %H:%i') AS fecha_postulacion," +
            "COALESCE(pp.cv_nombre,'') AS cv_nombre,COALESCE(pp.titular,'') AS titular," +
            "COALESCE(pp.habilidades,'') AS habilidades " +
            "FROM postulaciones p JOIN usuarios u ON u.id_usuario=p.id_usuario " +
            "JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa " +
            "LEFT JOIN perfiles_postulantes pp ON pp.id_usuario=u.id_usuario ORDER BY p.id_postulacion DESC";
        List<Postulacion> lista=new ArrayList<>();
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next()){
                Postulacion p=new Postulacion();
                p.setIdPostulacion(rs.getInt("id_postulacion"));
                p.setPostulante(rs.getString("postulante"));
                p.setCorreo(rs.getString("correo"));
                p.setOferta(rs.getString("oferta"));
                p.setEmpresa(rs.getString("empresa"));
                p.setEstado(rs.getString("estado"));
                p.setFechaPostulacion(rs.getString("fecha_postulacion"));
                p.setCvNombre(rs.getString("cv_nombre"));
                p.setTitular(rs.getString("titular"));
                p.setHabilidades(rs.getString("habilidades"));
                lista.add(p);
            }
        }
        return lista;
    }

    public List<EvaluacionRRHH> evaluaciones(int actor) throws SQLException {
        return listarEvaluaciones(SELECT_EVALUACION+"WHERE v.id_evaluador=? ORDER BY v.id_evaluacion DESC",actor);
    }
    public List<EvaluacionRRHH> listarTodas() throws SQLException {
        return listarEvaluaciones(SELECT_EVALUACION+"ORDER BY v.id_evaluacion DESC");
    }
    public List<EvaluacionRRHH> evaluacionesPublicadasEmpresa(int usuarioEmpresa) throws SQLException {
        return listarEvaluaciones(SELECT_EVALUACION+"WHERE e.id_usuario=? AND v.estado='PUBLICADO' ORDER BY v.fecha_actualizacion DESC",usuarioEmpresa);
    }
    public List<EvaluacionRRHH> evaluacionesPublicadasPostulacion(int postulacion,int usuarioEmpresa) throws SQLException {
        return listarEvaluaciones(SELECT_EVALUACION+"WHERE p.id_postulacion=? AND e.id_usuario=? AND v.estado='PUBLICADO' ORDER BY v.fecha_actualizacion DESC",postulacion,usuarioEmpresa);
    }

    public void guardar(int actor,int id,int postulacion,String observaciones,String retroalimentacion,String resultado,String estado,String etapa,int cv,int entrevista,int desempeno,int compatibilidad) throws SQLException {
        texto(observaciones,4000,"observaciones");opcional(retroalimentacion,4000,"retroalimentacion");
        if(!Arrays.asList("PENDIENTE","APROBADO","NO_APROBADO").contains(resultado)||!Arrays.asList("BORRADOR","PUBLICADO").contains(estado)||!Arrays.asList("REVISION_CV","ENTREVISTA","DESEMPENO","FINAL").contains(etapa))throw new IllegalArgumentException("Selecciona una etapa, veredicto y estado válidos.");
        porcentaje(cv,"CV");porcentaje(entrevista,"entrevista");porcentaje(desempeno,"desempeño");porcentaje(compatibilidad,"compatibilidad");
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{autorizar(cn,actor);
            try(PreparedStatement ps=cn.prepareStatement("SELECT estado FROM postulaciones WHERE id_postulacion=? FOR UPDATE")){ps.setInt(1,postulacion);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La postulación ya no existe.");if("DESEMPENO".equals(etapa)&&!"aceptado".equals(rs.getString(1)))throw new IllegalArgumentException("La evaluación de desempeño requiere una postulación aceptada.");}}
            if(id==0){try(PreparedStatement ps=cn.prepareStatement("INSERT INTO evaluaciones_rrhh(id_postulacion,id_evaluador,observaciones,retroalimentacion,resultado,estado,etapa,puntaje_cv,puntaje_entrevista,puntaje_desempeno,porcentaje_compatibilidad) VALUES(?,?,?,?,?,?,?,?,?,?,?)")){parametros(ps,postulacion,actor,observaciones.trim(),retroalimentacion.trim(),resultado,estado,etapa,cv,entrevista,desempeno,compatibilidad);ps.executeUpdate();}}
            else{try(PreparedStatement ps=cn.prepareStatement("UPDATE evaluaciones_rrhh SET id_postulacion=?,observaciones=?,retroalimentacion=?,resultado=?,estado=?,etapa=?,puntaje_cv=?,puntaje_entrevista=?,puntaje_desempeno=?,porcentaje_compatibilidad=? WHERE id_evaluacion=? AND id_evaluador=?")){parametros(ps,postulacion,observaciones.trim(),retroalimentacion.trim(),resultado,estado,etapa,cv,entrevista,desempeno,compatibilidad,id,actor);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("Evaluación no disponible.");}}
            cn.commit();}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }
    public void eliminar(int actor,int id) throws SQLException {
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{autorizar(cn,actor);try(PreparedStatement ps=cn.prepareStatement("DELETE FROM evaluaciones_rrhh WHERE id_evaluacion=? AND id_evaluador=? AND estado='BORRADOR'")){parametros(ps,id,actor);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("Solo puedes eliminar tus evaluaciones en borrador.");}cn.commit();}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    private List<EvaluacionRRHH> listarEvaluaciones(String sql,Object... valores)throws SQLException {
        List<EvaluacionRRHH> lista=new ArrayList<>();
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){
            parametros(ps,valores);
            try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapearEvaluacion(rs));}
        }
        return lista;
    }
    private EvaluacionRRHH mapearEvaluacion(ResultSet rs)throws SQLException {
        EvaluacionRRHH e=new EvaluacionRRHH();
        e.setIdEvaluacion(rs.getInt("id_evaluacion"));
        e.setIdPostulacion(rs.getInt("id_postulacion"));
        e.setIdEvaluador(rs.getInt("id_evaluador"));
        e.setNombrePostulante(rs.getString("nombre_postulante"));
        e.setNombreEvaluador(rs.getString("nombre_evaluador"));
        e.setTituloOferta(rs.getString("titulo_oferta"));
        e.setRazonSocialEmpresa(rs.getString("razon_social_empresa"));
        e.setObservaciones(rs.getString("observaciones"));
        e.setRetroalimentacion(rs.getString("retroalimentacion"));
        e.setResultado(rs.getString("resultado"));
        e.setEstado(rs.getString("estado"));
        e.setEtapa(rs.getString("etapa"));
        e.setPuntajeCv(rs.getInt("puntaje_cv"));
        e.setPuntajeEntrevista(rs.getInt("puntaje_entrevista"));
        e.setPuntajeDesempeno(rs.getInt("puntaje_desempeno"));
        e.setPorcentajeCompatibilidad(rs.getInt("porcentaje_compatibilidad"));
        e.setFechaCreacion(fecha(rs,"fecha_creacion"));
        e.setFechaActualizacion(fecha(rs,"fecha_actualizacion"));
        return e;
    }
    private java.time.LocalDateTime fecha(ResultSet rs,String columna)throws SQLException {Timestamp valor=rs.getTimestamp(columna);return valor==null?null:valor.toLocalDateTime();}
    private void parametros(PreparedStatement ps,Object... valores)throws SQLException{for(int i=0;i<valores.length;i++)ps.setObject(i+1,valores[i]);}
    private void texto(String valor,int max,String campo){if(valor==null||valor.trim().isEmpty()||valor.length()>max)throw new IllegalArgumentException("Completa "+campo+".");}
    private void opcional(String valor,int max,String campo){if(valor==null||valor.length()>max)throw new IllegalArgumentException("Revisa "+campo+".");}
    private void porcentaje(int valor,String campo){if(valor<0||valor>100)throw new IllegalArgumentException("El porcentaje de "+campo+" debe estar entre 0 y 100.");}
}
