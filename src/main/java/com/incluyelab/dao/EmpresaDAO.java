package com.incluyelab.dao;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Empresa;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EmpresaDAO {
    public Empresa obtenerPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT * FROM empresas WHERE id_usuario=?";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }
        }
        return null;
    }

    public List<Empresa> listar() throws SQLException {
        List<Empresa> empresas = new ArrayList<>();
        String sql = "SELECT e.*, u.correo AS correo_cuenta, u.estado AS estado_cuenta "
                + "FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario "
                + "ORDER BY e.id_empresa DESC";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Empresa empresa = mapear(rs);
                empresa.setCorreoCuenta(rs.getString("correo_cuenta"));
                empresa.setEstadoCuenta(rs.getString("estado_cuenta"));
                empresas.add(empresa);
            }
        }
        return empresas;
    }

    public Empresa obtener(int id) throws SQLException {
        try (Connection cn=Conexion.getConnection(); PreparedStatement ps=cn.prepareStatement("SELECT * FROM empresas WHERE id_empresa=?")) {
            ps.setInt(1,id);
            try (ResultSet rs=ps.executeQuery()) { return rs.next()?mapear(rs):null; }
        }
    }

    // Condiciones de visibilidad publica: empresa aprobada con cuenta EMPRESA activa
    // y ofertas activas cuya fecha de publicacion ya llego. Son constantes, nunca datos del usuario.
    private static final String EMPRESA_PUBLICA =
            "FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario "
            + "WHERE e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA' ";
    private static final String CON_OFERTA_VIGENTE =
            "AND EXISTS (SELECT 1 FROM ofertas o WHERE o.id_empresa=e.id_empresa "
            + "AND o.estado='activa' AND o.fecha_publicacion<=NOW()) ";

    /** Ficha publica: solo columnas publicas (sin RUC, correo, revision ni datos de la cuenta). */
    public Empresa obtenerPublica(int id) throws SQLException {
        if (id <= 0) return null;
        String sql = "SELECT e.id_empresa,e.razon_social,e.sector,e.logo_url,e.sello_inclusivo,"
                + "e.presentacion,e.anio_inicio,e.logros,e.sitio_oficial,e.pais,"
                + "(SELECT COUNT(*) FROM ofertas o WHERE o.id_empresa=e.id_empresa AND o.estado='activa' "
                + "AND o.fecha_publicacion<=NOW()) total_ofertas "
                + EMPRESA_PUBLICA + "AND e.id_empresa=?";
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapearPublica(rs) : null; }
        }
    }

    /** Directorio publico paginado: empresas visibles con al menos una oferta vigente. */
    public List<Empresa> listarDirectorioPublico(int limite, int offset) throws SQLException {
        List<Empresa> lista = new ArrayList<>();
        String sql = "SELECT e.id_empresa,e.razon_social,e.sector,e.logo_url,e.pais,t.total_ofertas "
                + "FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario "
                + "JOIN (SELECT o.id_empresa,COUNT(*) total_ofertas FROM ofertas o "
                + "WHERE o.estado='activa' AND o.fecha_publicacion<=NOW() GROUP BY o.id_empresa) t "
                + "ON t.id_empresa=e.id_empresa "
                + "WHERE e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA' "
                + "ORDER BY e.razon_social,e.id_empresa LIMIT ? OFFSET ?";
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, Math.min(48, limite)));
            ps.setInt(2, Math.max(0, offset));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Empresa e = new Empresa();
                    e.setIdEmpresa(rs.getInt("id_empresa"));
                    e.setRazonSocial(rs.getString("razon_social"));
                    e.setSector(rs.getString("sector"));
                    e.setLogoUrl(rs.getString("logo_url"));
                    e.setPais(rs.getString("pais"));
                    e.setTotalOfertas(rs.getInt("total_ofertas"));
                    lista.add(e);
                }
            }
        }
        return lista;
    }

    public int contarDirectorioPublico() throws SQLException {
        String sql = "SELECT COUNT(*) " + EMPRESA_PUBLICA + CON_OFERTA_VIGENTE;
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Lista liviana (id y nombre) para el filtro por empresa del buscador publico. */
    public List<Empresa> listarOpcionesFiltroPublico() throws SQLException {
        List<Empresa> lista = new ArrayList<>();
        String sql = "SELECT e.id_empresa,e.razon_social " + EMPRESA_PUBLICA + CON_OFERTA_VIGENTE
                + "ORDER BY e.razon_social,e.id_empresa";
        try (Connection cn = Conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Empresa e = new Empresa();
                e.setIdEmpresa(rs.getInt("id_empresa"));
                e.setRazonSocial(rs.getString("razon_social"));
                lista.add(e);
            }
        }
        return lista;
    }

    public void guardarFicha(int usuario, Empresa e) throws SQLException {
        if (!e.isFichaCompleta() || e.getRazonSocial()==null || e.getRazonSocial().trim().isEmpty()
                || e.getRazonSocial().length()>150 || e.getSector().length()>100
                || e.getPresentacion().length()>5000 || e.getLogros().length()>5000) {
            throw new IllegalArgumentException("Completa la presentacion, RUC de 11 digitos, sector, ano de inicio y logros. Si no hay logros registrados, indicalo.");
        }
        // Optimistic version prevents overwriting a decision or another browser's edits.
        try (Connection cn=Conexion.getConnection(); PreparedStatement ps=cn.prepareStatement(
                "UPDATE empresas SET razon_social=?,ruc=?,sector=?,presentacion=?,anio_inicio=?,logros=?,estado_revision='pendiente',motivo_revision='',fecha_revision=NULL,revisor_id=NULL,version_revision=version_revision+1 WHERE id_usuario=? AND version_revision=?")) {
            ps.setString(1,e.getRazonSocial()); ps.setString(2,e.getRuc()); ps.setString(3,e.getSector());
            ps.setString(4,e.getPresentacion()); ps.setInt(5,e.getAnioInicio()); ps.setString(6,e.getLogros());
            ps.setInt(7,usuario); ps.setInt(8,e.getVersionRevision());
            if(ps.executeUpdate()!=1) throw new IllegalArgumentException("La ficha cambio. Recarga la pagina antes de enviarla nuevamente.");
        }
    }

    public void revisar(int id, int version, int actor, String decision, String motivo) throws SQLException {
        if (!"aprobada".equals(decision) && !"rechazada".equals(decision))
            throw new IllegalArgumentException("Decision no valida.");
        if(motivo==null || motivo.length()>1000 || ("rechazada".equals(decision) && motivo.trim().isEmpty()))
            throw new IllegalArgumentException("Indica un motivo para rechazar la solicitud (maximo 1000 caracteres).");
        try(Connection cn=Conexion.getConnection()) {
            cn.setAutoCommit(false);
            try {
                try(PreparedStatement ps=cn.prepareStatement("SELECT id_usuario FROM usuarios WHERE id_usuario=? AND rol='ADMIN' AND estado='activo' FOR UPDATE")){
                    ps.setInt(1,actor);
                    try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Acceso no autorizado.");}
                }
                Empresa e;
                try(PreparedStatement ps=cn.prepareStatement("SELECT * FROM empresas WHERE id_empresa=? FOR UPDATE")){
                    ps.setInt(1,id);
                    try(ResultSet rs=ps.executeQuery()){e=rs.next()?mapear(rs):null;}
                }
                if(e==null || e.getVersionRevision()!=version || !"pendiente".equals(e.getEstadoRevision()))
                    throw new IllegalArgumentException("La solicitud ya fue revisada o modificada. Recarga la pagina.");
                if("aprobada".equals(decision) && !e.isFichaCompleta())
                    throw new IllegalArgumentException("La empresa debe completar su ficha antes de ser aprobada.");
                try(PreparedStatement ps=cn.prepareStatement("UPDATE empresas SET estado_revision=?,motivo_revision=?,revisor_id=?,fecha_revision=NOW(),version_revision=version_revision+1 WHERE id_empresa=?")){
                    ps.setString(1,decision);ps.setString(2,motivo.trim());ps.setInt(3,actor);ps.setInt(4,id);ps.executeUpdate();
                }
                cn.commit();
            } catch(SQLException|RuntimeException ex){cn.rollback();throw ex;}
        }
    }

    private Empresa mapear(ResultSet rs) throws SQLException {
        Empresa e = new Empresa();
        e.setIdEmpresa(rs.getInt("id_empresa"));
        e.setIdUsuario(rs.getInt("id_usuario"));
        e.setRazonSocial(rs.getString("razon_social"));
        e.setRuc(rs.getString("ruc"));
        e.setSector(rs.getString("sector"));
        e.setLogoUrl(rs.getString("logo_url"));
        e.setSelloInclusivo(rs.getString("sello_inclusivo"));
        e.setEstadoRevision(rs.getString("estado_revision"));
        e.setPresentacion(rs.getString("presentacion"));
        e.setAnioInicio((Integer) rs.getObject("anio_inicio"));
        e.setLogros(rs.getString("logros"));
        e.setMotivoRevision(rs.getString("motivo_revision"));
        e.setVersionRevision(rs.getInt("version_revision"));
        e.setSitioOficial(rs.getString("sitio_oficial"));
        e.setPais(rs.getString("pais"));
        return e;
    }

    private Empresa mapearPublica(ResultSet rs) throws SQLException {
        Empresa e = new Empresa();
        e.setIdEmpresa(rs.getInt("id_empresa"));
        e.setRazonSocial(rs.getString("razon_social"));
        e.setSector(rs.getString("sector"));
        e.setLogoUrl(rs.getString("logo_url"));
        e.setSelloInclusivo(rs.getString("sello_inclusivo"));
        e.setPresentacion(rs.getString("presentacion"));
        e.setAnioInicio((Integer) rs.getObject("anio_inicio"));
        e.setLogros(rs.getString("logros"));
        e.setSitioOficial(rs.getString("sitio_oficial"));
        e.setPais(rs.getString("pais"));
        e.setTotalOfertas(rs.getInt("total_ofertas"));
        return e;
    }
}
