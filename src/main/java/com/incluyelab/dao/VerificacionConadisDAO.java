package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.HistorialVerificacionConadis;
import com.incluyelab.model.VerificacionConadis;
import com.incluyelab.security.ConadisValidator;
import com.incluyelab.service.VerificadorConadisNoConfigurado;
import com.incluyelab.service.VerificadorConadisOficial;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class VerificacionConadisDAO {
    public static final String ESTADO_SQL = "CASE WHEN u.rol<>'POSTULANTE' THEN 'NO_APLICA' WHEN v.id_verificacion IS NULL THEN 'SIN_ENVIAR' "
            + "WHEN v.estado='APROBADA' AND v.fecha_caducidad<CURDATE() THEN 'VENCIDA' ELSE v.estado END";
    private static final String SELECT = "SELECT v.*,u.nombre nombre_cuenta,u.correo correo_cuenta,r.nombre nombre_revisor,d.nombre nombre_discapacidad "
            + "FROM verificaciones_conadis v JOIN usuarios u ON u.id_usuario=v.id_usuario LEFT JOIN usuarios r ON r.id_usuario=v.id_revisor LEFT JOIN discapacidades d ON d.id_discapacidad=v.id_discapacidad ";
    private static final List<String> ESTADOS = Arrays.asList("PENDIENTE","APROBADA","RECHAZADA","VENCIDA");
    private final VerificadorConadisOficial verificadorOficial;

    public VerificacionConadisDAO() { this(new VerificadorConadisNoConfigurado()); }
    public VerificacionConadisDAO(VerificadorConadisOficial verificadorOficial) { this.verificadorOficial=verificadorOficial; }

    public static final class ResultadoEnvio {
        private final String estado;
        ResultadoEnvio(String estado) { this.estado=estado; }
        public String getEstado() { return estado; }
    }

    public String estado(int idUsuario) throws SQLException {
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement("SELECT "+ESTADO_SQL+" FROM usuarios u LEFT JOIN verificaciones_conadis v ON v.id_usuario=u.id_usuario WHERE u.id_usuario=?")){
            ps.setInt(1,idUsuario);
            try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getString(1):"SIN_ENVIAR";}
        }
    }

    public VerificacionConadis obtenerPorUsuario(int idUsuario)throws SQLException {
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(SELECT+"WHERE v.id_usuario=?")){
            ps.setInt(1,idUsuario);
            try(ResultSet rs=ps.executeQuery()){return rs.next()?mapear(rs):null;}
        }
    }

    public List<VerificacionConadis> listar()throws SQLException { return listar("",""); }

    public List<VerificacionConadis> listar(String estado,String busqueda)throws SQLException {
        String filtroEstado=estado==null?"":estado.trim().toUpperCase();
        if(!filtroEstado.isEmpty()&&!ESTADOS.contains(filtroEstado))throw new IllegalArgumentException("Estado de verificación no válido.");
        String texto=busqueda==null?"":busqueda.trim();
        if(texto.length()>120)throw new IllegalArgumentException("La búsqueda es demasiado extensa.");
        StringBuilder sql=new StringBuilder(SELECT).append("WHERE 1=1 ");
        List<Object> valores=new ArrayList<>();
        if(!filtroEstado.isEmpty()){sql.append("AND ").append(ESTADO_SQL).append("=? ");valores.add(filtroEstado);}
        if(!texto.isEmpty()){sql.append("AND (u.nombre LIKE ? OR u.correo LIKE ? OR COALESCE(v.dni,'') LIKE ? OR v.rui LIKE ?) ");String like="%"+texto+"%";for(int i=0;i<4;i++)valores.add(like);}
        sql.append("ORDER BY FIELD(").append(ESTADO_SQL).append(",'PENDIENTE','RECHAZADA','VENCIDA','APROBADA'),COALESCE(v.fecha_revision,v.fecha_envio) DESC LIMIT 500");
        List<VerificacionConadis> lista=new ArrayList<>();
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql.toString())){
            parametros(ps,valores.toArray());
            try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapear(rs));}
        }
        return lista;
    }

    public List<HistorialVerificacionConadis> historial(int idVerificacion)throws SQLException {
        List<HistorialVerificacionConadis> lista=new ArrayList<>();
        String sql="SELECT h.id_historial,h.id_verificacion,h.estado,h.motivo,h.accion,h.fecha_evento,r.nombre nombre_revisor FROM historial_verificaciones_conadis h LEFT JOIN usuarios r ON r.id_usuario=h.id_revisor WHERE h.id_verificacion=? ORDER BY h.id_historial DESC";
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement(sql)){
            ps.setInt(1,idVerificacion);
            try(ResultSet rs=ps.executeQuery()){while(rs.next()){HistorialVerificacionConadis h=new HistorialVerificacionConadis();h.setIdHistorial(rs.getInt("id_historial"));h.setIdVerificacion(rs.getInt("id_verificacion"));h.setEstado(rs.getString("estado"));h.setMotivo(rs.getString("motivo"));h.setAccion(rs.getString("accion"));h.setNombreRevisor(rs.getString("nombre_revisor"));h.setFechaEvento(rs.getObject("fecha_evento",LocalDateTime.class));lista.add(h);}}
        }
        return lista;
    }

    public int contarPendientes()throws SQLException {
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement("SELECT COUNT(*) FROM verificaciones_conadis WHERE estado='PENDIENTE'");ResultSet rs=ps.executeQuery()){return rs.next()?rs.getInt(1):0;}
    }

    public ResultadoEnvio enviarSolicitud(int usuario,String rui,String archivo)throws SQLException {
        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{ResultadoEnvio resultado=enviarSolicitud(cn,usuario,rui,archivo);cn.commit();return resultado;}catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    ResultadoEnvio enviarSolicitud(Connection cn,int usuario,String rui,String archivo)throws SQLException {
        rui=ConadisValidator.rui(rui);
        if(archivo==null||!archivo.matches("[a-f0-9-]{36}\\.jpg"))throw new IllegalArgumentException("Adjunta una fotografía válida del carnet.");
        try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='POSTULANTE' AND estado='activo' FOR UPDATE")){ps.setInt(1,usuario);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La cuenta postulante no está disponible.");}}
        try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM verificaciones_conadis WHERE id_usuario<>? AND rui=? LIMIT 1")){ps.setInt(1,usuario);ps.setString(2,rui);try(ResultSet rs=ps.executeQuery()){if(rs.next())throw new IllegalArgumentException("El RUI ingresado ya está asociado a otra cuenta.");}}

        Integer idVerificacion=null;String estadoActual=null;LocalDate caducidad=null;
        try(PreparedStatement ps=cn.prepareStatement("SELECT id_verificacion,estado,fecha_caducidad FROM verificaciones_conadis WHERE id_usuario=? FOR UPDATE")){ps.setInt(1,usuario);try(ResultSet rs=ps.executeQuery()){if(rs.next()){idVerificacion=rs.getInt(1);estadoActual=rs.getString(2);caducidad=rs.getObject(3,LocalDate.class);}}}
        if("APROBADA".equals(estadoActual)&&caducidad!=null&&caducidad.isBefore(LocalDate.now()))estadoActual="VENCIDA";
        if(idVerificacion!=null&&!"RECHAZADA".equals(estadoActual)&&!"VENCIDA".equals(estadoActual))throw new IllegalArgumentException("Tu solicitud está pendiente o aprobada y no admite un nuevo envío.");

        if(idVerificacion==null){
            try(PreparedStatement ps=cn.prepareStatement("INSERT INTO verificaciones_conadis(id_usuario,rui,carnet_archivo,estado,observacion_sistema,revision_rrhh,fecha_envio) VALUES(?,?,?,'PENDIENTE','Pendiente de revisión manual por Recursos Humanos.',1,NOW())",Statement.RETURN_GENERATED_KEYS)){ps.setInt(1,usuario);ps.setString(2,rui);ps.setString(3,archivo);ps.executeUpdate();try(ResultSet rs=ps.getGeneratedKeys()){if(!rs.next())throw new SQLException("No se generó la solicitud.");idVerificacion=rs.getInt(1);}}
        }else{
            registrarHistorial(cn,idVerificacion,estadoActual,"Solicitud anterior conservada antes del reenvío",null,"ARCHIVADA_POR_REENVIO");
            try(PreparedStatement ps=cn.prepareStatement("UPDATE verificaciones_conadis SET rui=?,carnet_archivo=?,dni=NULL,apellidos=NULL,nombres=NULL,fecha_caducidad=NULL,id_discapacidad=NULL,estado='PENDIENTE',metodo=NULL,motivo='',observacion_sistema='Pendiente de revisión manual por Recursos Humanos.',id_revisor=NULL,fecha_revision=NULL,envios=envios+1,fecha_envio=NOW(),revision_rrhh=1 WHERE id_verificacion=?")){ps.setString(1,rui);ps.setString(2,archivo);ps.setInt(3,idVerificacion);ps.executeUpdate();}
        }
        registrarHistorial(cn,idVerificacion,"PENDIENTE","",null,"SOLICITUD_ENVIADA");
        return new ResultadoEnvio("PENDIENTE");
    }

    public List<String[]> discapacidades()throws SQLException {
        List<String[]> lista=new ArrayList<>();
        try(Connection cn=Conexion.getConnection();PreparedStatement ps=cn.prepareStatement("SELECT id_discapacidad,nombre FROM discapacidades ORDER BY id_discapacidad");ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(new String[]{rs.getString(1),rs.getString(2)});}
        return lista;
    }

    public void revisar(int usuario,String decision,String motivo,int revisor,String rui,String dni,String apellidos,String nombres,String fecha,int discapacidad)throws SQLException {
        boolean aprobar="aprobar".equals(decision);boolean rechazar="rechazar".equals(decision);boolean vencer="vencer".equals(decision);
        if(!aprobar&&!rechazar&&!vencer)throw new IllegalArgumentException("Selecciona una decisión válida.");
        String observacion=motivo==null?"":motivo.trim();
        if(observacion.length()>1000||((rechazar||vencer)&&observacion.length()<10))throw new IllegalArgumentException("Explica el rechazo o vencimiento con entre 10 y 1000 caracteres.");
        LocalDate caducidad=null;
        if(aprobar){rui=ConadisValidator.rui(rui);dni=ConadisValidator.dni(dni);apellidos=ConadisValidator.nombre(apellidos,"Apellidos");nombres=ConadisValidator.nombre(nombres,"Nombres");caducidad=ConadisValidator.caducidad(fecha);if(discapacidad<1||discapacidad>13)throw new IllegalArgumentException("Selecciona una discapacidad del catálogo.");}

        try(Connection cn=Conexion.getConnection()){cn.setAutoCommit(false);try{
            autorizarRevisor(cn,revisor);
            int idVerificacion;String ruiRegistrado;String estadoActual;String archivo;
            try(PreparedStatement ps=cn.prepareStatement("SELECT v.id_verificacion,v.rui,v.estado,v.carnet_archivo FROM verificaciones_conadis v JOIN usuarios u ON u.id_usuario=v.id_usuario WHERE v.id_usuario=? AND u.rol='POSTULANTE' AND u.estado='activo' FOR UPDATE")){ps.setInt(1,usuario);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La solicitud no está disponible.");idVerificacion=rs.getInt(1);ruiRegistrado=rs.getString(2);estadoActual=rs.getString(3);archivo=rs.getString(4);}}
            if(aprobar||rechazar){if(!"PENDIENTE".equals(estadoActual))throw new IllegalArgumentException("La solicitud ya fue resuelta.");}
            if(vencer&&!"PENDIENTE".equals(estadoActual)&&!"APROBADA".equals(estadoActual))throw new IllegalArgumentException("Solo una solicitud pendiente o aprobada puede marcarse como vencida.");
            if(aprobar){
                if(archivo==null||archivo.isEmpty())throw new IllegalArgumentException("No se puede aprobar sin fotografía del carnet.");
                if(!rui.equals(ruiRegistrado))throw new IllegalArgumentException("El RUI revisado no coincide con el enviado por el postulante.");
                try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM verificaciones_conadis WHERE id_usuario<>? AND (rui=? OR dni=?) LIMIT 1")){ps.setInt(1,usuario);ps.setString(2,rui);ps.setString(3,dni);try(ResultSet rs=ps.executeQuery()){if(rs.next())throw new IllegalArgumentException("El RUI o DNI ya está asociado a otra cuenta.");}}
                if(verificadorOficial.estaDisponible()&&verificadorOficial.verificar(rui,dni)==VerificadorConadisOficial.Resultado.NO_COINCIDE)throw new IllegalArgumentException("El servicio oficial configurado no confirmó los datos. No se puede aprobar.");
                String tipo;try(PreparedStatement ps=cn.prepareStatement("SELECT nombre FROM discapacidades WHERE id_discapacidad=?")){ps.setInt(1,discapacidad);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Discapacidad no válida.");tipo=rs.getString(1);}}
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO perfiles_postulantes(id_usuario,dni,tipo_discapacidad,id_discapacidad) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE dni=VALUES(dni),tipo_discapacidad=VALUES(tipo_discapacidad),id_discapacidad=VALUES(id_discapacidad)")){ps.setInt(1,usuario);ps.setString(2,dni);ps.setString(3,tipo);ps.setInt(4,discapacidad);ps.executeUpdate();}
                try(PreparedStatement ps=cn.prepareStatement("UPDATE usuarios SET nombre=? WHERE id_usuario=?")){ps.setString(1,nombres+" "+apellidos);ps.setInt(2,usuario);ps.executeUpdate();}
                try(PreparedStatement ps=cn.prepareStatement("UPDATE verificaciones_conadis SET dni=?,apellidos=?,nombres=?,fecha_caducidad=?,id_discapacidad=?,estado='APROBADA',metodo='MANUAL',motivo=?,id_revisor=?,fecha_revision=NOW(),revision_rrhh=1,observacion_sistema='Revisión manual completada por Recursos Humanos; no equivale a una consulta oficial en línea.' WHERE id_verificacion=?")){ps.setString(1,dni);ps.setString(2,apellidos);ps.setString(3,nombres);ps.setObject(4,caducidad);ps.setInt(5,discapacidad);ps.setString(6,observacion);ps.setInt(7,revisor);ps.setInt(8,idVerificacion);ps.executeUpdate();}
                registrarHistorial(cn,idVerificacion,"APROBADA",observacion,revisor,"REVISION_MANUAL");
            }else{
                String nuevoEstado=rechazar?"RECHAZADA":"VENCIDA";
                try(PreparedStatement ps=cn.prepareStatement("UPDATE verificaciones_conadis SET estado=?,metodo='MANUAL',motivo=?,id_revisor=?,fecha_revision=NOW(),revision_rrhh=1,observacion_sistema=? WHERE id_verificacion=?")){ps.setString(1,nuevoEstado);ps.setString(2,observacion);ps.setInt(3,revisor);ps.setString(4,rechazar?"RRHH solicitó corregir y reenviar los datos.":"RRHH marcó la verificación como vencida; se requiere un nuevo envío.");ps.setInt(5,idVerificacion);ps.executeUpdate();}
                registrarHistorial(cn,idVerificacion,nuevoEstado,observacion,revisor,"REVISION_MANUAL");
            }
            notificar(cn,usuario,aprobar?"RRHH aprobó tu verificación CONADIS.":(rechazar?"RRHH rechazó tu verificación. Motivo: ":"Tu verificación fue marcada como vencida. Motivo: ")+observacion);
            cn.commit();
        }catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}}
    }

    private void autorizarRevisor(Connection cn,int revisor)throws SQLException {
        try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM usuarios WHERE id_usuario=? AND rol='RECURSOS_HUMANOS' AND estado='activo' FOR UPDATE")){ps.setInt(1,revisor);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Solo Recursos Humanos activo puede resolver verificaciones CONADIS.");}}
    }
    private void registrarHistorial(Connection cn,int id,String estado,String motivo,Integer revisor,String accion)throws SQLException {
        try(PreparedStatement ps=cn.prepareStatement("INSERT INTO historial_verificaciones_conadis(id_verificacion,id_usuario,rui,carnet_archivo,estado,motivo,id_revisor,accion,fecha_evento) SELECT id_verificacion,id_usuario,rui,carnet_archivo,?,?,?,?,NOW() FROM verificaciones_conadis WHERE id_verificacion=?")){ps.setString(1,estado);ps.setString(2,motivo==null?"":motivo);if(revisor==null)ps.setNull(3,java.sql.Types.INTEGER);else ps.setInt(3,revisor);ps.setString(4,accion);ps.setInt(5,id);ps.executeUpdate();}
    }
    private void notificar(Connection cn,int usuario,String mensaje)throws SQLException {
        if(mensaje.length()>1000)mensaje=mensaje.substring(0,1000);
        try(PreparedStatement ps=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) VALUES(?,'CONADIS_ESTADO','Estado de verificación CONADIS',?)")){ps.setInt(1,usuario);ps.setString(2,mensaje);ps.executeUpdate();}
    }
    private void parametros(PreparedStatement ps,Object... valores)throws SQLException {for(int i=0;i<valores.length;i++)ps.setObject(i+1,valores[i]);}

    private VerificacionConadis mapear(ResultSet rs)throws SQLException {
        VerificacionConadis v=new VerificacionConadis();
        v.setIdVerificacion(rs.getInt("id_verificacion"));v.setIdUsuario(rs.getInt("id_usuario"));v.setIdDiscapacidad(rs.getInt("id_discapacidad"));v.setDiscapacidad(rs.getString("nombre_discapacidad"));v.setRevisionRrhh(rs.getBoolean("revision_rrhh"));v.setNombreCuenta(rs.getString("nombre_cuenta"));v.setCorreoCuenta(rs.getString("correo_cuenta"));v.setRui(rs.getString("rui"));v.setDni(rs.getString("dni"));v.setApellidos(rs.getString("apellidos"));v.setNombres(rs.getString("nombres"));v.setFechaCaducidad(rs.getObject("fecha_caducidad",LocalDate.class));v.setCarnetArchivo(rs.getString("carnet_archivo"));v.setEstado(rs.getString("estado"));v.setMetodo(rs.getString("metodo"));v.setObservacionSistema(rs.getString("observacion_sistema"));v.setMotivo(rs.getString("motivo"));v.setNombreRevisor(rs.getString("nombre_revisor"));v.setEnvios(rs.getInt("envios"));v.setFechaEnvio(rs.getObject("fecha_envio",LocalDateTime.class));v.setFechaRevision(rs.getObject("fecha_revision",LocalDateTime.class));return v;
    }
}
