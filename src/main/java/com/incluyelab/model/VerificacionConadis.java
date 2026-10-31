package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** Solicitud de verificacion del carnet CONADIS de un postulante. */
public class VerificacionConadis implements Serializable {
    private int idVerificacion;
    private int idUsuario;
    private int idDiscapacidad;
    private String discapacidad;
    private boolean revisionRrhh;
    public int getIdDiscapacidad(){return idDiscapacidad;}
    public void setIdDiscapacidad(int id){idDiscapacidad=id;}
    public String getDiscapacidad(){return discapacidad;}
    public void setDiscapacidad(String d){discapacidad=d;}
    public boolean isRevisionRrhh(){return revisionRrhh;}
    public void setRevisionRrhh(boolean v){revisionRrhh=v;}
    private String nombreCuenta;
    private String correoCuenta;
    private String rui;
    private String dni;
    private String apellidos;
    private String nombres;
    private LocalDate fechaCaducidad;
    private String carnetArchivo;
    private String estado;
    private String metodo;
    private String observacionSistema;
    private String motivo;
    private String nombreRevisor;
    private int envios;
    private LocalDateTime fechaEnvio;
    private LocalDateTime fechaRevision;

    /** Mantiene compatibilidad con registros antiguos cuya fecha ya caducó. */
    public String getEstadoEfectivo() {
        if ("APROBADA".equals(estado) && fechaCaducidad != null && fechaCaducidad.isBefore(LocalDate.now())) return "VENCIDA";
        return estado;
    }

    public int getIdVerificacion() { return idVerificacion; }
    public void setIdVerificacion(int idVerificacion) { this.idVerificacion = idVerificacion; }
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    public String getNombreCuenta() { return nombreCuenta; }
    public void setNombreCuenta(String nombreCuenta) { this.nombreCuenta = nombreCuenta; }
    public String getCorreoCuenta() { return correoCuenta; }
    public void setCorreoCuenta(String correoCuenta) { this.correoCuenta = correoCuenta; }
    public String getRui() { return rui; }
    public void setRui(String rui) { this.rui = rui; }
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }
    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }
    public LocalDate getFechaCaducidad() { return fechaCaducidad; }
    public void setFechaCaducidad(LocalDate fechaCaducidad) { this.fechaCaducidad = fechaCaducidad; }
    public String getCarnetArchivo() { return carnetArchivo; }
    public void setCarnetArchivo(String carnetArchivo) { this.carnetArchivo = carnetArchivo; }
    public boolean isTieneImagen() { return carnetArchivo != null && !carnetArchivo.isEmpty(); }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getMetodo() { return metodo; }
    public void setMetodo(String metodo) { this.metodo = metodo; }
    public String getObservacionSistema() { return observacionSistema; }
    public void setObservacionSistema(String observacionSistema) { this.observacionSistema = observacionSistema; }
    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
    public String getNombreRevisor() { return nombreRevisor; }
    public void setNombreRevisor(String nombreRevisor) { this.nombreRevisor = nombreRevisor; }
    public int getEnvios() { return envios; }
    public void setEnvios(int envios) { this.envios = envios; }
    public LocalDateTime getFechaEnvio() { return fechaEnvio; }
    public void setFechaEnvio(LocalDateTime fechaEnvio) { this.fechaEnvio = fechaEnvio; }
    public LocalDateTime getFechaRevision() { return fechaRevision; }
    public void setFechaRevision(LocalDateTime fechaRevision) { this.fechaRevision = fechaRevision; }
}
