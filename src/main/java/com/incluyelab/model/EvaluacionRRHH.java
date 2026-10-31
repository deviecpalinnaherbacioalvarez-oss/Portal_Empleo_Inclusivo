package com.incluyelab.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class EvaluacionRRHH implements Serializable {
    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int idEvaluacion;
    private int idPostulacion;
    private int idEvaluador;
    private String nombrePostulante;
    private String nombreEvaluador;
    private String tituloOferta;
    private String razonSocialEmpresa;
    private String observaciones;
    private String retroalimentacion;
    private String resultado;
    private String estado;
    private String etapa;
    private int puntajeCv;
    private int puntajeEntrevista;
    private int puntajeDesempeno;
    private int porcentajeCompatibilidad;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaActualizacion;

    public int getIdEvaluacion() { return idEvaluacion; }
    public void setIdEvaluacion(int idEvaluacion) { this.idEvaluacion = idEvaluacion; }
    public int getIdPostulacion() { return idPostulacion; }
    public void setIdPostulacion(int idPostulacion) { this.idPostulacion = idPostulacion; }
    public int getIdEvaluador() { return idEvaluador; }
    public void setIdEvaluador(int idEvaluador) { this.idEvaluador = idEvaluador; }
    public String getNombrePostulante() { return nombrePostulante; }
    public void setNombrePostulante(String nombrePostulante) { this.nombrePostulante = nombrePostulante; }
    public String getNombreEvaluador() { return nombreEvaluador; }
    public void setNombreEvaluador(String nombreEvaluador) { this.nombreEvaluador = nombreEvaluador; }
    public String getTituloOferta() { return tituloOferta; }
    public void setTituloOferta(String tituloOferta) { this.tituloOferta = tituloOferta; }
    public String getRazonSocialEmpresa() { return razonSocialEmpresa; }
    public void setRazonSocialEmpresa(String razonSocialEmpresa) { this.razonSocialEmpresa = razonSocialEmpresa; }
    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
    public String getRetroalimentacion() { return retroalimentacion; }
    public void setRetroalimentacion(String retroalimentacion) { this.retroalimentacion = retroalimentacion; }
    public String getResultado() { return resultado; }
    public void setResultado(String resultado) { this.resultado = resultado; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getEtapa() { return etapa; }
    public void setEtapa(String etapa) { this.etapa = etapa; }
    public int getPuntajeCv() { return puntajeCv; }
    public void setPuntajeCv(int puntajeCv) { this.puntajeCv = puntajeCv; }
    public int getPuntajeEntrevista() { return puntajeEntrevista; }
    public void setPuntajeEntrevista(int puntajeEntrevista) { this.puntajeEntrevista = puntajeEntrevista; }
    public int getPuntajeDesempeno() { return puntajeDesempeno; }
    public void setPuntajeDesempeno(int puntajeDesempeno) { this.puntajeDesempeno = puntajeDesempeno; }
    public int getPorcentajeCompatibilidad() { return porcentajeCompatibilidad; }
    public void setPorcentajeCompatibilidad(int porcentajeCompatibilidad) { this.porcentajeCompatibilidad = porcentajeCompatibilidad; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }
    public String getFechaCreacionTexto() { return formatear(fechaCreacion); }
    public String getFechaActualizacionTexto() { return formatear(fechaActualizacion); }

    private String formatear(LocalDateTime fecha) {
        return fecha == null ? "" : fecha.format(FORMATO_FECHA);
    }
}
