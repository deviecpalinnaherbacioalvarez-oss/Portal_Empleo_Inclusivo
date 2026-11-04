package com.incluyelab.servlet;

import com.incluyelab.dao.OfertaDAO;
import com.incluyelab.dao.PostulacionDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PostulanteServlet", urlPatterns = {"/postulante"})
public class PostulanteServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null) { response.sendRedirect("login?sesion=requerida"); return; }
        if (!"POSTULANTE".equals(usuario.getRol())) { response.sendError(403,"Acceso exclusivo para postulantes."); return; }
        try {
            if(request.getSession().getAttribute("postulacionCsrf")==null) request.getSession().setAttribute("postulacionCsrf",java.util.UUID.randomUUID().toString());
            if(request.getSession().getAttribute("notifCsrf")==null) request.getSession().setAttribute("notifCsrf",java.util.UUID.randomUUID().toString());
            request.setAttribute("ofertas", new OfertaDAO().listarActivas());
            request.setAttribute("postulaciones", new PostulacionDAO().listarPorUsuario(usuario.getIdUsuario()));
            request.setAttribute("notificaciones",new com.incluyelab.dao.NotificacionDAO().listar(usuario.getIdUsuario()));
            request.setAttribute("verificacionConadis",new com.incluyelab.dao.VerificacionConadisDAO().obtenerPorUsuario(usuario.getIdUsuario()));
        } catch (Exception ex) {
            request.setAttribute("error", ex.getMessage());
        }
        request.getRequestDispatcher("/postulante.jsp").forward(request, response);
    }
}
