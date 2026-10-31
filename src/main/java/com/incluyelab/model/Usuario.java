package com.incluyelab.model;

import java.io.Serializable;

public class Usuario implements Serializable {
    private int idUsuario;
    private String nombre;
    private String correo;
    private String contrasena;
    private String rol;
    private String estado;
    private String credencialVersion;
    private boolean requiereCambioClave;
    private boolean correoVerificado = true;
    /** NO_APLICA, SIN_ENVIAR, PENDIENTE, APROBADA, RECHAZADA o VENCIDA. */
    private String conadisEstado = "NO_APLICA";

    public String getCredencialVersion() { return credencialVersion; }
    public void setCredencialVersion(String version) { this.credencialVersion = version; }
    public boolean isRequiereCambioClave() { return requiereCambioClave; }
    public void setRequiereCambioClave(boolean requiereCambioClave) { this.requiereCambioClave = requiereCambioClave; }
    public boolean isCorreoVerificado() { return correoVerificado; }
    public void setCorreoVerificado(boolean correoVerificado) { this.correoVerificado = correoVerificado; }
    public String getConadisEstado() { return conadisEstado; }
    public void setConadisEstado(String conadisEstado) { this.conadisEstado = conadisEstado; }
    /** Solo los postulantes requieren el carnet CONADIS verificado y vigente. */
    public boolean isRequiereVerificacionConadis() {
        return "POSTULANTE".equals(rol) && !"APROBADA".equals(conadisEstado);
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getContrasena() {
        return contrasena;
    }

    public void setContrasena(String contrasena) {
        this.contrasena = contrasena;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}
