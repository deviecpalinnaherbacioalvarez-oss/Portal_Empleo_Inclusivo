package com.incluyelab.servlet;

import com.incluyelab.dao.ConversacionDAO;
import com.incluyelab.model.Postulacion;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/conversacion")
public class ConversacionServlet extends HttpServlet {
    private final ConversacionDAO dao=new ConversacionDAO();

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException {
        Usuario actor=actor(req,res); if(actor==null)return;
        try {
            int id=id(req);
            Postulacion postulacion=dao.obtenerPostulacion(id,actor);
            if(postulacion==null){res.sendError(404,"La conversación no existe o no pertenece a tu cuenta.");return;}
            HttpSession sesion=req.getSession();
            if(sesion.getAttribute("conversacionCsrf")==null)sesion.setAttribute("conversacionCsrf",UUID.randomUUID().toString());
            req.setAttribute("postulacion",postulacion);
            req.setAttribute("mensajes",dao.listar(id,actor));
            req.getRequestDispatcher("/WEB-INF/conversacion.jsp").forward(req,res);
        } catch(NumberFormatException ex){res.sendError(400,"Postulación no válida.");}
        catch(SQLException ex){log("No se pudo cargar la conversación",ex);res.sendError(503,"No se pudo cargar la conversación. Intenta nuevamente.");}
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException {
        Usuario actor=actor(req,res); if(actor==null)return;
        Object token=req.getSession().getAttribute("conversacionCsrf");
        if(token==null||!token.equals(req.getParameter("csrf"))){res.sendError(403,"Formulario vencido. Vuelve a abrir la conversación.");return;}
        try {
            int id=id(req); dao.enviar(id,actor,req.getParameter("mensaje"));
            res.sendRedirect(req.getContextPath()+"/conversacion?id="+id+"#ultimo-mensaje");
        } catch(IllegalArgumentException ex){req.getSession().setAttribute("conversacionError",ex.getMessage());res.sendRedirect(req.getContextPath()+"/conversacion?id="+req.getParameter("id"));}
        catch(SecurityException ex){res.sendError(404,"La conversación no existe o no pertenece a tu cuenta.");}
        catch(SQLException ex){log("No se pudo enviar el mensaje",ex);res.sendError(503,"No se pudo enviar el mensaje. Intenta nuevamente.");}
    }

    private Usuario actor(HttpServletRequest req,HttpServletResponse res)throws IOException {
        HttpSession sesion=req.getSession(false); Usuario u=sesion==null?null:(Usuario)sesion.getAttribute("usuario");
        if(u==null){res.sendRedirect(req.getContextPath()+"/login?sesion=requerida");return null;}
        if(!"POSTULANTE".equals(u.getRol())&&!"EMPRESA".equals(u.getRol())){res.sendError(403,"Esta función es exclusiva para postulantes y empresas.");return null;}
        return u;
    }
    private int id(HttpServletRequest req){int id=Integer.parseInt(req.getParameter("id"));if(id<1)throw new NumberFormatException();return id;}
}
