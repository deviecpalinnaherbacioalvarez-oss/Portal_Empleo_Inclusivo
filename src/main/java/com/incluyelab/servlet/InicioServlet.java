package com.incluyelab.servlet;

import com.incluyelab.dao.OfertaDAO;
import com.incluyelab.dao.EmpresaDAO;
import com.incluyelab.model.FiltroOfertaPublica;
import com.incluyelab.model.Oferta;
import java.io.IOException;
import java.util.Collections;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "InicioServlet", urlPatterns = {"/inicio"})
public class InicioServlet extends HttpServlet {
    private static final int EMPRESAS_POR_PAGINA = 12;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if(request.getSession().getAttribute("postulacionCsrf")==null) request.getSession().setAttribute("postulacionCsrf",java.util.UUID.randomUUID().toString());
        try {
            FiltroOfertaPublica filtro = crearFiltro(request);
            OfertaDAO ofertaDAO = new OfertaDAO();
            Integer ofertaSolicitada = enteroPositivo(request.getParameter("oferta"));
            int total;
            int paginas;
            if (ofertaSolicitada != null) {
                Oferta oferta = ofertaDAO.obtenerPublica(ofertaSolicitada);
                if (oferta == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
                request.setAttribute("ofertas", Collections.singletonList(oferta));
                total = 1;
                paginas = 1;
                filtro.setPagina(1);
            } else {
                total = ofertaDAO.contarPublicas(filtro);
                paginas = Math.max(1, (int)Math.ceil(total / (double)filtro.getTamanoPagina()));
                if (filtro.getPagina() > paginas) filtro.setPagina(paginas);
                request.setAttribute("ofertas", ofertaDAO.buscarPublicas(filtro));
            }
            request.setAttribute("totalOfertas", total);
            request.setAttribute("paginaActual", filtro.getPagina());
            request.setAttribute("totalPaginas", paginas);
            request.setAttribute("filtro", filtro);

            EmpresaDAO empresaDAO = new EmpresaDAO();
            int totalEmpresas = empresaDAO.contarDirectorioPublico();
            int paginasEmpresas = Math.max(1, (int)Math.ceil(totalEmpresas / (double)EMPRESAS_POR_PAGINA));
            Integer paginaSolicitada = enteroPositivo(request.getParameter("pagina_empresas"));
            int paginaEmpresas = Math.min(paginaSolicitada == null ? 1 : paginaSolicitada, paginasEmpresas);
            request.setAttribute("empresasPublicas",
                    empresaDAO.listarDirectorioPublico(EMPRESAS_POR_PAGINA, (paginaEmpresas - 1) * EMPRESAS_POR_PAGINA));
            request.setAttribute("empresasFiltro", empresaDAO.listarOpcionesFiltroPublico());
            request.setAttribute("totalEmpresas", totalEmpresas);
            request.setAttribute("paginaEmpresas", paginaEmpresas);
            request.setAttribute("totalPaginasEmpresas", paginasEmpresas);
        } catch (Exception ex) {
            // El detalle tecnico queda solo en el log del servidor; el visitante ve un mensaje generico.
            log("No se pudo cargar la web publica", ex);
            request.setAttribute("error", "No pudimos cargar las oportunidades en este momento.");
        }
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private FiltroOfertaPublica crearFiltro(HttpServletRequest request) {
        FiltroOfertaPublica filtro = new FiltroOfertaPublica();
        filtro.setTexto(request.getParameter("q"));
        filtro.setUbicacion(request.getParameter("ubicacion"));
        filtro.setIdEmpresa(enteroPositivo(request.getParameter("empresa")));
        filtro.setModalidades(request.getParameterValues("modalidad"));
        filtro.setAdaptaciones(request.getParameterValues("adaptacion"));
        filtro.setOrden(request.getParameter("orden"));
        Integer pagina = enteroPositivo(request.getParameter("pagina"));
        filtro.setPagina(pagina == null ? 1 : pagina);
        return filtro;
    }

    private Integer enteroPositivo(String valor) {
        if (valor == null || !valor.matches("[0-9]{1,9}")) return null;
        try {
            int numero = Integer.parseInt(valor);
            return numero > 0 ? numero : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
