package com.incluyelab.servlet;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Usuario;
import com.incluyelab.service.AlmacenCarnetConadis;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/conadis-foto")
public class ConadisFotoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Usuario actor = (Usuario) req.getSession().getAttribute("usuario");
        int postulanteId;
        try {
            postulanteId = Integer.parseInt(req.getParameter("usuario"));
        } catch (Exception ex) {
            res.sendError(404);
            return;
        }
        if (actor == null) {
            res.sendError(403);
            return;
        }
        // Solo el titular o Recursos Humanos pueden consultar el archivo privado.
        if ("POSTULANTE".equals(actor.getRol()) && actor.getIdUsuario() != postulanteId) {
            res.sendError(403);
            return;
        }
        if (!"POSTULANTE".equals(actor.getRol()) && !"RECURSOS_HUMANOS".equals(actor.getRol())) {
            res.sendError(403);
            return;
        }

        try (Connection cn = Conexion.getConnection()) {
            String archivo = null;
            try (PreparedStatement ps = cn.prepareStatement("SELECT carnet_archivo FROM verificaciones_conadis WHERE id_usuario=?")) {
                ps.setInt(1, postulanteId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        archivo = rs.getString(1);
                    }
                }
            }
            if (archivo == null || archivo.trim().isEmpty()) {
                res.sendError(404);
                return;
            }
            if (archivo.startsWith("demo:")) {
                String nombre = archivo.substring("demo:".length());
                if (!nombre.matches("conadis-[a-z0-9-]+\\.(png|jpg)")) {
                    res.sendError(404);
                    return;
                }
                try (InputStream in = getServletContext().getResourceAsStream("/WEB-INF/demo/" + nombre)) {
                    if (in == null) {
                        res.sendError(404);
                        return;
                    }
                    res.setContentType(nombre.endsWith(".png") ? "image/png" : "image/jpeg");
                    res.setHeader("X-Content-Type-Options", "nosniff");
                    res.setHeader("Content-Disposition", "inline; filename=\"carnet-conadis."
                            + (nombre.endsWith(".png") ? "png" : "jpg") + "\"");
                    res.setHeader("Cache-Control", "private, no-store");
                    byte[] buffer = new byte[8192];
                    int read;
                    while ((read = in.read(buffer)) != -1) res.getOutputStream().write(buffer, 0, read);
                }
                return;
            }
            Path file;
            try { file=AlmacenCarnetConadis.resolverLectura(archivo); }
            catch(IllegalArgumentException ex){res.sendError(404);return;}
            if (!Files.isRegularFile(file)) {
                res.sendError(404);
                return;
            }

            res.setContentType("image/jpeg");
            res.setHeader("X-Content-Type-Options","nosniff");
            res.setHeader("Content-Disposition","inline; filename=\"carnet-conadis.jpg\"");
            res.setHeader("Cache-Control", "private, no-store");
            res.setContentLengthLong(Files.size(file));
            Files.copy(file, res.getOutputStream());
        } catch (SQLException ex) {
            log("No se pudo servir la foto del carnet CONADIS", ex);
            res.sendError(503);
        }
    }
}
