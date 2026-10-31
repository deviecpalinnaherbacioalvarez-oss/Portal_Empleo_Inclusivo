package com.incluyelab.service;

/** Evita atribuir validación oficial cuando el proyecto no tiene un servicio configurado. */
public final class VerificadorConadisNoConfigurado implements VerificadorConadisOficial {
    @Override public boolean estaDisponible() { return false; }
    @Override public Resultado verificar(String rui, String dni) { return Resultado.NO_DISPONIBLE; }
}
