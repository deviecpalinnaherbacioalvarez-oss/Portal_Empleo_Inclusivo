package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.FiltroOfertaPublica;
import com.incluyelab.model.Oferta;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.CallableStatement;
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
        return listarProcedimiento("{CALL sp_oferta_listar_publicas()}");
    }

    public List<Oferta> listarPorEmpresa(int idEmpresa) throws SQLException {
        return listarProcedimiento("{CALL sp_oferta_listar_empresa(?)}",idEmpresa);
    }

    public List<Oferta> listarTodas() throws SQLException {
        return listarProcedimiento("{CALL sp_oferta_listar_todas()}");
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
        try (Connection cn = Conexion.getConnection();
             CallableStatement ps = cn.prepareCall("{CALL sp_oferta_crear(?,?,?,?,?,?,?,?)}")) {
            ps.setInt(1, oferta.getIdEmpresa());
            ps.setString(2, oferta.getTitulo());
            ps.setString(3, oferta.getModalidad());
            ps.setString(4, oferta.getUbicacion());
            ps.setString(5, oferta.getAdaptaciones());
            ps.setString(6, oferta.getDescripcion());
            ps.setBigDecimal(7, oferta.getSalario() == null ? BigDecimal.ZERO : oferta.getSalario());
            ps.setString(8, oferta.getApoyos());
            ps.execute();
        }
    }

    public void actualizar(Oferta oferta) throws SQLException {
        try (Connection cn = Conexion.getConnection(); CallableStatement ps = cn.prepareCall("{CALL sp_oferta_actualizar(?,?,?,?,?,?,?,?,?,?)}")) {
            ps.setInt(1,oferta.getIdOferta());ps.setInt(2,oferta.getIdEmpresa());ps.setString(3,oferta.getTitulo());
            ps.setString(4,oferta.getModalidad());ps.setString(5,oferta.getUbicacion());ps.setString(6,oferta.getAdaptaciones());
            ps.setString(7,oferta.getDescripcion());ps.setBigDecimal(8,oferta.getSalario());ps.setString(9,oferta.getApoyos());ps.setString(10,oferta.getEstado());
            ps.execute();
        }
    }

    public void eliminar(int idOferta, int idEmpresa) throws SQLException {
        try (Connection cn = Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                try(CallableStatement ps=cn.prepareCall("{CALL sp_oferta_cerrar(?,?)}")){ps.setInt(1,idOferta);ps.setInt(2,idEmpresa);ps.execute();}
                cn.commit();
            } catch (SQLException | RuntimeException ex) {
                cn.rollback();
                throw ex;
            } finally { cn.setAutoCommit(true); }
        }
    }

    private List<Oferta> listarProcedimiento(String llamada,Object... valores)throws SQLException{
        List<Oferta> ofertas=new ArrayList<>();
        try(Connection cn=Conexion.getConnection();CallableStatement cs=cn.prepareCall(llamada)){
            for(int i=0;i<valores.length;i++)cs.setObject(i+1,valores[i]);
            try(ResultSet rs=cs.executeQuery()){while(rs.next())ofertas.add(mapearOferta(rs));}
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
