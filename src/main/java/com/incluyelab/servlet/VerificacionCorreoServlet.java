package com.incluyelab.servlet;

import com.incluyelab.dao.OtpDAO;
import com.incluyelab.dao.OtpDAO.ResultadoOtp;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "VerificacionCorreoServlet", urlPatterns = {"/verificar-correo"})
public class VerificacionCorreoServlet extends HttpServlet {
    private final OtpDAO otpDao = new OtpDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Usuario usuario = session != null ? (Usuario) session.getAttribute("usuario") : null;

        if (usuario == null) {
            res.sendRedirect(req.getContextPath() + "/login?sesion=requerida");
            return;
        }

        // Si ya está verificado, enviar a su panel correspondiente
        if (usuario.isCorreoVerificado()) {
            res.sendRedirect(req.getContextPath() + panel(usuario));
            return;
        }

        try {
            // Asegurar que exista un código OTP pendiente activo
            String codigoPendiente = otpDao.obtenerCodigoPendiente(usuario.getIdUsuario(), "VERIFICACION_CORREO");
            if (codigoPendiente == null) {
                codigoPendiente = otpDao.generarOtp(usuario.getIdUsuario(), usuario.getCorreo(), "VERIFICACION_CORREO");
            }

            req.setAttribute("correoEnmascarado", enmascararCorreo(usuario.getCorreo()));
            req.setAttribute("codigoDemo", codigoPendiente);
            req.getRequestDispatcher("/WEB-INF/verificar-correo.jsp").forward(req, res);
        } catch (SQLException ex) {
            log("Error al consultar código OTP", ex);
            res.sendError(503, "No se pudo generar el código de verificación.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Usuario usuario = session != null ? (Usuario) session.getAttribute("usuario") : null;

        if (usuario == null) {
            res.sendRedirect(req.getContextPath() + "/login?sesion=requerida");
            return;
        }

        String accion = req.getParameter("accion");
        if ("reenviar".equalsIgnoreCase(accion)) {
            try {
                otpDao.generarOtp(usuario.getIdUsuario(), usuario.getCorreo(), "VERIFICACION_CORREO");
                res.sendRedirect(req.getContextPath() + "/verificar-correo?reenviado=ok");
            } catch (SQLException ex) {
                log("Error al reenviar código OTP", ex);
                req.setAttribute("error", "No se pudo generar un nuevo código. Intenta en un momento.");
                doGet(req, res);
            }
            return;
        }

        // Leer código OTP (soporta campo único o 6 casillas individuales)
        String codigo = req.getParameter("codigo");
        if (codigo == null || codigo.trim().isEmpty()) {
            StringBuilder sb = new StringBuilder();
            for (int i = 1; i <= 6; i++) {
                String d = req.getParameter("d" + i);
                if (d != null) sb.append(d.trim());
            }
            codigo = sb.toString();
        }

        try {
            ResultadoOtp resultado = otpDao.verificarOtp(usuario.getIdUsuario(), codigo);
            if (!resultado.isExito()) {
                req.setAttribute("error", resultado.getMensaje());
                doGet(req, res);
                return;
            }

            // Éxito: actualizar estado en memoria de la sesión
            usuario.setCorreoVerificado(true);

            // Redirigir según rol y requisitos
            if (usuario.isRequiereVerificacionConadis()) {
                res.sendRedirect(req.getContextPath() + "/verificacion-conadis?correo=verificado");
            } else {
                res.sendRedirect(req.getContextPath() + panel(usuario) + "?correo=verificado");
            }
        } catch (SQLException ex) {
            log("Error al validar código OTP", ex);
            req.setAttribute("error", "Error interno al verificar el código. Intenta nuevamente.");
            doGet(req, res);
        }
    }

    private String panel(Usuario u) {
        if ("ADMIN".equals(u.getRol())) return "/admin";
        if ("EMPRESA".equals(u.getRol())) return "/empresa";
        if ("RECURSOS_HUMANOS".equals(u.getRol())) return "/recursos-humanos";
        if ("SOPORTE_TECNICO".equals(u.getRol())) return "/soporte-tecnico";
        return "/postulante";
    }

    private String enmascararCorreo(String correo) {
        if (correo == null || !correo.contains("@")) return "tu correo";
        String[] partes = correo.split("@");
        String nombre = partes[0];
        String dominio = partes[1];
        if (nombre.length() <= 2) {
            return nombre.charAt(0) + "***@" + dominio;
        }
        return nombre.charAt(0) + "***" + nombre.charAt(nombre.length() - 1) + "@" + dominio;
    }
}
