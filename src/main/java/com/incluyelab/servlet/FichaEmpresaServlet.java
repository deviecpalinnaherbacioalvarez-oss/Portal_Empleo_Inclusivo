package com.incluyelab.servlet;

import com.incluyelab.dao.EmpresaDAO;
import com.incluyelab.model.*;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/empresa/perfil")
public class FichaEmpresaServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        Usuario u=(Usuario)req.getSession().getAttribute("usuario");
        if(u==null||!"EMPRESA".equals(u.getRol())){res.sendError(403,"Acceso exclusivo para empresas.");return;}
        try {
            if(req.getSession().getAttribute("empresaCsrf")==null) req.getSession().setAttribute("empresaCsrf",java.util.UUID.randomUUID().toString());
            if(req.getAttribute("ficha")==null) req.setAttribute("ficha",new EmpresaDAO().obtenerPorUsuario(u.getIdUsuario()));
            if(req.getAttribute("ficha")==null){res.sendError(404);return;}
            req.getRequestDispatcher("/WEB-INF/empresa-ficha.jsp").forward(req,res);
        }catch(java.sql.SQLException ex){log("Error al cargar ficha",ex);res.sendError(503,"No se pudo cargar la ficha.");}
    }
    protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        Object token=req.getSession().getAttribute("empresaCsrf");
        if(token==null || !token.equals(req.getParameter("csrf"))){res.sendError(403);return;}
        Usuario u=(Usuario)req.getSession().getAttribute("usuario");
        if(u==null||!"EMPRESA".equals(u.getRol())){res.sendError(403,"Acceso exclusivo para empresas.");return;}
        Empresa e=new Empresa();
        e.setRazonSocial(value(req,"razonSocial"));e.setRuc(value(req,"ruc"));e.setSector(value(req,"sector"));
        e.setPresentacion(value(req,"presentacion"));e.setLogros(value(req,"logros"));
        try {
            e.setAnioInicio(Integer.valueOf(value(req,"anioInicio")));
            e.setVersionRevision(Integer.parseInt(value(req,"version")));
            new EmpresaDAO().guardarFicha(u.getIdUsuario(),e);
            res.sendRedirect(req.getContextPath()+"/empresa?ok=ficha");
        }catch(IllegalArgumentException ex){
            req.setAttribute("error",ex instanceof NumberFormatException?"Revisa el ano de inicio y recarga la ficha.":ex.getMessage());
            req.setAttribute("ficha",e);res.setStatus(400);doGet(req,res);
        }catch(java.sql.SQLException ex){log("Error al guardar ficha",ex);res.sendError(503,"No se pudo guardar la ficha.");}
    }
    private String value(HttpServletRequest req,String key){String v=req.getParameter(key);return v==null?"":v.trim();}
}
