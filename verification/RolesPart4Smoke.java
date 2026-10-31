import com.incluyelab.security.Permisos;
import com.incluyelab.security.Roles;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public final class RolesPart4Smoke {
    private static int pruebas;

    public static void main(String[] args) {
        Set<String> roles = new HashSet<>(Arrays.asList(
                Roles.POSTULANTE, Roles.EMPRESA, Roles.RECURSOS_HUMANOS,
                Roles.SOPORTE_TECNICO, Roles.ADMINISTRADOR_CENTRAL));
        verificar(roles.size() == 5, "Deben existir exactamente cinco identificadores de rol");
        verificar(Roles.esRegistroPublico(Roles.POSTULANTE), "Postulante puede registrarse publicamente");
        verificar(Roles.esRegistroPublico(Roles.EMPRESA), "Empresa puede registrarse publicamente");
        verificar(!Roles.esRegistroPublico(Roles.RECURSOS_HUMANOS), "RRHH no puede registrarse publicamente");
        verificar(!Roles.esRegistroPublico(Roles.SOPORTE_TECNICO), "Soporte no puede registrarse publicamente");
        verificar(!Roles.esRegistroPublico(Roles.ADMINISTRADOR_CENTRAL), "Administrador no puede registrarse publicamente");
        verificar(!Roles.esValido("VISITANTE"), "No se admite un sexto rol");

        permitir(Roles.POSTULANTE, "/postulante", "/postular", "/perfil-profesional", "/verificacion-conadis");
        negar(Roles.POSTULANTE, "/admin", "/oferta", "/revision-conadis", "/soporte-tecnico");
        permitir(Roles.EMPRESA, "/empresa", "/empresa/perfil", "/empresa/candidato", "/empresa/postulacion", "/oferta");
        negar(Roles.EMPRESA, "/admin", "/postular", "/revision-conadis", "/soporte-tecnico");
        permitir(Roles.RECURSOS_HUMANOS, "/recursos-humanos", "/recursos-humanos/candidato", "/revision-conadis");
        negar(Roles.RECURSOS_HUMANOS, "/admin", "/oferta", "/soporte-tecnico", "/postular");
        permitir(Roles.SOPORTE_TECNICO, "/soporte-tecnico");
        negar(Roles.SOPORTE_TECNICO, "/admin", "/revision-conadis", "/oferta", "/postular");
        permitir(Roles.ADMINISTRADOR_CENTRAL, "/admin", "/revision-empresa");
        negar(Roles.ADMINISTRADOR_CENTRAL, "/recursos-humanos", "/revision-conadis", "/soporte-tecnico", "/oferta", "/postular");

        verificar(Permisos.puedeAcceder("/inicio", null), "El inicio sigue siendo publico");
        System.out.println("OK - " + pruebas + " comprobaciones de roles y rutas superadas.");
    }

    private static void permitir(String rol, String... rutas) {
        for (String ruta : rutas) verificar(Permisos.puedeAcceder(ruta, rol), rol + " debe acceder a " + ruta);
    }

    private static void negar(String rol, String... rutas) {
        for (String ruta : rutas) verificar(!Permisos.puedeAcceder(ruta, rol), rol + " no debe acceder a " + ruta);
    }

    private static void verificar(boolean condicion, String mensaje) {
        pruebas++;
        if (!condicion) throw new AssertionError(mensaje);
    }
}
