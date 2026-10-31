package com.incluyelab.servlet;

import com.incluyelab.dao.VerificacionConadisDAO;
import com.incluyelab.dao.VerificacionConadisDAO.ResultadoEnvio;
import com.incluyelab.model.Usuario;
import com.incluyelab.model.VerificacionConadis;
import com.incluyelab.security.ConadisValidator;
import com.incluyelab.service.AlmacenCarnetConadis;
import java.io.*;
import java.nio.file.*;
import java.sql.SQLException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/verificacion-conadis")
@MultipartConfig(maxFileSize = 6 * 1024 * 1024, maxRequestSize = 8 * 1024 * 1024)
public class VerificacionConadisServlet extends HttpServlet {
    private final VerificacionConadisDAO dao = new VerificacionConadisDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getSession().getAttribute("usuario");
        if (usuario == null || !"POSTULANTE".equals(usuario.getRol())) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (req.getSession().getAttribute("conadisCsrf") == null) {
            req.getSession().setAttribute("conadisCsrf", UUID.randomUUID().toString());
        }

        try {
            VerificacionConadis verificacion = dao.obtenerPorUsuario(usuario.getIdUsuario());
            req.setAttribute("verificacion", verificacion);
            req.getRequestDispatcher("/WEB-INF/verificacion-conadis.jsp").forward(req, res);
        } catch (SQLException ex) {
            log("Error al consultar verificacion CONADIS", ex);
            res.sendError(503, "No se pudo consultar el estado de tu verificación.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Usuario usuario = (Usuario) req.getSession().getAttribute("usuario");
        if (usuario == null || !"POSTULANTE".equals(usuario.getRol())) {
            res.sendError(403, "Acción no permitida.");
            return;
        }

        Object token = req.getSession().getAttribute("conadisCsrf");
        if (token == null || !token.equals(req.getParameter("csrf"))) {
            res.sendError(403, "Formulario caducado. Vuelve a intentarlo.");
            return;
        }

        String nombreArchivoFinal = null;

        try {
            String rui=ConadisValidator.rui(req.getParameter("rui"));
            nombreArchivoFinal=AlmacenCarnetConadis.guardar(req.getPart("carnetFoto"));
            ResultadoEnvio resultado=dao.enviarSolicitud(usuario.getIdUsuario(),rui,nombreArchivoFinal);
            usuario.setConadisEstado(resultado.getEstado());

            req.getSession().setAttribute("conadisAviso","Solicitud enviada. Recursos Humanos realizará una revisión manual.");
            res.sendRedirect(req.getContextPath()+"/verificacion-conadis");
        } catch (IllegalArgumentException ex) {
            AlmacenCarnetConadis.eliminarSiExiste(nombreArchivoFinal);
            req.setAttribute("error", ex.getMessage());
            doGet(req, res);
        } catch (SQLException ex) {
            AlmacenCarnetConadis.eliminarSiExiste(nombreArchivoFinal);
            log("Error al procesar verificación CONADIS", ex);
            req.setAttribute("error", "No se pudo registrar la verificación en este momento. Intenta de nuevo.");
            doGet(req, res);
        } catch (IOException ex) {
            AlmacenCarnetConadis.eliminarSiExiste(nombreArchivoFinal);
            log("No se pudo almacenar la imagen CONADIS",ex);
            req.setAttribute("error","No se pudo procesar la fotografía. Intenta con otra imagen JPG o PNG.");
            doGet(req,res);
        }
    }
}
