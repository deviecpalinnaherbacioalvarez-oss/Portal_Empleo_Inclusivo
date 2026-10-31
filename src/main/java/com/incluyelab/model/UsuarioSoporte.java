package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** Vista minima de una cuenta disponible exclusivamente para Soporte Tecnico. */
public class UsuarioSoporte implements Serializable {
    private static final DateTimeFormatter FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private int idUsuario;
    private String nombre;
    private String correoOculto;
    private String rol;
    private String estado;
    private int intentosFallidos;
    private LocalDateTime bloqueadoHasta;
    private String motivoBloqueo;
    private boolean requiereCambioClave;
    private LocalDateTime claveTemporalExpira;

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getCorreoOculto() { return correoOculto; }
    public void setCorreoOculto(String correoOculto) { this.correoOculto = correoOculto; }
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public int getIntentosFallidos() { return intentosFallidos; }
    public void setIntentosFallidos(int intentosFallidos) { this.intentosFallidos = intentosFallidos; }
    public LocalDateTime getBloqueadoHasta() { return bloqueadoHasta; }
    public void setBloqueadoHasta(LocalDateTime bloqueadoHasta) { this.bloqueadoHasta = bloqueadoHasta; }
    public String getMotivoBloqueo() { return motivoBloqueo; }
    public void setMotivoBloqueo(String motivoBloqueo) { this.motivoBloqueo = motivoBloqueo; }
    public boolean isRequiereCambioClave() { return requiereCambioClave; }
    public void setRequiereCambioClave(boolean requiereCambioClave) { this.requiereCambioClave = requiereCambioClave; }
    public LocalDateTime getClaveTemporalExpira() { return claveTemporalExpira; }
    public void setClaveTemporalExpira(LocalDateTime claveTemporalExpira) { this.claveTemporalExpira = claveTemporalExpira; }
    public String getBloqueadoHastaTexto() { return bloqueadoHasta == null ? "" : bloqueadoHasta.format(FECHA); }
    public String getClaveTemporalExpiraTexto() { return claveTemporalExpira == null ? "" : claveTemporalExpira.format(FECHA); }
}
