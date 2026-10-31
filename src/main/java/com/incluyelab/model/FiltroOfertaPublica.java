package com.incluyelab.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class FiltroOfertaPublica {
    private static final Set<String> MODALIDADES = Set.of("Remoto", "Hibrido", "Presencial");
    private static final Set<String> ADAPTACIONES = Set.of("movilidad", "visual", "auditiva", "flexible", "pausas");
    private String texto = "";
    private String ubicacion = "";
    private Integer idEmpresa;
    private List<String> modalidades = Collections.emptyList();
    private List<String> adaptaciones = Collections.emptyList();
    private String orden = "recent";
    private int pagina = 1;
    private int tamanoPagina = 8;

    public String getTexto() { return texto; }
    public void setTexto(String value) { texto = limitar(value, 100); }
    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String value) { ubicacion = limitar(value, 100); }
    public Integer getIdEmpresa() { return idEmpresa; }
    public void setIdEmpresa(Integer value) { idEmpresa = value != null && value > 0 ? value : null; }
    public List<String> getModalidades() { return modalidades; }
    public void setModalidades(String[] values) { modalidades = validar(values, MODALIDADES); }
    public List<String> getAdaptaciones() { return adaptaciones; }
    public void setAdaptaciones(String[] values) { adaptaciones = validar(values, ADAPTACIONES); }
    public String getOrden() { return orden; }
    public void setOrden(String value) {
        orden = "salary".equals(value) || "title".equals(value) ? value : "recent";
    }
    public int getPagina() { return pagina; }
    public void setPagina(int value) { pagina = Math.max(1, value); }
    public int getTamanoPagina() { return tamanoPagina; }
    public void setTamanoPagina(int value) { tamanoPagina = Math.max(1, Math.min(24, value)); }
    public int getOffset() { return (pagina - 1) * tamanoPagina; }

    private static String limitar(String value, int max) {
        String limpio = value == null ? "" : value.trim().replaceAll("\\s+", " ");
        return limpio.length() > max ? limpio.substring(0, max) : limpio;
    }

    private static List<String> validar(String[] values, Set<String> allowed) {
        if (values == null) return Collections.emptyList();
        Set<String> result = new LinkedHashSet<>();
        for (String value : values) if (allowed.contains(value)) result.add(value);
        return Collections.unmodifiableList(new ArrayList<>(result));
    }
}
