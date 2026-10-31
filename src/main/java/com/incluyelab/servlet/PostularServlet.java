package com.incluyelab.servlet;

import com.incluyelab.dao.PostulacionDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PostularServlet", urlPatterns = {"/postular"})
public class PostularServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null) { response.sendRedirect("login?sesion=requerida"); return; }
        if (!"POSTULANTE".equals(usuario.getRol())) { response.sendError(403,"Acceso exclusivo para postulantes."); return; }
        Object csrf=request.getSession().getAttribute("postulacionCsrf");
        if(csrf==null||!csrf.equals(request.getParameter("csrf"))){response.sendError(403);return;}
        try {
            if("eliminar".equals(request.getParameter("accion"))){
                new PostulacionDAO().eliminarPorUsuario(Integer.parseInt(request.getParameter("idPostulacion")),usuario.getIdUsuario());
                response.sendRedirect("postulante?ok=eliminada#postulaciones");
            }else{
                int idOferta = Integer.parseInt(request.getParameter("idOferta"));
                new PostulacionDAO().registrar(usuario.getIdUsuario(), idOferta);
                response.sendRedirect("postulante?ok=postulacion");
            }
        } catch (Exception ex) {
            log("No se pudo registrar la postulacion", ex);
            request.getSession().setAttribute("flashError", "No se pudo registrar. Verifica si ya postulaste o si la oferta sigue disponible.");
            response.sendRedirect("postulante");
        }
    }
}
