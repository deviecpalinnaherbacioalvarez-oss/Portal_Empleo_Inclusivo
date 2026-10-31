import com.incluyelab.model.Empresa;
import com.incluyelab.model.FiltroOfertaPublica;
import com.incluyelab.model.Oferta;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

public class WebPublicaPart6Smoke {
    private static int checks;

    public static void main(String[] args) throws Exception {
        FiltroOfertaPublica filtro = new FiltroOfertaPublica();
        filtro.setTexto("  soporte   técnico  ");
        check("soporte técnico".equals(filtro.getTexto()), "normaliza texto");
        filtro.setModalidades(new String[]{"Remoto", "INVALIDA", "Remoto"});
        check(filtro.getModalidades().size()==1 && filtro.getModalidades().contains("Remoto"), "modalidades permitidas");
        filtro.setAdaptaciones(new String[]{"visual", "' OR 1=1 --", "auditiva"});
        check(filtro.getAdaptaciones().size()==2, "adaptaciones permitidas");
        filtro.setOrden("DROP TABLE ofertas");
        check("recent".equals(filtro.getOrden()), "orden restringido");
        filtro.setPagina(-20);
        filtro.setTamanoPagina(500);
        check(filtro.getPagina()==1 && filtro.getTamanoPagina()==24, "limites de paginacion");

        Empresa empresa = new Empresa();
        empresa.setLogoUrl("assets/logos/yape.png");
        check("assets/logos/yape.png".equals(empresa.getLogoPublico()), "logo local permitido");
        empresa.setLogoUrl("javascript:alert(1)");
        check(empresa.getLogoPublico().isEmpty(), "logo inseguro rechazado");
        empresa.setSitioOficial("javascript:alert(1)");
        check(empresa.getSitioOficial().isEmpty(), "sitio inseguro rechazado");
        Oferta oferta = new Oferta();
        oferta.setLogoUrl("../WEB-INF/web.xml");
        check(oferta.getLogoPublico().isEmpty(), "traversal de logo rechazado");

        Path root = Path.of(System.getProperty("projectRoot", "."));
        String ofertaDao = read(root,"src/main/java/com/incluyelab/dao/OfertaDAO.java");
        String empresaDao = read(root,"src/main/java/com/incluyelab/dao/EmpresaDAO.java");
        String inicio = read(root,"src/main/java/com/incluyelab/servlet/InicioServlet.java");
        String empresaPublica = read(root,"src/main/java/com/incluyelab/servlet/EmpresaPublicaServlet.java");
        String index = read(root,"src/main/webapp/index.jsp");
        String migration = read(root,"database/migrations/20261029_web_publica_jdbc.sql");
        check(!Files.exists(root.resolve("src/main/java/com/incluyelab/model/DirectorioEmpresas.java")), "catalogo estatico eliminado");
        check(ofertaDao.contains("PreparedStatement") && ofertaDao.contains("try (Connection"), "JDBC seguro en ofertas");
        check(ofertaDao.contains("LIMIT ? OFFSET ?") && ofertaDao.contains("contarPublicas"), "paginacion JDBC");
        check(ofertaDao.contains("LIKE ? ESCAPE") && !ofertaDao.contains("request.getParameter"), "busqueda parametrizada");
        check(empresaDao.contains("listarDirectorioPublico") && empresaDao.contains("contarDirectorioPublico")
                && empresaDao.contains("obtenerPublica"), "directorio JDBC paginado");
        check(!read(root,"src/main/webapp/WEB-INF/jspf/helpers.jspf").contains("logo("), "sin mapa estatico de logos");
        check(inicio.contains("buscarPublicas") && inicio.contains("crearFiltro"), "controlador aplica filtros");
        check(empresaPublica.contains("listarPublicasPorEmpresa") && !empresaPublica.contains("DirectorioEmpresas"), "ficha y ofertas relacionadas");
        check(index.contains("getLogoPublico") && index.contains("pagination-nav"), "vista usa datos JDBC");
        check(migration.contains("sitio_oficial") && migration.contains("idx_ofertas_publicas"), "migracion publica");
        check(!migration.contains("INSERT INTO usuarios") && !migration.contains("INSERT INTO empresas"), "migracion no crea cuentas ficticias");
        check(!ofertaDao.contains("u.correo") && !empresaDao.substring(empresaDao.indexOf("obtenerPublica"), empresaDao.indexOf("guardarFicha")).contains("e.ruc"), "consultas publicas no exponen datos privados");
        System.out.println("OK - " + checks + " comprobaciones de web publica JDBC superadas.");
    }

    private static String read(Path root, String file) throws Exception {
        return Files.readString(root.resolve(file), StandardCharsets.UTF_8);
    }
    private static void check(boolean condition, String name) {
        checks++;
        if (!condition) throw new AssertionError("Fallo: " + name);
    }
}
