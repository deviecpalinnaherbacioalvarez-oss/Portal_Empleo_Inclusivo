package com.incluyelab.model;

import java.io.Serializable;

public class Empresa implements Serializable {
    private int idEmpresa;
    private int idUsuario;
    private String razonSocial;
    private String ruc;
    private String sector;
    private String selloInclusivo;
    private String estadoRevision;
    private String presentacion;
    private Integer anioInicio;
    private String logros;
    private String motivoRevision;
    private int versionRevision;
    private String correoCuenta;
    private String estadoCuenta;
    private String logoUrl;
    private String sitioOficial;
    private String pais;
    private int totalOfertas;

    public String getEstadoRevision() { return estadoRevision; }
    public void setEstadoRevision(String v) { estadoRevision=v; }
    public boolean isAprobada() { return "aprobada".equals(estadoRevision); }
    public String getPresentacion() { return presentacion == null ? "" : presentacion; }
    public void setPresentacion(String v) { presentacion=v; }
    public Integer getAnioInicio() { return anioInicio; }
    public void setAnioInicio(Integer v) { anioInicio=v; }
    public String getLogros() { return logros == null ? "" : logros; }
    public void setLogros(String v) { logros=v; }
    public String getMotivoRevision() { return motivoRevision; }
    public void setMotivoRevision(String v) { motivoRevision=v; }
    public int getVersionRevision() { return versionRevision; }
    public void setVersionRevision(int v) { versionRevision=v; }
    public String getCorreoCuenta() { return correoCuenta == null ? "" : correoCuenta; }
    public void setCorreoCuenta(String v) { correoCuenta=v; }
    public String getEstadoCuenta() { return estadoCuenta == null ? "" : estadoCuenta; }
    public void setEstadoCuenta(String v) { estadoCuenta=v; }
    public String getLogoUrl() { return logoUrl == null ? "" : logoUrl; }
    public void setLogoUrl(String v) { logoUrl=v; }
    public String getLogoPublico() {
        String logo = getLogoUrl().replace('\\', '/');
        return logo.matches("assets/logos/[A-Za-z0-9._-]+") ? logo : "";
    }
    public String getSitioOficial() {
        String sitio = sitioOficial == null ? "" : sitioOficial.trim();
        return sitio.matches("https?://[^\\s]+") ? sitio : "";
    }
    public void setSitioOficial(String v) { sitioOficial=v; }
    public String getPais() { return pais == null || pais.trim().isEmpty() ? "Peru" : pais; }
    public void setPais(String v) { pais=v; }
    public int getTotalOfertas() { return totalOfertas; }
    public void setTotalOfertas(int v) { totalOfertas=v; }
    public boolean isFichaCompleta() {
        return ruc != null && ruc.matches("[0-9]{11}") && !"00000000000".equals(ruc)
            && sector != null && !sector.trim().isEmpty() && !getPresentacion().trim().isEmpty()
            && anioInicio != null && anioInicio >= 1800 && anioInicio <= java.time.Year.now().getValue()
            && !getLogros().trim().isEmpty();
    }

    public int getIdEmpresa() {
        return idEmpresa;
    }

    public void setIdEmpresa(int idEmpresa) {
        this.idEmpresa = idEmpresa;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getRazonSocial() {
        return razonSocial;
    }

    public void setRazonSocial(String razonSocial) {
        this.razonSocial = razonSocial;
    }

    public String getRuc() {
        return ruc;
    }

    public void setRuc(String ruc) {
        this.ruc = ruc;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getSelloInclusivo() {
        return selloInclusivo;
    }

    public void setSelloInclusivo(String selloInclusivo) {
        this.selloInclusivo = selloInclusivo;
    }
}
