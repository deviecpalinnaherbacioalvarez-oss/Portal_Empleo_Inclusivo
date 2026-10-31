package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class HistorialVerificacionConadis implements Serializable {
    private int idHistorial;
    private int idVerificacion;
    private String estado;
    private String motivo;
    private String nombreRevisor;
    private String accion;
    private LocalDateTime fechaEvento;

    public int getIdHistorial() { return idHistorial; }
    public void setIdHistorial(int idHistorial) { this.idHistorial = idHistorial; }
    public int getIdVerificacion() { return idVerificacion; }
    public void setIdVerificacion(int idVerificacion) { this.idVerificacion = idVerificacion; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
    public String getNombreRevisor() { return nombreRevisor; }
    public void setNombreRevisor(String nombreRevisor) { this.nombreRevisor = nombreRevisor; }
    public String getAccion() { return accion; }
    public void setAccion(String accion) { this.accion = accion; }
    public LocalDateTime getFechaEvento() { return fechaEvento; }
    public void setFechaEvento(LocalDateTime fechaEvento) { this.fechaEvento = fechaEvento; }
}
