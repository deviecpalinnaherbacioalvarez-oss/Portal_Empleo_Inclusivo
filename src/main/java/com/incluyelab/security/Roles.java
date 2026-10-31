package com.incluyelab.security;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/** Identificadores persistidos de los cinco roles de IncluyeLab. */
public final class Roles {
    public static final String POSTULANTE = "POSTULANTE";
    public static final String EMPRESA = "EMPRESA";
    public static final String RECURSOS_HUMANOS = "RECURSOS_HUMANOS";
    public static final String SOPORTE_TECNICO = "SOPORTE_TECNICO";

    // ADMIN es el identificador historico en MySQL para ADMINISTRADOR_CENTRAL.
    public static final String ADMINISTRADOR_CENTRAL = "ADMIN";

    private static final Set<String> TODOS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            POSTULANTE, EMPRESA, RECURSOS_HUMANOS, SOPORTE_TECNICO, ADMINISTRADOR_CENTRAL)));
    private static final Set<String> PUBLICOS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            POSTULANTE, EMPRESA)));
    private static final Set<String> INTERNOS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            RECURSOS_HUMANOS, SOPORTE_TECNICO, ADMINISTRADOR_CENTRAL)));

    private Roles() { }

    public static boolean esValido(String rol) { return TODOS.contains(rol); }
    public static boolean esRegistroPublico(String rol) { return PUBLICOS.contains(rol); }
    public static boolean esInterno(String rol) { return INTERNOS.contains(rol); }
}
