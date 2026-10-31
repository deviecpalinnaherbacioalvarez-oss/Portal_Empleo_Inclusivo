package com.incluyelab.servlet;

import com.incluyelab.dao.EmpresaDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/revision-empresa")
public class RevisionEmpresaServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        Usuario actor=(Usuario)req.getSession().getAttribute("usuario");
        if(actor==null||!"ADMIN".equals(actor.getRol())){res.sendError(403,"Acceso exclusivo para el Administrador Central.");return;}
        try{
            if(req.getSession().getAttribute("revisionCsrf")==null)req.getSession().setAttribute("revisionCsrf",java.util.UUID.randomUUID().toString());
            req.setAttribute("ficha",new EmpresaDAO().obtener(Integer.parseInt(req.getParameter("id"))));
            if(req.getAttribute("ficha")==null){res.sendError(404);return;}
            req.getRequestDispatcher("/WEB-INF/empresa-revision.jsp").forward(req,res);
        }catch(NumberFormatException ex){res.sendError(404);}
        catch(java.sql.SQLException ex){log("Error al revisar empresa",ex);res.sendError(503);}
    }
    protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        Usuario actor=(Usuario)req.getSession().getAttribute("usuario");
        if(actor==null||!"ADMIN".equals(actor.getRol())){res.sendError(403,"Acceso exclusivo para el Administrador Central.");return;}
        Object token=req.getSession().getAttribute("revisionCsrf");
        if(token==null || !token.equals(req.getParameter("csrf"))){res.sendError(403);return;}
        try{
            new EmpresaDAO().revisar(Integer.parseInt(req.getParameter("id")),Integer.parseInt(req.getParameter("version")),
                actor.getIdUsuario(),req.getParameter("decision"),req.getParameter("motivo"));
            req.getSession().setAttribute("adminNotice","Decision guardada. La empresa puede consultar el resultado en su panel.");
            res.sendRedirect(req.getContextPath()+"/admin#empresas");
        }catch(IllegalArgumentException ex){
            req.setAttribute("error",ex instanceof NumberFormatException?"Solicitud no valida.":ex.getMessage());
            res.setStatus(400);doGet(req,res);
        }catch(java.sql.SQLException ex){log("Error al revisar empresa",ex);res.sendError(503);}
    }
}
