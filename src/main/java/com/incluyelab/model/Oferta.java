package com.incluyelab.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Oferta implements Serializable {
    private int idOferta;
    private int idEmpresa;
    private String empresa;
    private String logoUrl;
    private String titulo;
    private String modalidad;
    private String ubicacion;
    private String adaptaciones;
    private String apoyos = "";

    public String getApoyos() { return apoyos; }
    public void setApoyos(String apoyos) { this.apoyos = apoyos == null ? "" : apoyos; }
    public String getCategoriasApoyo() { return ApoyosOferta.categorias(apoyos); }
    public String getEtiquetasApoyo() { return ApoyosOferta.etiquetas(apoyos); }
    private String descripcion;
    private BigDecimal salario;
    private String estado;

    public int getIdOferta() {
        return idOferta;
    }

    public void setIdOferta(int idOferta) {
        this.idOferta = idOferta;
    }

    public int getIdEmpresa() {
        return idEmpresa;
    }

    public void setIdEmpresa(int idEmpresa) {
        this.idEmpresa = idEmpresa;
    }

    public String getEmpresa() {
        return empresa;
    }

    public void setEmpresa(String empresa) {
        this.empresa = empresa;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public String getLogoPublico() {
        String logo = logoUrl == null ? "" : logoUrl.replace('\\', '/');
        return logo.matches("assets/logos/[A-Za-z0-9._-]+") ? logo : "";
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getModalidad() {
        return modalidad;
    }

    public void setModalidad(String modalidad) {
        this.modalidad = modalidad;
    }

    public String getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
    }

    public String getAdaptaciones() {
        return adaptaciones;
    }

    public void setAdaptaciones(String adaptaciones) {
        this.adaptaciones = adaptaciones;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public List<SeccionDetalle> getSeccionesDetalle() {
        List<SeccionDetalle> secciones = new ArrayList<>();
        SeccionDetalle actual = null;
        String texto = descripcion == null ? "" : descripcion.trim();
        for (String lineaOriginal : texto.split("\\r?\\n")) {
            String linea = lineaOriginal.trim();
            if (linea.isEmpty()) continue;
            if (linea.startsWith("## ")) {
                actual = new SeccionDetalle(linea.substring(3).trim());
                secciones.add(actual);
            } else {
                if (actual == null) {
                    actual = new SeccionDetalle("Acerca del empleo");
                    secciones.add(actual);
                }
                if (linea.startsWith("- ")) actual.items.add(linea.substring(2).trim());
                else actual.parrafos.add(linea);
            }
        }
        if (secciones.isEmpty()) secciones.add(new SeccionDetalle("Acerca del empleo"));
        return secciones;
    }

    public String getResumen() {
        for (SeccionDetalle seccion : getSeccionesDetalle()) {
            if (!seccion.parrafos.isEmpty()) return seccion.parrafos.get(0);
            if (!seccion.items.isEmpty()) return seccion.items.get(0);
        }
        return "Consulta las funciones, requisitos y condiciones de esta oportunidad.";
    }

    public static class SeccionDetalle implements Serializable {
        private final String titulo;
        private final List<String> parrafos = new ArrayList<>();
        private final List<String> items = new ArrayList<>();

        public SeccionDetalle(String titulo) { this.titulo = titulo; }
        public String getTitulo() { return titulo; }
        public List<String> getParrafos() { return parrafos; }
        public List<String> getItems() { return items; }
    }

    public BigDecimal getSalario() {
        return salario;
    }

    public void setSalario(BigDecimal salario) {
        this.salario = salario;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}
