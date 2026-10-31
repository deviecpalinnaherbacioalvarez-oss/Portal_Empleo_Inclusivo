package com.incluyelab.servlet;

import com.incluyelab.dao.UsuarioDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "PerfilServlet", urlPatterns = {"/perfil"})
public class PerfilServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            res.sendRedirect(req.getContextPath() + "/login?sesion=requerida"); return;
        }
        Usuario actor=(Usuario)session.getAttribute("usuario");
        if("POSTULANTE".equals(actor.getRol()) && !"1".equals(req.getParameter("seguridad"))){
            res.sendRedirect(req.getContextPath()+"/perfil-profesional");return;
        }
        if (session.getAttribute("perfilCsrf") == null) session.setAttribute("perfilCsrf", UUID.randomUUID().toString());
        req.getRequestDispatcher("/WEB-INF/perfil.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Usuario usuario = session == null ? null : (Usuario) session.getAttribute("usuario");
        if (usuario == null || session.getAttribute("perfilCsrf") == null
                || !session.getAttribute("perfilCsrf").equals(req.getParameter("csrf"))) {
            res.sendError(403, "Formulario no valido. Abre Mi perfil nuevamente."); return;
        }
        String actual = req.getParameter("actual");
        String nueva = req.getParameter("nueva");
        String confirmar = req.getParameter("confirmar");
        try {
            if (actual == null || actual.isEmpty() || actual.length() > 100) {
                throw new IllegalArgumentException("Ingresa tu contrasena actual.");
            }
            if (nueva == null || !nueva.equals(confirmar)) {
                throw new IllegalArgumentException("La nueva contrasena y su confirmacion no coinciden.");
            }
            new UsuarioDAO().cambiarContrasena(usuario, actual, nueva);
            session.invalidate();
            res.sendRedirect(req.getContextPath() + "/login?clave=actualizada");
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            res.setStatus(400);
            doGet(req, res);
        } catch (SQLException ex) {
            log("No se pudo cambiar la contrasena", ex);
            req.setAttribute("error", "No se pudo guardar el cambio. Intenta nuevamente en unos minutos.");
            res.setStatus(503);
            doGet(req, res);
        }
    }
}
