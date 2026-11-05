package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class MensajePostulacion implements Serializable {
    private static final DateTimeFormatter FORMATO = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private long idMensaje;
    private int idPostulacion;
    private int idRemitente;
    private String nombreRemitente;
    private String rolRemitente;
    private String mensaje;
    private boolean leido;
    private LocalDateTime fechaCreacion;

    public long getIdMensaje() { return idMensaje; }
    public void setIdMensaje(long idMensaje) { this.idMensaje = idMensaje; }
    public int getIdPostulacion() { return idPostulacion; }
    public void setIdPostulacion(int idPostulacion) { this.idPostulacion = idPostulacion; }
    public int getIdRemitente() { return idRemitente; }
    public void setIdRemitente(int idRemitente) { this.idRemitente = idRemitente; }
    public String getNombreRemitente() { return nombreRemitente; }
    public void setNombreRemitente(String nombreRemitente) { this.nombreRemitente = nombreRemitente; }
    public String getRolRemitente() { return rolRemitente; }
    public void setRolRemitente(String rolRemitente) { this.rolRemitente = rolRemitente; }
    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }
    public boolean isLeido() { return leido; }
    public void setLeido(boolean leido) { this.leido = leido; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public String getFechaCreacionTexto() { return fechaCreacion == null ? "" : fechaCreacion.format(FORMATO); }
}
