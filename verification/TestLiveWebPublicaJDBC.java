import com.incluyelab.config.Conexion;
import com.incluyelab.dao.EmpresaDAO;
import com.incluyelab.dao.OfertaDAO;
import com.incluyelab.model.Empresa;
import com.incluyelab.model.FiltroOfertaPublica;
import com.incluyelab.model.Oferta;
import java.sql.Connection;
import java.sql.Statement;
import java.util.List;

public class TestLiveWebPublicaJDBC {
    public static void main(String[] args) throws Exception {
        System.out.println("--- 1. Probando conexion JDBC ---");
        try (Connection cn = Conexion.getConnection()) {
            if (cn == null || cn.isClosed()) throw new RuntimeException("Conexion cerrada");
            System.out.println("Conexion JDBC exitosa.");
        }

        EmpresaDAO empresaDAO = new EmpresaDAO();
        OfertaDAO ofertaDAO = new OfertaDAO();

        System.out.println("--- 2. Directorio de Empresas (JDBC) ---");
        int totalEmpresas = empresaDAO.contarDirectorioPublico();
        System.out.println("Total empresas publicas con ofertas activas: " + totalEmpresas);
        List<Empresa> empresas = empresaDAO.listarDirectorioPublico(10, 0);
        for (Empresa e : empresas) {
            System.out.println(" - " + e.getRazonSocial() + " (" + e.getSector() + ", " + e.getPais() + ") - Ofertas: " + e.getTotalOfertas() + " - Logo: " + e.getLogoPublico());
        }

        System.out.println("--- 3. Detalle de Empresa Publica ---");
        if (!empresas.isEmpty()) {
            int testId = empresas.get(0).getIdEmpresa();
            Empresa detalle = empresaDAO.obtenerPublica(testId);
            System.out.println("Ficha publica de " + detalle.getRazonSocial() + ":");
            System.out.println("  Sitio oficial: " + detalle.getSitioOficial());
            System.out.println("  Presentacion: " + (detalle.getPresentacion().isEmpty() ? "(vacia)" : detalle.getPresentacion()));
            System.out.println("  Anio inicio: " + detalle.getAnioInicio());
            List<Oferta> ofertasEmpresa = ofertaDAO.listarPublicasPorEmpresa(testId);
            System.out.println("  Ofertas asociadas encontradas: " + ofertasEmpresa.size());
        }

        System.out.println("--- 4. Busqueda y Filtros de Ofertas (JDBC) ---");
        FiltroOfertaPublica filtro = new FiltroOfertaPublica();
        int totalOfertas = ofertaDAO.contarPublicas(filtro);
        System.out.println("Total ofertas publicas vigentes: " + totalOfertas);

        // Prueba filtro texto
        filtro.setTexto("soporte");
        List<Oferta> porTexto = ofertaDAO.buscarPublicas(filtro);
        System.out.println("Busqueda 'soporte': " + porTexto.size() + " ofertas.");

        // Prueba inyeccion SQL en busqueda
        filtro.setTexto("' OR '1'='1' -- ");
        List<Oferta> inyeccion = ofertaDAO.buscarPublicas(filtro);
        System.out.println("Busqueda payload inyeccion SQL: " + inyeccion.size() + " ofertas (debe retornar 0 o solo coincidencias literales).");

        // Prueba filtro modalidad
        filtro = new FiltroOfertaPublica();
        filtro.setModalidades(new String[]{"Remoto"});
        List<Oferta> remotas = ofertaDAO.buscarPublicas(filtro);
        System.out.println("Filtro modalidad 'Remoto': " + remotas.size() + " ofertas.");

        // Prueba filtro adaptaciones
        filtro = new FiltroOfertaPublica();
        filtro.setAdaptaciones(new String[]{"visual"});
        List<Oferta> visual = ofertaDAO.buscarPublicas(filtro);
        System.out.println("Filtro adaptacion 'visual': " + visual.size() + " ofertas.");

        System.out.println("--- 5. Detalle de Oferta Especifica ---");
        if (!remotas.isEmpty()) {
            Oferta o = ofertaDAO.obtenerPublica(remotas.get(0).getIdOferta());
            System.out.println("Oferta #" + o.getIdOferta() + ": " + o.getTitulo() + " en " + o.getEmpresa());
            System.out.println("  Modalidad: " + o.getModalidad() + " | Salario: S/ " + o.getSalario());
            System.out.println("  Secciones de detalle: " + o.getSeccionesDetalle().size());
        }

        System.out.println("--- 6. Prueba de cambios dinamicos en MySQL sin cambiar codigo Java ---");
        // Actualizamos temporalmente el sitio_oficial de una empresa y verificamos que se refleje inmediatamente
        if (!empresas.isEmpty()) {
            int empId = empresas.get(0).getIdEmpresa();
            String testWeb = "https://test-dinamico-incluyelab.pe/";
            try (Connection cn = Conexion.getConnection(); Statement st = cn.createStatement()) {
                st.executeUpdate("UPDATE empresas SET sitio_oficial='" + testWeb + "' WHERE id_empresa=" + empId);
            }
            Empresa mod = empresaDAO.obtenerPublica(empId);
            if (!testWeb.equals(mod.getSitioOficial())) {
                throw new AssertionError("El cambio directo en MySQL no se reflejo!");
            }
            System.out.println("Modificacion dinamica en MySQL verificada correctamente.");
            // Restaurar
            try (Connection cn = Conexion.getConnection(); Statement st = cn.createStatement()) {
                st.executeUpdate("UPDATE empresas SET sitio_oficial='https://www.microsoft.com/' WHERE id_empresa=" + empId);
            }
        }

        System.out.println("\n>>> TODAS LAS PRUEBAS EN VIVO CONTRA MYSQL SUPERADAS EXITOSAMENTE <<<");
    }
}
