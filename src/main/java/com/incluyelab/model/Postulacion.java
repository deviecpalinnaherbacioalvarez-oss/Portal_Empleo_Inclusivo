package com.incluyelab.model;

import java.io.Serializable;

public class Postulacion implements Serializable {
    private int idPostulacion;
    private int idUsuario;
    private int idOferta;
    private String postulante;
    private String oferta;
    private String empresa;
    private String estado;
    private String fechaPostulacion;
    private String correo;
    private String titular;
    private String ubicacion;
    private String habilidades;
    private String cvNombre;

    public int getIdPostulacion() {
        return idPostulacion;
    }

    public void setIdPostulacion(int idPostulacion) {
        this.idPostulacion = idPostulacion;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public int getIdOferta() {
        return idOferta;
    }

    public void setIdOferta(int idOferta) {
        this.idOferta = idOferta;
    }

    public String getPostulante() {
        return postulante;
    }

    public void setPostulante(String postulante) {
        this.postulante = postulante;
    }

    public String getOferta() {
        return oferta;
    }

    public void setOferta(String oferta) {
        this.oferta = oferta;
    }

    public String getEmpresa() {
        return empresa;
    }

    public void setEmpresa(String empresa) {
        this.empresa = empresa;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getFechaPostulacion() {
        return fechaPostulacion;
    }

    public void setFechaPostulacion(String fechaPostulacion) {
        this.fechaPostulacion = fechaPostulacion;
    }
    public String getCorreo(){return correo;} public void setCorreo(String v){correo=v;}
    public String getTitular(){return titular;} public void setTitular(String v){titular=v;}
    public String getUbicacion(){return ubicacion;} public void setUbicacion(String v){ubicacion=v;}
    public String getHabilidades(){return habilidades;} public void setHabilidades(String v){habilidades=v;}
    public String getCvNombre(){return cvNombre;} public void setCvNombre(String v){cvNombre=v;}
}
