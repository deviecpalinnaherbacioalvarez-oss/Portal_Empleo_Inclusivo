package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class CodigoOtp implements Serializable {
    private int idOtp;
    private int idUsuario;
    private String correo;
    private String codigo;
    private String tipo = "VERIFICACION_CORREO";
    private int intentos;
    private String estado = "PENDIENTE";
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaExpiracion;

    public int getIdOtp() { return idOtp; }
    public void setIdOtp(int idOtp) { this.idOtp = idOtp; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public int getIntentos() { return intentos; }
    public void setIntentos(int intentos) { this.intentos = intentos; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public LocalDateTime getFechaExpiracion() { return fechaExpiracion; }
    public void setFechaExpiracion(LocalDateTime fechaExpiracion) { this.fechaExpiracion = fechaExpiracion; }

    public boolean isExpirado() {
        return fechaExpiracion != null && LocalDateTime.now().isAfter(fechaExpiracion);
    }
}
