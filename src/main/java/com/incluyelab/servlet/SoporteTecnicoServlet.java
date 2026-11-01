package com.incluyelab.servlet;

import com.incluyelab.dao.IncidenciaDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet({"/soporte","/soporte-tecnico"})
public class SoporteTecnicoServlet extends HttpServlet {
    private final IncidenciaDAO dao=new IncidenciaDAO();
    protected void doGet(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException{
        if(req.getSession().getAttribute("soporteCsrf")==null)req.getSession().setAttribute("soporteCsrf",UUID.randomUUID().toString());
        if("/soporte".equals(req.getServletPath())){req.getRequestDispatcher("/WEB-INF/soporte.jsp").forward(req,res);return;}
        if(req.getSession().getAttribute("notifCsrf")==null)req.getSession().setAttribute("notifCsrf",UUID.randomUUID().toString());
        Usuario u=usuario(req);if(u==null||!"SOPORTE_TECNICO".equals(u.getRol())){res.sendError(403);return;}try{req.setAttribute("incidencias",dao.listar(u.getIdUsuario()));req.setAttribute("notificaciones",new com.incluyelab.dao.NotificacionDAO().listar(u.getIdUsuario()));req.setAttribute("historial",dao.historial(u.getIdUsuario()));String buscar=req.getParameter("buscarUsuario");req.setAttribute("usuariosSoporte",buscar==null||buscar.trim().isEmpty()?java.util.Collections.emptyList():dao.buscarUsuarios(u.getIdUsuario(),buscar));Object temporal=req.getSession().getAttribute("claveTemporal");if(temporal!=null){req.setAttribute("claveTemporal",temporal);req.setAttribute("correoTemporal",req.getSession().getAttribute("correoTemporal"));req.setAttribute("expiraTemporal",req.getSession().getAttribute("expiraTemporal"));req.getSession().removeAttribute("claveTemporal");req.getSession().removeAttribute("correoTemporal");req.getSession().removeAttribute("expiraTemporal");}req.getRequestDispatcher("/WEB-INF/soporte-tecnico.jsp").forward(req,res);}catch(SQLException ex){log("No se pudo cargar soporte",ex);res.sendError(503);}
    }
    protected void doPost(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException{
        Object token=req.getSession().getAttribute("soporteCsrf");if(token==null||!token.equals(req.getParameter("csrf"))){res.sendError(403);return;}Usuario u=usuario(req);
        try{
            if("/soporte".equals(req.getServletPath())){dao.registrarExterna(u==null?null:u.getIdUsuario(),req.getParameter("correo"),req.getParameter("categoria"),req.getParameter("titulo"),req.getParameter("descripcion"));res.sendRedirect(req.getContextPath()+"/soporte?ok=1");return;}
            if(u==null||!"SOPORTE_TECNICO".equals(u.getRol())){res.sendError(403);return;}
            String accion=req.getParameter("accion");if(accion==null||accion.isEmpty())accion="actualizar";int id="crear".equals(accion)?0:numero(req,"id");
            if("crear".equals(accion))dao.crearInterna(u.getIdUsuario(),req.getParameter("categoria"),req.getParameter("titulo"),req.getParameter("descripcion"),req.getParameter("prioridad"));
            else if("actualizar".equals(accion))dao.actualizar(u.getIdUsuario(),id,req.getParameter("titulo"),req.getParameter("descripcion"),req.getParameter("categoria"),req.getParameter("prioridad"),req.getParameter("decision"),req.getParameter("estado"),req.getParameter("solucion"));
            else if("eliminar".equals(accion))dao.eliminar(u.getIdUsuario(),id);
            else if("verificar".equals(accion))dao.verificarIdentidad(u.getIdUsuario(),id,numero(req,"idUsuario"),req.getParameter("metodoVerificacion"),req.getParameter("motivoAccion"),req.getParameter("correoConfirmado"),"1".equals(req.getParameter("identidadConfirmada")));
            else if("desbloquear".equals(accion))dao.desbloquearCuenta(u.getIdUsuario(),id);
            else if("notificar".equals(accion))dao.enviarNotificacion(u.getIdUsuario(),id,req.getParameter("mensaje"));
            else if("restablecer".equals(accion)){String temporal=temporal();String correo=dao.restablecerClave(u.getIdUsuario(),id,temporal);req.getSession().setAttribute("claveTemporal",temporal);req.getSession().setAttribute("correoTemporal",correo);req.getSession().setAttribute("expiraTemporal","30 minutos");}
            else throw new IllegalArgumentException("Acción de soporte no permitida.");
            res.sendRedirect(req.getContextPath()+"/soporte-tecnico?ok=1");
        }catch(IllegalArgumentException ex){req.setAttribute("error",ex.getMessage());res.setStatus(400);doGet(req,res);}catch(SQLException ex){log("No se pudo guardar la incidencia",ex);res.sendError(503);}
    }
    private Usuario usuario(HttpServletRequest req){HttpSession s=req.getSession(false);return s==null?null:(Usuario)s.getAttribute("usuario");}
    private int numero(HttpServletRequest req,String campo){try{int n=Integer.parseInt(req.getParameter(campo));if(n>0)return n;}catch(Exception ex){}throw new IllegalArgumentException("Selecciona una incidencia válida.");}
    private String temporal(){return com.incluyelab.security.Passwords.temporary();}
}
