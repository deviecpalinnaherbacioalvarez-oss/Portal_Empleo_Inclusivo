package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class IncidenciaSoporte implements Serializable {
    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int idIncidencia;
    private Integer idCreador;
    private int idResponsable;
    private Integer idUsuarioAfectado;
    private String correo;
    private String titulo;
    private String descripcion;
    private String origen;
    private String categoria;
    private String prioridad;
    private String decision;
    private String estado;
    private String solucion;
    private String nombreUsuarioAfectado;
    private String nombreResponsable;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaActualizacion;
    private String numeroTicket;
    private boolean identidadVerificada;
    private String metodoVerificacion;
    private String motivoAccion;
    private LocalDateTime fechaVerificacion;
    private String correoOculto;
    private String estadoCuenta;
    private int intentosFallidos;
    private LocalDateTime bloqueadoHasta;
    private String motivoBloqueo;

    public int getIdIncidencia() { return idIncidencia; }
    public void setIdIncidencia(int idIncidencia) { this.idIncidencia = idIncidencia; }
    public Integer getIdCreador() { return idCreador; }
    public void setIdCreador(Integer idCreador) { this.idCreador = idCreador; }
    public int getIdResponsable() { return idResponsable; }
    public void setIdResponsable(int idResponsable) { this.idResponsable = idResponsable; }
    public Integer getIdUsuarioAfectado() { return idUsuarioAfectado; }
    public void setIdUsuarioAfectado(Integer idUsuarioAfectado) { this.idUsuarioAfectado = idUsuarioAfectado; }
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public String getOrigen() { return origen; }
    public void setOrigen(String origen) { this.origen = origen; }
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
    public String getPrioridad() { return prioridad; }
    public void setPrioridad(String prioridad) { this.prioridad = prioridad; }
    public String getDecision() { return decision; }
    public void setDecision(String decision) { this.decision = decision; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getSolucion() { return solucion; }
    public void setSolucion(String solucion) { this.solucion = solucion; }
    public String getNombreUsuarioAfectado() { return nombreUsuarioAfectado; }
    public void setNombreUsuarioAfectado(String nombreUsuarioAfectado) { this.nombreUsuarioAfectado = nombreUsuarioAfectado; }
    public String getNombreResponsable() { return nombreResponsable; }
    public void setNombreResponsable(String nombreResponsable) { this.nombreResponsable = nombreResponsable; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }
    public String getFechaCreacionTexto() { return formatear(fechaCreacion); }
    public String getFechaActualizacionTexto() { return formatear(fechaActualizacion); }
    public String getNumeroTicket() { return numeroTicket; }
    public void setNumeroTicket(String numeroTicket) { this.numeroTicket = numeroTicket; }
    public boolean isIdentidadVerificada() { return identidadVerificada; }
    public void setIdentidadVerificada(boolean identidadVerificada) { this.identidadVerificada = identidadVerificada; }
    public String getMetodoVerificacion() { return metodoVerificacion; }
    public void setMetodoVerificacion(String metodoVerificacion) { this.metodoVerificacion = metodoVerificacion; }
    public String getMotivoAccion() { return motivoAccion; }
    public void setMotivoAccion(String motivoAccion) { this.motivoAccion = motivoAccion; }
    public LocalDateTime getFechaVerificacion() { return fechaVerificacion; }
    public void setFechaVerificacion(LocalDateTime fechaVerificacion) { this.fechaVerificacion = fechaVerificacion; }
    public String getFechaVerificacionTexto() { return formatear(fechaVerificacion); }
    public String getCorreoOculto() { return correoOculto; }
    public void setCorreoOculto(String correoOculto) { this.correoOculto = correoOculto; }
    public String getEstadoCuenta() { return estadoCuenta; }
    public void setEstadoCuenta(String estadoCuenta) { this.estadoCuenta = estadoCuenta; }
    public int getIntentosFallidos() { return intentosFallidos; }
    public void setIntentosFallidos(int intentosFallidos) { this.intentosFallidos = intentosFallidos; }
    public LocalDateTime getBloqueadoHasta() { return bloqueadoHasta; }
    public void setBloqueadoHasta(LocalDateTime bloqueadoHasta) { this.bloqueadoHasta = bloqueadoHasta; }
    public String getBloqueadoHastaTexto() { return formatear(bloqueadoHasta); }
    public String getMotivoBloqueo() { return motivoBloqueo; }
    public void setMotivoBloqueo(String motivoBloqueo) { this.motivoBloqueo = motivoBloqueo; }

    private String formatear(LocalDateTime fecha) {
        return fecha == null ? "" : fecha.format(FORMATO_FECHA);
    }
}
