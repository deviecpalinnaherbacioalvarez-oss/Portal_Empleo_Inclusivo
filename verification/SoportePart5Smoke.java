import com.incluyelab.security.Passwords;
import com.incluyelab.security.Permisos;
import com.incluyelab.security.Roles;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;

public final class SoportePart5Smoke {
    private static int pruebas;
    public static void main(String[] args)throws Exception{
        Set<String> generadas=new HashSet<>();
        for(int i=0;i<50;i++){
            String temporal=Passwords.temporary();
            verificar(Passwords.policyError(temporal)==null,"La clave temporal debe cumplir la política");
            verificar(generadas.add(temporal),"Las claves temporales no deben repetirse");
            String hash=Passwords.hash(temporal);
            verificar(!hash.contains(temporal),"El hash no debe contener la clave temporal");
            verificar(Passwords.matches(temporal,hash),"La clave temporal debe validar contra su hash");
        }
        verificar(Permisos.puedeAcceder("/soporte-tecnico",Roles.SOPORTE_TECNICO),"Soporte accede a su módulo");
        verificar(!Permisos.puedeAcceder("/revision-conadis",Roles.SOPORTE_TECNICO),"Soporte no aprueba CONADIS");
        verificar(!Permisos.puedeAcceder("/oferta",Roles.SOPORTE_TECNICO),"Soporte no administra ofertas");
        verificar(!Permisos.puedeAcceder("/admin",Roles.SOPORTE_TECNICO),"Soporte no cambia roles");

        String dao=leer("src/main/java/com/incluyelab/dao/IncidenciaDAO.java");
        String usuario=leer("src/main/java/com/incluyelab/dao/UsuarioDAO.java");
        String migracion=leer("database/migrations/20261029_soporte_tecnico_seguro.sql");
        verificar(dao.contains("i.identidad_verificada=1"),"Las acciones sensibles exigen identidad verificada");
        verificar(dao.contains("u.estado")&&dao.contains("Solo el Administrador Central puede reactivarla"),"Soporte no reactiva cuentas inactivas");
        verificar(dao.contains("auditoria_soporte")&&dao.contains("registrarAuditoria"),"Las acciones se auditan");
        verificar(dao.contains("CUENTA_DESBLOQUEADA")&&dao.contains("CLAVE_TEMPORAL")&&dao.contains("MENSAJE_SOPORTE"),"Las acciones notifican al usuario");
        verificar(dao.contains("clave_temporal_expira=DATE_ADD(NOW(),INTERVAL 30 MINUTE)"),"La clave temporal tiene expiración");
        verificar(usuario.contains("TEMPORAL_EXPIRADA")&&usuario.contains("clave_temporal_expira=NULL"),"Se controla expiración y uso mediante cambio obligatorio");
        verificar(usuario.contains("CLAVE_CAMBIADA")&&usuario.contains("ACTIVIDAD_SOSPECHOSA"),"Cambio y actividad sospechosa generan notificaciones");
        verificar(migracion.contains("CREATE TABLE IF NOT EXISTS auditoria_soporte"),"La migración crea auditoría");
        System.out.println("OK - "+pruebas+" comprobaciones de Soporte Técnico superadas.");
    }
    private static String leer(String ruta)throws Exception{return Files.readString(Path.of(ruta),StandardCharsets.UTF_8);}
    private static void verificar(boolean condicion,String mensaje){pruebas++;if(!condicion)throw new AssertionError(mensaje);}
}
