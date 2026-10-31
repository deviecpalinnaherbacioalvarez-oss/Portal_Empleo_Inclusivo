package com.incluyelab.servlet;

import com.incluyelab.dao.*;
import com.incluyelab.model.*;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet({"/empresa/candidato","/recursos-humanos/candidato"})
public class CandidatoServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException{
        Usuario u=(Usuario)req.getSession().getAttribute("usuario");
        if(u==null){res.sendError(403);return;}
        boolean rutaRrhh="/recursos-humanos/candidato".equals(req.getServletPath());
        boolean rrhh=rutaRrhh&&"RECURSOS_HUMANOS".equals(u.getRol());
        boolean empresa=!rutaRrhh&&"EMPRESA".equals(u.getRol());
        if(!rrhh&&!empresa){res.sendError(403);return;}
        try{int id=Integer.parseInt(req.getParameter("id"));Postulacion p=rrhh?new PostulacionDAO().obtenerPorId(id):new PostulacionDAO().obtenerParaEmpresa(id,u.getIdUsuario());if(p==null){res.sendError(404);return;}req.setAttribute("vistaRrhh",rrhh);req.setAttribute("postulacion",p);req.setAttribute("perfilProfesional",new PerfilPostulanteDAO().obtener(p.getIdUsuario()));if(!rrhh)req.setAttribute("evaluacionesRrhh",new RecursosHumanosDAO().evaluacionesPublicadasPostulacion(id,u.getIdUsuario()));req.getRequestDispatcher("/WEB-INF/candidato.jsp").forward(req,res);}
        catch(NumberFormatException ex){res.sendError(404);}catch(java.sql.SQLException ex){log("No se pudo abrir candidato",ex);res.sendError(503);}
    }
}
