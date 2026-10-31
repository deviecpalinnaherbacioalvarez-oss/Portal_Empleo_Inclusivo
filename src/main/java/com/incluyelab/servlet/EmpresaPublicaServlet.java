package com.incluyelab.servlet;

import com.incluyelab.dao.EmpresaDAO;
import com.incluyelab.dao.OfertaDAO;
import com.incluyelab.model.Empresa;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/empresa-publica")
public class EmpresaPublicaServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        try{
            String parametro = req.getParameter("id");
            if (parametro == null || !parametro.matches("[0-9]{1,9}")) { res.sendError(404); return; }
            int id = Integer.parseInt(parametro);
            Empresa e = new EmpresaDAO().obtenerPublica(id);
            if(e==null){res.sendError(404,"Empresa no disponible.");return;}
            req.setAttribute("ficha",e);
            req.setAttribute("ofertasEmpresa",new OfertaDAO().listarPublicasPorEmpresa(id));
            req.getRequestDispatcher("/WEB-INF/empresa-publica.jsp").forward(req,res);
        }catch(NumberFormatException ex){res.sendError(404);}
        catch(java.sql.SQLException ex){log("Error al consultar empresa",ex);res.sendError(503);}
    }
}
