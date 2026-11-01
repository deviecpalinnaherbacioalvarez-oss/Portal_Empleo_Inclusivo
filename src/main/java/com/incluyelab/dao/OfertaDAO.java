package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.FiltroOfertaPublica;
import com.incluyelab.model.Oferta;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class OfertaDAO {
    private static final Map<String,List<String>> CODIGOS_ADAPTACION = new LinkedHashMap<>();
    static {
        CODIGOS_ADAPTACION.put("movilidad", Arrays.asList("rampas","ascensores","escritorios","perifericos"));
        CODIGOS_ADAPTACION.put("visual", Arrays.asList("lector","macrotipos","contraste","braille"));
        CODIGOS_ADAPTACION.put("auditiva", Arrays.asList("escrita","subtitulos","lsp"));
        CODIGOS_ADAPTACION.put("flexible", Arrays.asList("flexible"));
        CODIGOS_ADAPTACION.put("pausas", Arrays.asList("pausas"));
    }

    public List<Oferta> listarActivas() throws SQLException {
        return listarPorSql("WHERE o.estado='activa' AND e.estado_revision='aprobada' AND EXISTS (SELECT 1 FROM usuarios u WHERE u.id_usuario=e.id_usuario AND u.estado='activo' AND u.rol='EMPRESA')", 0);
    }

    public List<Oferta> listarPorEmpresa(int idEmpresa) throws SQLException {
        return listarPorSql("WHERE o.id_empresa=?", idEmpresa);
    }

    public List<Oferta> listarTodas() throws SQLException {
        return listarPorSql("", 0);
    }

    public List<Oferta> buscarPublicas(FiltroOfertaPublica filtro) throws SQLException {
        ConsultaPublica consulta = consultaPublica(filtro);
        String orden = "salary".equals(filtro.getOrden()) ? "o.salario DESC,o.id_oferta DESC"
                : "title".equals(filtro.getOrden()) ? "o.titulo ASC,o.id_oferta DESC"
                : "o.fecha_publicacion DESC,o.id_oferta DESC";
        String sql = "SELECT o.id_oferta,o.id_empresa,e.razon_social empresa,e.logo_url,o.titulo,o.modalidad,"
                + "o.ubicacion,o.adaptaciones,o.apoyos,o.descripcion,o.salario,o.estado "
                + "FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa "
                + "JOIN usuarios u ON u.id_usuario=e.id_usuario " + consulta.where
                + " ORDER BY " + orden + " LIMIT ? OFFSET ?";
        List<Oferta> ofertas = new ArrayList<>();
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            int indice = asignar(ps, consulta.parametros);
            ps.setInt(indice++, filtro.getTamanoPagina());
            ps.setInt(indice, filtro.getOffset());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ofertas.add(mapearOferta(rs));
            }
        }
        return ofertas;
    }

    public int contarPublicas(FiltroOfertaPublica filtro) throws SQLException {
        ConsultaPublica consulta = consultaPublica(filtro);
        String sql = "SELECT COUNT(*) FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa "
                + "JOIN usuarios u ON u.id_usuario=e.id_usuario " + consulta.where;
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            asignar(ps, consulta.parametros);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        }
    }

    public Oferta obtenerPublica(int idOferta) throws SQLException {
        String sql = "SELECT o.id_oferta,o.id_empresa,e.razon_social empresa,e.logo_url,o.titulo,o.modalidad,"
                + "o.ubicacion,o.adaptaciones,o.apoyos,o.descripcion,o.salario,o.estado "
                + "FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa "
                + "JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE o.id_oferta=? AND o.estado='activa' "
                + "AND o.fecha_publicacion<=NOW() AND e.estado_revision='aprobada' "
                + "AND u.estado='activo' AND u.rol='EMPRESA'";
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idOferta);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapearOferta(rs) : null; }
        }
    }

    public List<Oferta> listarPublicasPorEmpresa(int idEmpresa) throws SQLException {
        FiltroOfertaPublica filtro = new FiltroOfertaPublica();
        filtro.setIdEmpresa(idEmpresa);
        filtro.setTamanoPagina(24);
        return buscarPublicas(filtro);
    }

    public Oferta obtenerPorEmpresa(int idOferta, int idEmpresa) throws SQLException {
        for (Oferta oferta : listarPorEmpresa(idEmpresa)) {
            if (oferta.getIdOferta() == idOferta) return oferta;
        }
        return null;
    }

    public void registrar(Oferta oferta) throws SQLException {
        String sql = "INSERT INTO ofertas(id_empresa, titulo, modalidad, ubicacion, adaptaciones, descripcion, salario, apoyos, estado) SELECT ?,?,?,?,?,?,?,?, 'activa' FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE e.id_empresa=? AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA'";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, oferta.getIdEmpresa());
            ps.setString(2, oferta.getTitulo());
            ps.setString(3, oferta.getModalidad());
            ps.setString(4, oferta.getUbicacion());
            ps.setString(5, oferta.getAdaptaciones());
            ps.setString(6, oferta.getDescripcion());
            ps.setBigDecimal(7, oferta.getSalario() == null ? BigDecimal.ZERO : oferta.getSalario());
            ps.setString(8, oferta.getApoyos());
            ps.setInt(9, oferta.getIdEmpresa());
            if(ps.executeUpdate()!=1) throw new IllegalArgumentException("Tu empresa requiere aprobacion antes de publicar.");
        }
    }

    public void actualizar(Oferta oferta) throws SQLException {
        String sql = "UPDATE ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario "
                + "SET o.titulo=?,o.modalidad=?,o.ubicacion=?,o.adaptaciones=?,o.descripcion=?,o.salario=?,o.apoyos=?,o.estado=? "
                + "WHERE o.id_oferta=? AND o.id_empresa=? AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA'";
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, oferta.getTitulo());
            ps.setString(2, oferta.getModalidad());
            ps.setString(3, oferta.getUbicacion());
            ps.setString(4, oferta.getAdaptaciones());
            ps.setString(5, oferta.getDescripcion());
            ps.setBigDecimal(6, oferta.getSalario());
            ps.setString(7, oferta.getApoyos());
            ps.setString(8, oferta.getEstado());
            ps.setInt(9, oferta.getIdOferta());
            ps.setInt(10, oferta.getIdEmpresa());
            if (ps.executeUpdate() != 1) throw new IllegalArgumentException("La oferta no existe o no pertenece a tu empresa.");
        }
    }

    public void eliminar(int idOferta, int idEmpresa) throws SQLException {
        try (Connection cn = Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = cn.prepareStatement("SELECT id_oferta,estado FROM ofertas WHERE id_oferta=? AND id_empresa=? FOR UPDATE")) {
                    ps.setInt(1,idOferta); ps.setInt(2,idEmpresa);
                    try (ResultSet rs=ps.executeQuery()) {
                        if(!rs.next()) throw new IllegalArgumentException("La oferta no existe o no pertenece a tu empresa.");
                        if("cerrada".equals(rs.getString("estado"))) throw new IllegalArgumentException("La oferta ya se encuentra cerrada.");
                    }
                }
                String aviso="La empresa cerró una oferta a la que habías postulado. Tu postulación y su historial se conservarán para consulta.";
                try(PreparedStatement ps=cn.prepareStatement("INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje) SELECT p.id_usuario,'OFERTA_ELIMINADA','Oferta cerrada',CONCAT(?, ' Puesto: ',o.titulo) FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta WHERE p.id_oferta=?")){ps.setString(1,aviso);ps.setInt(2,idOferta);ps.executeUpdate();}
                try (PreparedStatement ps=cn.prepareStatement("UPDATE ofertas SET estado='cerrada' WHERE id_oferta=? AND id_empresa=?")) {
                    ps.setInt(1,idOferta); ps.setInt(2,idEmpresa);
                    if(ps.executeUpdate()!=1) throw new IllegalArgumentException("No se pudo cerrar la oferta.");
                }
                cn.commit();
            } catch (SQLException | RuntimeException ex) {
                cn.rollback();
                throw ex;
            } finally { cn.setAutoCommit(true); }
        }
    }

    private List<Oferta> listarPorSql(String where, int idEmpresa) throws SQLException {
        List<Oferta> ofertas = new ArrayList<>();
        String sql = "SELECT o.id_oferta, o.id_empresa, e.razon_social empresa, e.logo_url, o.titulo, o.modalidad, o.ubicacion, "
                + "o.adaptaciones, o.apoyos, o.descripcion, o.salario, o.estado "
                + "FROM ofertas o INNER JOIN empresas e ON o.id_empresa=e.id_empresa " + where
                + " ORDER BY o.id_oferta DESC";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            if (where.contains("?")) {
                ps.setInt(1, idEmpresa);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ofertas.add(mapearOferta(rs));
                }
            }
        }
        return ofertas;
    }

    private ConsultaPublica consultaPublica(FiltroOfertaPublica filtro) {
        StringBuilder where = new StringBuilder("WHERE o.estado='activa' AND o.fecha_publicacion<=NOW() ")
                .append("AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA'");
        List<Object> parametros = new ArrayList<>();
        if (!filtro.getTexto().isEmpty()) {
            where.append(" AND (o.titulo LIKE ? ESCAPE '!' OR e.razon_social LIKE ? ESCAPE '!' ")
                    .append("OR o.descripcion LIKE ? ESCAPE '!' OR o.adaptaciones LIKE ? ESCAPE '!')");
            String valor = like(filtro.getTexto());
            for (int i=0; i<4; i++) parametros.add(valor);
        }
        if (!filtro.getUbicacion().isEmpty()) {
            where.append(" AND o.ubicacion LIKE ? ESCAPE '!'");
            parametros.add(like(filtro.getUbicacion()));
        }
        if (filtro.getIdEmpresa() != null) {
            where.append(" AND o.id_empresa=?");
            parametros.add(filtro.getIdEmpresa());
        }
        if (!filtro.getModalidades().isEmpty()) {
            where.append(" AND (");
            for (int i=0; i<filtro.getModalidades().size(); i++) {
                if (i>0) where.append(" OR ");
                where.append("LOWER(o.modalidad) LIKE ? ESCAPE '!'");
                parametros.add(like(filtro.getModalidades().get(i).toLowerCase()));
            }
            where.append(')');
        }
        for (String categoria : filtro.getAdaptaciones()) {
            List<String> codigos = CODIGOS_ADAPTACION.get(categoria);
            if (codigos == null) continue;
            where.append(" AND (");
            for (int i=0; i<codigos.size(); i++) {
                if (i>0) where.append(" OR ");
                where.append("FIND_IN_SET(?,REPLACE(o.apoyos,' ',''))>0");
                parametros.add(codigos.get(i));
            }
            where.append(')');
        }
        return new ConsultaPublica(where.toString(), parametros);
    }

    private int asignar(PreparedStatement ps, List<Object> parametros) throws SQLException {
        int indice = 1;
        for (Object parametro : parametros) {
            if (parametro instanceof Integer) ps.setInt(indice++, (Integer) parametro);
            else ps.setString(indice++, String.valueOf(parametro));
        }
        return indice;
    }

    private String like(String value) {
        return "%" + value.replace("!", "!!").replace("%", "!%").replace("_", "!_") + "%";
    }

    private Oferta mapearOferta(ResultSet rs) throws SQLException {
        Oferta o = new Oferta();
        o.setIdOferta(rs.getInt("id_oferta"));
        o.setIdEmpresa(rs.getInt("id_empresa"));
        o.setEmpresa(rs.getString("empresa"));
        o.setLogoUrl(rs.getString("logo_url"));
        o.setTitulo(rs.getString("titulo"));
        o.setModalidad(rs.getString("modalidad"));
        o.setUbicacion(rs.getString("ubicacion"));
        o.setAdaptaciones(rs.getString("adaptaciones"));
        o.setApoyos(rs.getString("apoyos"));
        o.setDescripcion(rs.getString("descripcion"));
        o.setSalario(rs.getBigDecimal("salario"));
        o.setEstado(rs.getString("estado"));
        return o;
    }

    private static final class ConsultaPublica {
        private final String where;
        private final List<Object> parametros;
        private ConsultaPublica(String where, List<Object> parametros) {
            this.where = where;
            this.parametros = parametros;
        }
    }
}
