package com.incluyelab.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class PerfilPostulante implements Serializable {
    private static final long serialVersionUID = 1L;

    private VerificacionConadis datosConadis;
    public VerificacionConadis getDatosConadis(){return datosConadis;}
    public void setDatosConadis(VerificacionConadis datos){datosConadis=datos;}
    private int idUsuario;
    private String nombre = "";
    private String correo = "";
    private String telefono = "";
    private String titular = "";
    private String ubicacion = "";
    private String acercaDe = "";
    private String habilidades = "";
    private String adaptacionRequerida = "";
    private String fotoUrl = "";
    private String cvNombre = "";
    private String cvArchivo = "";

    // Composicion: estas tres colecciones nacen y permanecen con el perfil.
    private final List<Experiencia> experiencias = new ArrayList<>();
    private final List<Educacion> educacion = new ArrayList<>();
    private final List<Certificacion> certificaciones = new ArrayList<>();

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = texto(nombre); }
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = texto(correo); }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = texto(telefono); }
    public String getTitular() { return titular; }
    public void setTitular(String titular) { this.titular = texto(titular); }
    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = texto(ubicacion); }
    public String getAcercaDe() { return acercaDe; }
    public void setAcercaDe(String acercaDe) { this.acercaDe = texto(acercaDe); }
    public String getHabilidades() { return habilidades; }
    public void setHabilidades(String habilidades) { this.habilidades = texto(habilidades); }
    public String getAdaptacionRequerida() { return adaptacionRequerida; }
    public void setAdaptacionRequerida(String adaptacionRequerida) { this.adaptacionRequerida = texto(adaptacionRequerida); }
    public String getFotoUrl() { return fotoUrl; }
    public void setFotoUrl(String fotoUrl) { this.fotoUrl = texto(fotoUrl); }
    public String getCvNombre() { return cvNombre; }
    public void setCvNombre(String cvNombre) { this.cvNombre = texto(cvNombre); }
    public String getCvArchivo() { return cvArchivo; }
    public void setCvArchivo(String cvArchivo) { this.cvArchivo = texto(cvArchivo); }

    public List<Experiencia> getExperiencias() { return Collections.unmodifiableList(experiencias); }
    public List<Educacion> getEducacion() { return Collections.unmodifiableList(educacion); }
    public List<Certificacion> getCertificaciones() { return Collections.unmodifiableList(certificaciones); }
    public void agregarExperiencia(Experiencia experiencia) { experiencias.add(experiencia); }
    public void agregarEducacion(Educacion item) { educacion.add(item); }
    public void agregarCertificacion(Certificacion certificacion) { certificaciones.add(certificacion); }

    private String texto(String valor) { return valor == null ? "" : valor; }

    public static final class Experiencia implements Serializable {
        private static final long serialVersionUID = 1L;
        private int id;
        private String cargo = "";
        private String organizacion = "";
        private String inicio = "";
        private String fin = "";
        private String descripcion = "";

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getCargo() { return cargo; }
        public void setCargo(String cargo) { this.cargo = textoSeguro(cargo); }
        public String getOrganizacion() { return organizacion; }
        public void setOrganizacion(String organizacion) { this.organizacion = textoSeguro(organizacion); }
        public String getInicio() { return inicio; }
        public void setInicio(String inicio) { this.inicio = textoSeguro(inicio); }
        public String getFin() { return fin; }
        public void setFin(String fin) { this.fin = textoSeguro(fin); }
        public String getDescripcion() { return descripcion; }
        public void setDescripcion(String descripcion) { this.descripcion = textoSeguro(descripcion); }
    }

    public static final class Educacion implements Serializable {
        private static final long serialVersionUID = 1L;
        private int id;
        private String institucion = "";
        private String carrera = "";
        private String inicio = "";
        private String fin = "";
        private String descripcion = "";

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getInstitucion() { return institucion; }
        public void setInstitucion(String institucion) { this.institucion = textoSeguro(institucion); }
        public String getCarrera() { return carrera; }
        public void setCarrera(String carrera) { this.carrera = textoSeguro(carrera); }
        public String getInicio() { return inicio; }
        public void setInicio(String inicio) { this.inicio = textoSeguro(inicio); }
        public String getFin() { return fin; }
        public void setFin(String fin) { this.fin = textoSeguro(fin); }
        public String getDescripcion() { return descripcion; }
        public void setDescripcion(String descripcion) { this.descripcion = textoSeguro(descripcion); }
    }

    public static final class Certificacion implements Serializable {
        private static final long serialVersionUID = 1L;
        private int id;
        private String nombre = "";
        private String emisor = "";
        private String fecha = "";
        private String url = "";

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getNombre() { return nombre; }
        public void setNombre(String nombre) { this.nombre = textoSeguro(nombre); }
        public String getEmisor() { return emisor; }
        public void setEmisor(String emisor) { this.emisor = textoSeguro(emisor); }
        public String getFecha() { return fecha; }
        public void setFecha(String fecha) { this.fecha = textoSeguro(fecha); }
        public String getUrl() { return url; }
        public void setUrl(String url) { this.url = textoSeguro(url); }
    }

    private static String textoSeguro(String valor) {
        return valor == null ? "" : valor;
    }
}

