package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.AccionSoporte;
import com.incluyelab.model.IncidenciaSoporte;
import com.incluyelab.model.UsuarioSoporte;
import com.incluyelab.security.Passwords;
import java.sql.*;
import java.util.*;

public class IncidenciaDAO {
    private static final String SELECT_INCIDENCIAS =
        "SELECT i.id_incidencia,i.id_creador,i.id_responsable,i.id_usuario_afectado,i.correo,i.titulo,i.descripcion,i.origen,i.categoria,i.prioridad,i.decision,i.estado,i.solucion,i.fecha_creacion,i.fecha_actualizacion,i.numero_ticket,i.identidad_verificada,i.metodo_verificacion,i.motivo_accion,i.fecha_verificacion,"+
        "COALESCE(u.nombre,'') nombre_usuario_afectado,COALESCE(resp.nombre,'') nombre_responsable,COALESCE(u.estado,'') estado_cuenta,COALESCE(u.intentos_fallidos,0) intentos_fallidos,u.bloqueado_hasta,COALESCE(u.motivo_bloqueo,'') motivo_bloqueo " +
        "FROM incidencias_soporte i LEFT JOIN usuarios u ON u.id_usuario=i.id_usuario_afectado LEFT JOIN usuarios resp ON resp.id_usuario=i.id_responsable ";

    public void registrarExterna(Integer creador,String correo,String categoria,String titulo,String descripcion) throws SQLException {
        texto(correo,150);texto(titulo,150);texto(descripcion,4000);categoria(categoria);
        if(!correo.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+"))throw new IllegalArgumentException("Ingresa un correo válido.");
        String sql="INSERT INTO incidencias_soporte(id_creador,id_responsable,id_usuario_afectado,correo,titulo,descripcion,origen,categoria,prioridad,decision,estado,numero_ticket) SELECT ?,s.id_usuario,(SELECT u.id_usuario FROM usuarios u WHERE LOWER(u.correo)=LOWER(?) LIMIT 1),?,?,?,'EXTERNA',?,'MEDIA','PENDIENTE','PENDIENTE',CONCAT('TMP-',LEFT(REPLACE(UUID(),'-',''),26)) FROM usuarios s WHERE s.rol='SOPORTE_TECNICO' AND s.estado='activo' ORDER BY s.id_usuario LIMIT 1";
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try{
                int incidencia;
                try(PreparedStatement ps=cn.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){if(creador==null)ps.setNull(1,Types.INTEGER);else ps.setInt(1,creador);ps.setString(2,correo.trim());ps.setString(3,correo.trim());ps.setString(4,titulo.trim());ps.setString(5,descripcion.trim());ps.setString(6,categoria);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("No hay personal de soporte disponible.");try(ResultSet rs=ps.getGeneratedKeys()){if(!rs.next())throw new SQLException("No se generó el reporte.");incidencia=rs.getInt(1);}}
                asignarTicket(cn,incidencia);
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) SELECT id_responsable,'REPORTE_SOPORTE','Nuevo reporte recibido',CONCAT('Ticket ',numero_ticket,' · Categoría: ',categoria,' · ',titulo) FROM incidencias_soporte WHERE id_incidencia=?")){ps.setInt(1,incidencia);if(ps.executeUpdate()!=1)throw new SQLException("No se pudo notificar a Soporte.");}
                cn.commit();
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}finally{cn.setAutoCommit(true);}
        }
    }

    public void crearInterna(int actor,String categoria,String titulo,String descripcion,String prioridad) throws SQLException {
        texto(titulo,150);texto(descripcion,4000);categoria(categoria);prioridad(prioridad);
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try{
                autorizarSoporte(cn,actor);
                try(CallableStatement ps=cn.prepareCall("{CALL sp_incidencia_crear_interna(?,?,?,?,?)}")){parametros(ps,actor,categoria,titulo.trim(),descripcion.trim(),prioridad);ps.execute();}
                cn.commit();
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}
        }
    }

    public List<IncidenciaSoporte> listar(int actor)throws SQLException{return listarProcedimiento("ACTOR",actor);}
    public List<IncidenciaSoporte> listarTodas()throws SQLException{return listarProcedimiento("TODAS",0);}

    public List<UsuarioSoporte> buscarUsuarios(int actor,String termino)throws SQLException{
        String q=termino==null?"":termino.trim();if(q.length()>120)throw new IllegalArgumentException("La búsqueda es demasiado extensa.");List<UsuarioSoporte> lista=new ArrayList<>();
        String sql="SELECT u.id_usuario,u.nombre,u.correo,u.rol,u.estado,u.intentos_fallidos,u.bloqueado_hasta,u.motivo_bloqueo,u.requiere_cambio_clave,u.clave_temporal_expira FROM usuarios u WHERE EXISTS(SELECT 1 FROM usuarios s WHERE s.id_usuario=? AND s.rol='SOPORTE_TECNICO' AND s.estado='activo') AND (?='' OR u.nombre LIKE CONCAT('%',?,'%') OR u.correo LIKE CONCAT('%',?,'%') OR CAST(u.id_usuario AS CHAR)=?) ORDER BY (u.bloqueado_hasta>NOW()) DESC,u.id_usuario DESC LIMIT 30";
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){parametros(ps,actor,q,q,q,q);try(ResultSet rs=ps.executeQuery()){while(rs.next()){UsuarioSoporte u=new UsuarioSoporte();u.setIdUsuario(rs.getInt(1));u.setNombre(rs.getString(2));u.setCorreoOculto(ocultarCorreo(rs.getString(3)));u.setRol(rs.getString(4));u.setEstado(rs.getString(5));u.setIntentosFallidos(rs.getInt(6));u.setBloqueadoHasta(fecha(rs.getTimestamp(7)));u.setMotivoBloqueo(rs.getString(8));u.setRequiereCambioClave(rs.getBoolean(9));u.setClaveTemporalExpira(fecha(rs.getTimestamp(10)));lista.add(u);}}}return lista;
    }

    public void actualizar(int actor,int id,String titulo,String descripcion,String categoria,String prioridad,String decision,String estado,String solucion)throws SQLException{
        texto(titulo,150);texto(descripcion,4000);opcional(solucion,4000);categoria(categoria);prioridad(prioridad);if(!Arrays.asList("PENDIENTE","ACEPTADA","RECHAZADA").contains(decision)||!Arrays.asList("PENDIENTE","EN_PROCESO","RESUELTA").contains(estado))throw new IllegalArgumentException("Selecciona estados válidos.");
        try(Connection cn=Conexion.getConnection()){autorizarSoporte(cn,actor);try(CallableStatement ps=cn.prepareCall("{CALL sp_incidencia_actualizar(?,?,?,?,?,?,?,?,?)}")){parametros(ps,actor,id,titulo.trim(),descripcion.trim(),categoria,prioridad,decision,estado,solucion.trim());ps.execute();}}
    }

    public void verificarIdentidad(int actor,int incidencia,int usuario,String metodo,String motivo,String correoConfirmado,boolean confirmada)throws SQLException{
        texto(motivo,1000);metodo(metodo);texto(correoConfirmado,150);boolean coincide;
        try(Connection cn=Conexion.getConnection()){
            cn.setAutoCommit(false);
            try{
                autorizarSoporte(cn,actor);ticketAsignado(cn,actor,incidencia);String correo;
                try(PreparedStatement ps=cn.prepareStatement("SELECT correo FROM usuarios WHERE id_usuario=? FOR UPDATE")){ps.setInt(1,usuario);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La cuenta seleccionada no existe.");correo=rs.getString(1);}}
                coincide=confirmada&&correo.equalsIgnoreCase(correoConfirmado.trim());registrarAuditoria(cn,incidencia,usuario,actor,coincide?"IDENTIDAD_VERIFICADA":"IDENTIDAD_RECHAZADA",motivo,coincide?"EXITO":"RECHAZADO",metodo);
                if(coincide){try(PreparedStatement ps=cn.prepareStatement("UPDATE incidencias_soporte SET id_usuario_afectado=?,correo=?,identidad_verificada=1,metodo_verificacion=?,motivo_accion=?,fecha_verificacion=NOW(),decision='ACEPTADA',estado='EN_PROCESO' WHERE id_incidencia=? AND id_responsable=? AND identidad_verificada=0")){parametros(ps,usuario,correo,metodo,motivo,incidencia,actor);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("La identidad ya fue verificada o la incidencia no está disponible.");}}
                cn.commit();
            }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}
        }
        if(!coincide)throw new IllegalArgumentException("La identidad no fue verificada: el correo confirmado no coincide con la cuenta seleccionada.");
    }

    public void desbloquearCuenta(int actor,int incidencia)throws SQLException{
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{CuentaTicket c=cuentaVerificada(cn,actor,incidencia);asegurarAccionNueva(cn,incidencia,"CUENTA_DESBLOQUEADA");if(!"activo".equals(c.estado))throw new IllegalArgumentException("La cuenta está deshabilitada administrativamente. Solo el Administrador Central puede reactivarla.");try(PreparedStatement ps=cn.prepareStatement("UPDATE usuarios SET intentos_fallidos=0,bloqueado_hasta=NULL,motivo_bloqueo='' WHERE id_usuario=? AND estado='activo'")){ps.setInt(1,c.usuario);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("No se pudo desbloquear la cuenta.");}try(PreparedStatement ps=cn.prepareStatement("UPDATE incidencias_soporte SET solucion=CONCAT(solucion,IF(solucion='','','\\n'),'Cuenta desbloqueada después de verificar identidad.'),estado='RESUELTA' WHERE id_incidencia=?")){ps.setInt(1,incidencia);ps.executeUpdate();}notificar(cn,c.usuario,"CUENTA_DESBLOQUEADA","Cuenta desbloqueada","Soporte Técnico desbloqueó tu cuenta mediante el ticket "+c.ticket+". Si no solicitaste esta acción, repórtala de inmediato.");registrarAuditoria(cn,incidencia,c.usuario,actor,"CUENTA_DESBLOQUEADA",c.motivo,"EXITO",c.metodo);cn.commit();}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    public String restablecerClave(int actor,int incidencia,String temporal)throws SQLException{
        Passwords.requireStrong(temporal);
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{CuentaTicket c=cuentaVerificada(cn,actor,incidencia);asegurarAccionNueva(cn,incidencia,"CLAVE_TEMPORAL_GENERADA");if(!"activo".equals(c.estado))throw new IllegalArgumentException("La cuenta está deshabilitada administrativamente. Solo el Administrador Central puede reactivarla.");try(PreparedStatement ps=cn.prepareStatement("UPDATE usuarios SET contrasena=?,intentos_fallidos=0,bloqueado_hasta=NULL,motivo_bloqueo='',requiere_cambio_clave=1,clave_temporal_expira=DATE_ADD(NOW(),INTERVAL 30 MINUTE) WHERE id_usuario=? AND estado='activo'")){parametros(ps,Passwords.hash(temporal),c.usuario);if(ps.executeUpdate()!=1)throw new IllegalArgumentException("No se pudo generar la clave temporal.");}try(PreparedStatement ps=cn.prepareStatement("UPDATE incidencias_soporte SET solucion=CONCAT(solucion,IF(solucion='','','\\n'),'Clave temporal generada con vigencia de 30 minutos; cambio obligatorio activado.'),estado='RESUELTA' WHERE id_incidencia=?")){ps.setInt(1,incidencia);ps.executeUpdate();}notificar(cn,c.usuario,"CLAVE_TEMPORAL","Contraseña temporal generada","Soporte Técnico generó una contraseña temporal para el ticket "+c.ticket+". Vence en 30 minutos y deberás cambiarla al ingresar.");registrarAuditoria(cn,incidencia,c.usuario,actor,"CLAVE_TEMPORAL_GENERADA",c.motivo,"EXITO",c.metodo);cn.commit();return ocultarCorreo(c.correo);}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    public void enviarNotificacion(int actor,int incidencia,String mensaje)throws SQLException{
        texto(mensaje,1000);try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{CuentaTicket c=cuentaVerificada(cn,actor,incidencia);notificar(cn,c.usuario,"MENSAJE_SOPORTE","Actualización de Soporte",mensaje.trim()+" · Ticket "+c.ticket);registrarAuditoria(cn,incidencia,c.usuario,actor,"NOTIFICACION_ENVIADA",c.motivo,"EXITO",c.metodo);cn.commit();}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    public List<AccionSoporte> historial(int actor)throws SQLException{
        List<AccionSoporte> lista=new ArrayList<>();String sql="SELECT a.id_auditoria,i.numero_ticket,u.nombre afectado,s.nombre responsable,a.accion,a.motivo,a.resultado,a.metodo_verificacion,a.fecha_accion FROM auditoria_soporte a JOIN incidencias_soporte i ON i.id_incidencia=a.id_incidencia JOIN usuarios u ON u.id_usuario=a.id_usuario_afectado JOIN usuarios s ON s.id_usuario=a.id_responsable WHERE a.id_responsable=? ORDER BY a.id_auditoria DESC LIMIT 100";
        try(Connection cn=Conexion.getConnection()){autorizarSoporte(cn,actor);try(PreparedStatement ps=cn.prepareStatement(sql)){ps.setInt(1,actor);try(ResultSet rs=ps.executeQuery()){while(rs.next()){AccionSoporte a=new AccionSoporte();a.setIdAuditoria(rs.getInt(1));a.setNumeroTicket(rs.getString(2));a.setUsuarioAfectado(rs.getString(3));a.setResponsable(rs.getString(4));a.setAccion(rs.getString(5));a.setMotivo(rs.getString(6));a.setResultado(rs.getString(7));a.setMetodoVerificacion(rs.getString(8));a.setFechaAccion(fecha(rs.getTimestamp(9)));lista.add(a);}}}}return lista;
    }

    public void eliminar(int actor,int id)throws SQLException{try(Connection cn=Conexion.getConnection()){autorizarSoporte(cn,actor);try(CallableStatement ps=cn.prepareCall("{CALL sp_incidencia_eliminar(?,?)}")){parametros(ps,actor,id);ps.execute();}}}

    private CuentaTicket cuentaVerificada(Connection cn,int actor,int incidencia)throws SQLException{autorizarSoporte(cn,actor);String sql="SELECT i.id_usuario_afectado,i.numero_ticket,i.metodo_verificacion,i.motivo_accion,u.estado,u.correo FROM incidencias_soporte i JOIN usuarios u ON u.id_usuario=i.id_usuario_afectado WHERE i.id_incidencia=? AND i.id_responsable=? AND i.identidad_verificada=1 AND i.categoria IN ('ACCESO','SEGURIDAD') FOR UPDATE";try(PreparedStatement ps=cn.prepareStatement(sql)){parametros(ps,incidencia,actor);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Verifica la identidad en un ticket de Acceso o Seguridad antes de continuar.");CuentaTicket c=new CuentaTicket();c.usuario=rs.getInt(1);c.ticket=rs.getString(2);c.metodo=rs.getString(3);c.motivo=rs.getString(4);c.estado=rs.getString(5);c.correo=rs.getString(6);return c;}}}
    private void ticketAsignado(Connection cn,int actor,int incidencia)throws SQLException{try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM incidencias_soporte WHERE id_incidencia=? AND id_responsable=? FOR UPDATE")){parametros(ps,incidencia,actor);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("El ticket no existe o no está asignado a tu cuenta.");}}}
    private void autorizarSoporte(Connection cn,int actor)throws SQLException{try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='SOPORTE_TECNICO' AND estado='activo'")){ps.setInt(1,actor);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La cuenta ya no tiene permisos de Soporte Técnico.");}}}
    private void registrarAuditoria(Connection cn,int incidencia,int afectado,int actor,String accion,String motivo,String resultado,String metodo)throws SQLException{try(PreparedStatement ps=cn.prepareStatement("INSERT INTO auditoria_soporte(id_incidencia,id_usuario_afectado,id_responsable,accion,motivo,resultado,metodo_verificacion) VALUES(?,?,?,?,?,?,?)")){parametros(ps,incidencia,afectado,actor,accion,motivo,resultado,metodo);ps.executeUpdate();}}
    private void asegurarAccionNueva(Connection cn,int incidencia,String accion)throws SQLException{try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM auditoria_soporte WHERE id_incidencia=? AND accion=? AND resultado='EXITO' LIMIT 1")){parametros(ps,incidencia,accion);try(ResultSet rs=ps.executeQuery()){if(rs.next())throw new IllegalArgumentException("Esta acción ya fue realizada para el ticket. Crea una nueva incidencia si necesitas repetirla.");}}}
    private void notificar(Connection cn,int usuario,String tipo,String titulo,String mensaje)throws SQLException{try(PreparedStatement ps=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) VALUES(?,?,?,?)")){parametros(ps,usuario,tipo,titulo,mensaje);ps.executeUpdate();}}
    private void asignarTicket(Connection cn,int id)throws SQLException{try(PreparedStatement ps=cn.prepareStatement("UPDATE incidencias_soporte SET numero_ticket=CONCAT('INC-',LPAD(id_incidencia,8,'0')) WHERE id_incidencia=?")){ps.setInt(1,id);ps.executeUpdate();}}
    private List<IncidenciaSoporte> filas(String sql,Object... valores)throws SQLException{List<IncidenciaSoporte> lista=new ArrayList<>();try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){parametros(ps,valores);try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapear(rs));}}return lista;}
    private List<IncidenciaSoporte> listarProcedimiento(String modo,int actor)throws SQLException{List<IncidenciaSoporte> lista=new ArrayList<>();try(Connection cn=Conexion.getConnection();CallableStatement ps=cn.prepareCall("{CALL sp_incidencia_listar(?,?)}")){ps.setString(1,modo);ps.setInt(2,actor);try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapear(rs));}}return lista;}
    private IncidenciaSoporte mapear(ResultSet rs)throws SQLException{IncidenciaSoporte i=new IncidenciaSoporte();i.setIdIncidencia(rs.getInt("id_incidencia"));i.setIdCreador(enteroNullable(rs,"id_creador"));i.setIdResponsable(rs.getInt("id_responsable"));i.setIdUsuarioAfectado(enteroNullable(rs,"id_usuario_afectado"));i.setCorreo(rs.getString("correo"));i.setCorreoOculto(ocultarCorreo(rs.getString("correo")));i.setTitulo(rs.getString("titulo"));i.setDescripcion(rs.getString("descripcion"));i.setOrigen(rs.getString("origen"));i.setCategoria(rs.getString("categoria"));i.setPrioridad(rs.getString("prioridad"));i.setDecision(rs.getString("decision"));i.setEstado(rs.getString("estado"));i.setSolucion(rs.getString("solucion"));i.setNombreUsuarioAfectado(rs.getString("nombre_usuario_afectado"));i.setNombreResponsable(rs.getString("nombre_responsable"));i.setFechaCreacion(fecha(rs.getTimestamp("fecha_creacion")));i.setFechaActualizacion(fecha(rs.getTimestamp("fecha_actualizacion")));i.setNumeroTicket(rs.getString("numero_ticket"));i.setIdentidadVerificada(rs.getBoolean("identidad_verificada"));i.setMetodoVerificacion(rs.getString("metodo_verificacion"));i.setMotivoAccion(rs.getString("motivo_accion"));i.setFechaVerificacion(fecha(rs.getTimestamp("fecha_verificacion")));i.setEstadoCuenta(rs.getString("estado_cuenta"));i.setIntentosFallidos(rs.getInt("intentos_fallidos"));i.setBloqueadoHasta(fecha(rs.getTimestamp("bloqueado_hasta")));i.setMotivoBloqueo(rs.getString("motivo_bloqueo"));return i;}
    private static String ocultarCorreo(String correo){if(correo==null||correo.isEmpty())return "";int a=correo.indexOf('@');if(a<1)return "***";String local=correo.substring(0,a),dominio=correo.substring(a);return local.substring(0,1)+"***"+(local.length()>1?local.substring(local.length()-1):"")+dominio;}
    private Integer enteroNullable(ResultSet rs,String columna)throws SQLException{int valor=rs.getInt(columna);return rs.wasNull()?null:valor;}
    private java.time.LocalDateTime fecha(Timestamp t){return t==null?null:t.toLocalDateTime();}
    private void parametros(PreparedStatement ps,Object... valores)throws SQLException{for(int i=0;i<valores.length;i++)ps.setObject(i+1,valores[i]);}
    private void texto(String valor,int max){if(valor==null||valor.trim().isEmpty()||valor.length()>max)throw new IllegalArgumentException("Completa los campos requeridos.");}
    private void opcional(String valor,int max){if(valor==null||valor.length()>max)throw new IllegalArgumentException("El texto es demasiado extenso.");}
    private void prioridad(String p){if(!Arrays.asList("BAJA","MEDIA","ALTA","URGENTE").contains(p))throw new IllegalArgumentException("Prioridad no válida.");}
    private void categoria(String c){if(!Arrays.asList("SEGURIDAD","ACCESO","INFRACCION","TECNICO","OTRO").contains(c))throw new IllegalArgumentException("Categoría no válida.");}
    private void metodo(String m){if(!Arrays.asList("CORREO_REGISTRADO","DOCUMENTO_REGISTRADO","VIDEOLLAMADA","OTRO").contains(m))throw new IllegalArgumentException("Selecciona un método de verificación válido.");}
    private static final class CuentaTicket{int usuario;String ticket,metodo,motivo,estado,correo;}
}
