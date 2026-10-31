package com.incluyelab.servlet;

import com.incluyelab.dao.UsuarioDAO;
import com.incluyelab.dao.UsuarioDAO.ResultadoLogin;
import com.incluyelab.dao.VerificacionConadisDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String correo = request.getParameter("correo");
        String contrasena = request.getParameter("contrasena");
        try {
            ResultadoLogin resultado = new UsuarioDAO().autenticar(correo, contrasena);
            if (resultado.getEstado() == ResultadoLogin.Estado.BLOQUEADO) {
                long minutos=Math.max(1,(resultado.getSegundosBloqueo()+59)/60);
                request.setAttribute("error", "Cuenta bloqueada temporalmente por seguridad. Intenta nuevamente en " + minutos + (minutos==1?" minuto.":" minutos."));
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            if (resultado.getEstado() == ResultadoLogin.Estado.TEMPORAL_EXPIRADA) {
                request.setAttribute("error", "La contraseña temporal venció. Envía un nuevo reporte a Soporte Técnico para recuperar el acceso.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            if (resultado.getEstado() != ResultadoLogin.Estado.EXITO) {
                String detalle=resultado.getIntentosRestantes()>0?" Te quedan "+resultado.getIntentosRestantes()+" intentos antes del bloqueo de 1 hora.":"";
                request.setAttribute("error", "Correo o contraseña incorrectos."+detalle);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            Usuario usuario = resultado.getUsuario();
            if ("POSTULANTE".equals(usuario.getRol())) usuario.setConadisEstado(new VerificacionConadisDAO().estado(usuario.getIdUsuario()));
            HttpSession anterior = request.getSession(false);
            if (anterior != null) anterior.invalidate();
            HttpSession session = request.getSession(true);
            usuario.setContrasena(null);
            session.setAttribute("usuario", usuario);
            session.setMaxInactiveInterval(30 * 60);
            if (usuario.isRequiereCambioClave()) {
                response.sendRedirect("perfil?cambio=obligatorio");
                return;
            }
            if (!usuario.isCorreoVerificado()) {
                response.sendRedirect("verificar-correo");
                return;
            }
            // Flujo de Verificacion de Identidad Digital: segundo paso tras la contrasena.
            if (usuario.isRequiereVerificacionConadis()) {
                response.sendRedirect("verificacion-conadis");
                return;
            }
            String oferta = request.getParameter("oferta");
            if ("POSTULANTE".equals(usuario.getRol()) && oferta != null && oferta.matches("[0-9]{1,9}")) {
                response.sendRedirect("inicio?oferta=" + oferta + "#ofertas");
                return;
            }
            switch (usuario.getRol()) {
                case "ADMIN":
                    response.sendRedirect("admin");
                    break;
                case "EMPRESA":
                    response.sendRedirect("empresa");
                    break;
                case "RECURSOS_HUMANOS":
                    response.sendRedirect("recursos-humanos");
                    break;
                case "SOPORTE_TECNICO":
                    response.sendRedirect("soporte-tecnico");
                    break;
                default:
                    response.sendRedirect("postulante");
                    break;
            }
        } catch (Exception ex) {
            log("No se pudo iniciar sesion", ex);
            request.setAttribute("error", "No se pudo iniciar sesion. Intenta nuevamente en unos minutos.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
