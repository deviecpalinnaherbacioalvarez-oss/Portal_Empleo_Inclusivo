package com.incluyelab.servlet;

import com.incluyelab.dao.EmpresaDAO;
import com.incluyelab.dao.OfertaDAO;
import com.incluyelab.dao.PostulacionDAO;
import com.incluyelab.model.Empresa;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "EmpresaServlet", urlPatterns = {"/empresa"})
public class EmpresaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null) { response.sendRedirect("login?sesion=requerida"); return; }
        if (!"EMPRESA".equals(usuario.getRol())) { response.sendError(403,"Acceso exclusivo para empresas."); return; }
        try {
            if(request.getSession().getAttribute("empresaCsrf")==null) request.getSession().setAttribute("empresaCsrf",java.util.UUID.randomUUID().toString());
            if(request.getSession().getAttribute("notifCsrf")==null) request.getSession().setAttribute("notifCsrf",java.util.UUID.randomUUID().toString());
            Empresa empresa = new EmpresaDAO().obtenerPorUsuario(usuario.getIdUsuario());
            request.setAttribute("empresa", empresa);
            request.setAttribute("ofertas", empresa == null ? null : new OfertaDAO().listarPorEmpresa(empresa.getIdEmpresa()));
            request.setAttribute("candidatos", empresa == null ? null : new PostulacionDAO().listarPorEmpresa(usuario.getIdUsuario()));
            request.setAttribute("evaluacionesRrhh", empresa == null ? null : new com.incluyelab.dao.RecursosHumanosDAO().evaluacionesPublicadasEmpresa(usuario.getIdUsuario()));
            request.setAttribute("notificaciones",new com.incluyelab.dao.NotificacionDAO().listar(usuario.getIdUsuario()));
            String editar=request.getParameter("editar");
            if(empresa!=null && editar!=null && editar.matches("[0-9]{1,9}")) {
                com.incluyelab.model.Oferta ofertaEditar=new OfertaDAO().obtenerPorEmpresa(Integer.parseInt(editar),empresa.getIdEmpresa());
                if(ofertaEditar==null){response.sendError(404,"La oferta no existe o no pertenece a tu empresa.");return;}
                request.setAttribute("ofertaEditar",ofertaEditar);
            }
        } catch (Exception ex) {
            log("No se pudo cargar la empresa",ex);
            request.setAttribute("error", "No se pudo cargar el panel. Intenta nuevamente.");
        }
        request.getRequestDispatcher("/empresa.jsp").forward(request, response);
    }
}
