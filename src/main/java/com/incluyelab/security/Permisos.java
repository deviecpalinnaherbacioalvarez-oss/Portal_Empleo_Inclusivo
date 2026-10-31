package com.incluyelab.security;

/** Matriz de autorizacion por ruta; las comprobaciones se ejecutan en el filtro. */
public final class Permisos {
    private Permisos() { }

    public static String rolRequerido(String ruta) {
        if (ruta == null) return null;
        if (ruta.equals("/revision-empresa") || ruta.equals("/admin") || ruta.equals("/admin.jsp"))
            return Roles.ADMINISTRADOR_CENTRAL;
        if (ruta.equals("/revision-conadis") || ruta.equals("/recursos-humanos") || ruta.equals("/recursos-humanos/candidato"))
            return Roles.RECURSOS_HUMANOS;
        if (ruta.equals("/empresa/perfil") || ruta.equals("/empresa/candidato") || ruta.equals("/empresa/postulacion")
                || ruta.equals("/empresa") || ruta.equals("/empresa.jsp") || ruta.equals("/oferta"))
            return Roles.EMPRESA;
        if (ruta.equals("/postulante") || ruta.equals("/postulante.jsp") || ruta.equals("/postular")
                || ruta.equals("/perfil-profesional") || ruta.equals("/verificacion-conadis"))
            return Roles.POSTULANTE;
        if (ruta.equals("/soporte-tecnico")) return Roles.SOPORTE_TECNICO;
        return null;
    }

    public static boolean puedeAcceder(String ruta, String rol) {
        String requerido = rolRequerido(ruta);
        return requerido == null || requerido.equals(rol);
    }
}
