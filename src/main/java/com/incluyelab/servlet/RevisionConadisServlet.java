package com.incluyelab.servlet;

import com.incluyelab.dao.VerificacionConadisDAO;
import com.incluyelab.model.Usuario;
import com.incluyelab.model.VerificacionConadis;
import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/revision-conadis")
public class RevisionConadisServlet extends HttpServlet {
    private final VerificacionConadisDAO dao = new VerificacionConadisDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Usuario actor = (Usuario) req.getSession().getAttribute("usuario");
        if (actor == null) { res.sendRedirect(req.getContextPath() + "/login?sesion=requerida"); return; }
        if (!"RECURSOS_HUMANOS".equals(actor.getRol())) { res.sendError(403,"Acceso exclusivo para Recursos Humanos."); return; }

        try {
            int usuarioId = Integer.parseInt(req.getParameter("id"));
            VerificacionConadis verif = dao.obtenerPorUsuario(usuarioId);
            if (verif == null) {
                res.sendError(404, "No se encontró la verificación de CONADIS solicitada.");
                return;
            }

            if (req.getSession().getAttribute("revisionConadisCsrf") == null) {
                req.getSession().setAttribute("revisionConadisCsrf", UUID.randomUUID().toString());
            }

            req.setAttribute("verificacion", verif);
            req.setAttribute("historial",dao.historial(verif.getIdVerificacion()));
            req.setAttribute("discapacidades",dao.discapacidades());
            req.getRequestDispatcher("/WEB-INF/conadis-revision.jsp").forward(req, res);
        } catch (NumberFormatException ex) {
            res.sendError(404);
        } catch (SQLException ex) {
            log("Error al cargar revisión de carnet CONADIS", ex);
            res.sendError(503);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Usuario actor = (Usuario) req.getSession().getAttribute("usuario");
        if (actor == null || !"RECURSOS_HUMANOS".equals(actor.getRol())) {
            res.sendError(403);
            return;
        }

        Object token = req.getSession().getAttribute("revisionConadisCsrf");
        if (token == null || !token.equals(req.getParameter("csrf"))) {
            res.sendError(403, "Token de seguridad no válido.");
            return;
        }

        try {
            int usuarioId = Integer.parseInt(req.getParameter("id"));
            String decision = req.getParameter("decision");
            String motivo = req.getParameter("motivo");

            int discapacidad=0;if("aprobar".equals(decision)){try{discapacidad=Integer.parseInt(req.getParameter("idDiscapacidad"));}catch(Exception ex){throw new IllegalArgumentException("Selecciona una discapacidad del catálogo.");}}
            dao.revisar(usuarioId,decision,motivo,actor.getIdUsuario(),req.getParameter("rui"),req.getParameter("dni"),req.getParameter("apellidos"),req.getParameter("nombres"),req.getParameter("fechaCaducidad"),discapacidad);

            req.getSession().setAttribute("adminNotice", "Decisión guardada con éxito. El postulante verá el resultado al ingresar a la plataforma.");
            res.sendRedirect(req.getContextPath() + "/recursos-humanos#conadis");
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            doGet(req, res);
        } catch (SQLException ex) {
            log("Error al registrar revisión de carnet CONADIS", ex);
            req.setAttribute("error", "Error al guardar la revisión en la base de datos.");
            doGet(req, res);
        }
    }
}
