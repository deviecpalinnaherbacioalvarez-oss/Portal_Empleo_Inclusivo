package com.incluyelab.servlet;

import com.incluyelab.dao.NotificacionDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/notificacion")
public class NotificacionServlet extends HttpServlet {
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException {
        HttpSession sesion=req.getSession(false);Usuario usuario=sesion==null?null:(Usuario)sesion.getAttribute("usuario");
        if(usuario==null){res.sendError(403);return;}
        Object token=sesion.getAttribute("notifCsrf");if(token==null||!token.equals(req.getParameter("csrf"))){res.sendError(403);return;}
        try{int id="todas".equals(req.getParameter("accion"))?0:Integer.parseInt(req.getParameter("id"));if(id<0)throw new NumberFormatException();new NotificacionDAO().marcarLeida(usuario.getIdUsuario(),id);res.sendRedirect(req.getContextPath()+panel(usuario)+"#notificaciones");}
        catch(Exception ex){res.sendError(400,"Notificación no válida.");}
    }
    private String panel(Usuario u){return "SOPORTE_TECNICO".equals(u.getRol())?"/soporte-tecnico":"/postulante";}
}
