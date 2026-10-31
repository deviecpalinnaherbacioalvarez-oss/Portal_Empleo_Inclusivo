package com.incluyelab.servlet;

import com.incluyelab.dao.UsuarioDAO;
import com.incluyelab.dao.VerificacionConadisDAO;
import com.incluyelab.model.Usuario;
import com.incluyelab.security.ConadisValidator;
import com.incluyelab.security.Passwords;
import com.incluyelab.security.Roles;
import com.incluyelab.service.AlmacenCarnetConadis;
import java.io.*;
import java.nio.file.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "RegistroServlet", urlPatterns = {"/registro"})
@MultipartConfig(maxFileSize = 6 * 1024 * 1024, maxRequestSize = 8 * 1024 * 1024)
public class RegistroServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/registro.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String rol = request.getParameter("rol");
        String nombre = request.getParameter("nombre");
        String correo = request.getParameter("correo");
        String clave = request.getParameter("contrasena");
        String confirmacion = request.getParameter("confirmarContrasena");
        if (clave == null || !clave.equals(confirmacion)) {
            request.setAttribute("error", "Las contraseñas no coinciden. Escríbelas nuevamente.");
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }


        if (!Roles.esRegistroPublico(rol) || nombre == null || nombre.trim().isEmpty()
                || nombre.length() > 120 || correo == null || !correo.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")
                || correo.length() > 150 || Passwords.policyError(clave) != null) {
            request.setAttribute("error", Passwords.policyError(clave) != null ? Passwords.policyError(clave) : "Revisa los campos e ingresa un correo válido.");
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }

        Path archivoGuardado = null;
        String nombreArchivoFinal = null;
        String rui = null;
        if ("POSTULANTE".equals(rol)) {
            try {
                rui = ConadisValidator.rui(request.getParameter("rui"));
                nombreArchivoFinal = AlmacenCarnetConadis.guardar(request.getPart("carnetFoto"));
                archivoGuardado = AlmacenCarnetConadis.resolver(nombreArchivoFinal);
            } catch (IllegalArgumentException ex) {
                AlmacenCarnetConadis.eliminarSiExiste(nombreArchivoFinal);
                request.setAttribute("error", ex.getMessage());
                request.getRequestDispatcher("/registro.jsp").forward(request, response);
                return;
            } catch (IOException ex) {
                AlmacenCarnetConadis.eliminarSiExiste(nombreArchivoFinal);
                log("No se pudo almacenar la imagen CONADIS",ex);
                request.setAttribute("error","No se pudo procesar la fotografía. Intenta con otra imagen JPG o PNG.");
                request.getRequestDispatcher("/registro.jsp").forward(request,response);
                return;
            }
        }

        Usuario usuario = new Usuario();
        usuario.setNombre(nombre);
        usuario.setCorreo(correo);
        usuario.setContrasena(clave);
        usuario.setRol(rol);

        try {
            int nuevoId = new UsuarioDAO().registrar(usuario,rui,nombreArchivoFinal);
            archivoGuardado=null; // La imagen ya pertenece a una cuenta confirmada en la base.
            usuario=new UsuarioDAO().obtenerActivo(nuevoId);
            if(usuario==null)throw new IllegalArgumentException("Cuenta no disponible.");
            new com.incluyelab.dao.OtpDAO().generarOtp(nuevoId,usuario.getCorreo(),"VERIFICACION_CORREO");
            // Iniciar sesión y enviar directo a la verificación de correo
            HttpSession anterior=request.getSession(false);if(anterior!=null)anterior.invalidate();
            HttpSession session = request.getSession(true);
            session.setAttribute("usuario", usuario);
            session.setMaxInactiveInterval(30 * 60);

            response.sendRedirect("verificar-correo?registro=ok");
        } catch (Exception ex) {
            AlmacenCarnetConadis.eliminarSiExiste(nombreArchivoFinal);
            log("No se pudo registrar la cuenta", ex);
            request.setAttribute("error", ex instanceof java.sql.SQLIntegrityConstraintViolationException
                    ? "Ese correo ya tiene una cuenta. Ingresa o utiliza otro correo."
                    : (ex instanceof IllegalArgumentException ? ex.getMessage() : "No se pudo crear la cuenta. Intenta nuevamente en unos minutos."));
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
        }
    }
}
