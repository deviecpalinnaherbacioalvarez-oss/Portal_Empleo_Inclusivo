package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class AccionSoporte implements Serializable {
    private static final DateTimeFormatter FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private int idAuditoria;
    private String numeroTicket;
    private String usuarioAfectado;
    private String responsable;
    private String accion;
    private String motivo;
    private String resultado;
    private String metodoVerificacion;
    private LocalDateTime fechaAccion;

    public int getIdAuditoria() { return idAuditoria; }
    public void setIdAuditoria(int idAuditoria) { this.idAuditoria = idAuditoria; }
    public String getNumeroTicket() { return numeroTicket; }
    public void setNumeroTicket(String numeroTicket) { this.numeroTicket = numeroTicket; }
    public String getUsuarioAfectado() { return usuarioAfectado; }
    public void setUsuarioAfectado(String usuarioAfectado) { this.usuarioAfectado = usuarioAfectado; }
    public String getResponsable() { return responsable; }
    public void setResponsable(String responsable) { this.responsable = responsable; }
    public String getAccion() { return accion; }
    public void setAccion(String accion) { this.accion = accion; }
    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
    public String getResultado() { return resultado; }
    public void setResultado(String resultado) { this.resultado = resultado; }
    public String getMetodoVerificacion() { return metodoVerificacion; }
    public void setMetodoVerificacion(String metodoVerificacion) { this.metodoVerificacion = metodoVerificacion; }
    public LocalDateTime getFechaAccion() { return fechaAccion; }
    public void setFechaAccion(LocalDateTime fechaAccion) { this.fechaAccion = fechaAccion; }
    public String getFechaAccionTexto() { return fechaAccion == null ? "" : fechaAccion.format(FECHA); }
}
