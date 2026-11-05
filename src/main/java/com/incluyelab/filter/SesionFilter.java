package com.incluyelab.filter;

import com.incluyelab.dao.UsuarioDAO;
import com.incluyelab.model.Usuario;
import com.incluyelab.security.Permisos;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter(urlPatterns = "/*", dispatcherTypes = DispatcherType.REQUEST)
public class SesionFilter implements Filter {
    public static String panel(Usuario usuario) {
        switch (usuario.getRol()) {
            case "ADMIN": return "/admin";
            case "EMPRESA": return "/empresa";
            case "RECURSOS_HUMANOS": return "/recursos-humanos";
            case "SOPORTE_TECNICO": return "/soporte-tecnico";
            default: return "/postulante";
        }
    }

    @Override
    public void doFilter(ServletRequest input, ServletResponse output, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) input;
        HttpServletResponse res = (HttpServletResponse) output;
        req.setCharacterEncoding("UTF-8");
        String ruta = req.getServletPath();
        if (ruta.startsWith("/assets/")) { chain.doFilter(req,res); return; }
        res.setHeader("Cache-Control","no-store, no-cache, must-revalidate");
        res.setHeader("Pragma","no-cache");
        res.setDateHeader("Expires",0);
        HttpSession sesion = req.getSession(false);
        Usuario usuario = sesion == null ? null : (Usuario) sesion.getAttribute("usuario");
        boolean revocada = false;
        // Recheck the database so disabling an account also revokes an existing session.
        if (usuario != null) {
            try {
                Usuario actual = new UsuarioDAO().obtenerActivo(usuario.getIdUsuario());
                if (actual == null || !actual.getRol().equals(usuario.getRol())
                        || !java.util.Objects.equals(actual.getCredencialVersion(),usuario.getCredencialVersion())) {
                    sesion.invalidate(); sesion = null; usuario = null; revocada = true;
                } else { usuario = actual; sesion.setAttribute("usuario",actual); }
            } catch (SQLException ex) {
                req.getServletContext().log("No se pudo verificar la sesion",ex);
                res.sendError(503,"No se pudo verificar la sesion. Intenta nuevamente."); return;
            }
        }
        String rol = Permisos.rolRequerido(ruta);
        boolean protegida = rol != null || ruta.equals("/perfil") || ruta.equals("/cv") || ruta.equals("/foto-perfil")
                || ruta.equals("/conadis-foto") || ruta.equals("/conversacion");
        if (protegida && usuario == null) {
            if (!"GET".equals(req.getMethod())) { res.sendError(403,"Inicia sesion para realizar esta accion."); return; }
            String motivo = revocada ? "revocada" : req.getRequestedSessionId()!=null && !req.isRequestedSessionIdValid() ? "expirada" : "requerida";
            res.sendRedirect(req.getContextPath()+"/login?sesion="+motivo); return;
        }
        if (rol != null && !rol.equals(usuario.getRol())) {
            res.sendError(403,"Tu cuenta no tiene permiso para esta accion.");
            return;
        }
        if (usuario != null && usuario.isRequiereCambioClave()
                && !ruta.equals("/perfil") && !ruta.equals("/logout")) {
            if ("GET".equals(req.getMethod())) res.sendRedirect(req.getContextPath()+"/perfil?cambio=obligatorio");
            else res.sendError(403,"Debes cambiar la clave temporal antes de continuar.");
            return;
        }
        if (usuario != null && !usuario.isCorreoVerificado()
                && !ruta.equals("/verificar-correo") && !ruta.equals("/logout") && !ruta.equals("/soporte") && !ruta.startsWith("/assets/")) {
            if ("GET".equals(req.getMethod())) res.sendRedirect(req.getContextPath()+"/verificar-correo");
            else res.sendError(403,"Debes verificar tu correo electronico con el codigo OTP antes de continuar.");
            return;
        }
        if (ruta.equals("/verificar-correo")) {
            if (usuario == null) {
                res.sendRedirect(req.getContextPath()+"/login?sesion=requerida");
                return;
            }
            chain.doFilter(req, res);
            return;
        }
        if (usuario != null && usuario.isRequiereVerificacionConadis()
                && !ruta.equals("/verificacion-conadis") && !ruta.equals("/conadis-foto") && !ruta.equals("/logout") && !ruta.equals("/soporte")) {
            if ("GET".equals(req.getMethod())) res.sendRedirect(req.getContextPath()+"/verificacion-conadis");
            else res.sendError(403,"Debes verificar tu carnet CONADIS antes de continuar.");
            return;
        }
        if (ruta.equals("/login") || ruta.equals("/login.jsp") || ruta.equals("/registro") || ruta.equals("/registro.jsp")) {
            if (usuario != null) { res.sendRedirect(req.getContextPath()+panel(usuario)); return; }
        }
        if ("GET".equals(req.getMethod()) && ruta.endsWith(".jsp") && (rol != null || ruta.equals("/login.jsp") || ruta.equals("/registro.jsp"))) {
            res.sendRedirect(req.getContextPath()+ruta.substring(0,ruta.length()-4)); return;
        }
        chain.doFilter(req,res);
    }
}
