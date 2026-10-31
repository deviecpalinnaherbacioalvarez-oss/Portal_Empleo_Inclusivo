package com.incluyelab.servlet;

import com.incluyelab.dao.EmpresaDAO;
import com.incluyelab.dao.OfertaDAO;
import com.incluyelab.model.Empresa;
import com.incluyelab.model.Oferta;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "OfertaServlet", urlPatterns = {"/oferta"})
public class OfertaServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null) { response.sendRedirect("login?sesion=requerida"); return; }
        if (!"EMPRESA".equals(usuario.getRol())) { response.sendError(403,"Acceso exclusivo para empresas."); return; }
        Object csrf=request.getSession().getAttribute("empresaCsrf");
        if(csrf==null || !csrf.equals(request.getParameter("csrf"))){response.sendError(403);return;}
        try {
            Empresa empresa = new EmpresaDAO().obtenerPorUsuario(usuario.getIdUsuario());
            if (empresa == null) {
                response.sendRedirect("empresa?error=empresa");
                return;
            }
            if(!empresa.isAprobada()){response.sendError(403,"Tu empresa requiere aprobacion antes de publicar.");return;}
            OfertaDAO dao = new OfertaDAO();
            String accion=request.getParameter("accion");
            if(accion==null||accion.isEmpty())accion="crear";
            if("eliminar".equals(accion)) {
                int id=Integer.parseInt(request.getParameter("id"));
                dao.eliminar(id,empresa.getIdEmpresa());
                request.getSession().setAttribute("empresaNotice","La oferta y sus postulaciones asociadas fueron eliminadas correctamente.");
                response.sendRedirect("empresa#publicadas");
                return;
            }
            if(!"crear".equals(accion)&&!"editar".equals(accion))throw new IllegalArgumentException("Accion no valida.");
            Oferta oferta = new Oferta();
            oferta.setIdEmpresa(empresa.getIdEmpresa());
            oferta.setTitulo(request.getParameter("titulo"));
            oferta.setModalidad(request.getParameter("modalidad"));
            oferta.setUbicacion(request.getParameter("ubicacion"));
            oferta.setAdaptaciones(request.getParameter("adaptaciones"));
            oferta.setApoyos(com.incluyelab.model.ApoyosOferta.validar(request.getParameterValues("apoyos")));
            oferta.setDescripcion(request.getParameter("descripcion"));
            oferta.setSalario(new BigDecimal(request.getParameter("salario")));
            if("editar".equals(accion)) {
                oferta.setIdOferta(Integer.parseInt(request.getParameter("id")));
                oferta.setEstado("cerrada".equals(request.getParameter("estado"))?"cerrada":"activa");
                dao.actualizar(oferta);
                request.getSession().setAttribute("empresaNotice","La oferta fue actualizada correctamente.");
                response.sendRedirect("empresa#publicadas");
            } else {
                dao.registrar(oferta);
                response.sendRedirect("empresa?ok=oferta");
            }
        } catch (Exception ex) {
            log("No se pudo registrar la oferta", ex);
            request.setAttribute("error", ex instanceof IllegalArgumentException ? "Revisa los datos y las adaptaciones seleccionadas." : "No se pudo registrar la oferta. Intenta nuevamente.");
            try {
                Empresa empresa = new EmpresaDAO().obtenerPorUsuario(usuario.getIdUsuario());
                request.setAttribute("empresa",empresa);
                if (empresa != null) request.setAttribute("ofertas",new OfertaDAO().listarPorEmpresa(empresa.getIdEmpresa()));
            } catch (java.sql.SQLException ignored) { log("No se pudo recargar el panel", ignored); }
            request.getRequestDispatcher("/empresa.jsp").forward(request, response);
        }
    }
}
