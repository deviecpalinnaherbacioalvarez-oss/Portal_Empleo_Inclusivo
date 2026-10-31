package com.incluyelab.service;

/** Punto de integración para un servicio oficial de CONADIS cuando esté disponible. */
public interface VerificadorConadisOficial {
    enum Resultado { COINCIDE, NO_COINCIDE, NO_DISPONIBLE }

    boolean estaDisponible();
    Resultado verificar(String rui, String dni);
}
