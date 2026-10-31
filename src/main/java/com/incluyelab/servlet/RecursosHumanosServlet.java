package com.incluyelab.servlet;

import com.incluyelab.dao.RecursosHumanosDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/recursos-humanos")
public class RecursosHumanosServlet extends HttpServlet {
    private final RecursosHumanosDAO dao=new RecursosHumanosDAO();
    protected void doGet(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException{
        Usuario u=usuario(req);if(u==null||!"RECURSOS_HUMANOS".equals(u.getRol())){res.sendError(403);return;}if(req.getSession().getAttribute("rrhhCsrf")==null)req.getSession().setAttribute("rrhhCsrf",UUID.randomUUID().toString());
        try{com.incluyelab.dao.VerificacionConadisDAO conadis=new com.incluyelab.dao.VerificacionConadisDAO();req.setAttribute("verificacionesConadis",conadis.listar(req.getParameter("estadoConadis"),req.getParameter("buscarConadis")));req.setAttribute("candidatos",dao.candidatos());req.setAttribute("evaluaciones",dao.evaluaciones(u.getIdUsuario()));req.getRequestDispatcher("/WEB-INF/recursos-humanos.jsp").forward(req,res);}catch(IllegalArgumentException ex){req.setAttribute("error",ex.getMessage());res.setStatus(400);req.setAttribute("verificacionesConadis",java.util.Collections.emptyList());try{req.setAttribute("candidatos",dao.candidatos());req.setAttribute("evaluaciones",dao.evaluaciones(u.getIdUsuario()));req.getRequestDispatcher("/WEB-INF/recursos-humanos.jsp").forward(req,res);}catch(SQLException sql){log("No se pudo cargar Recursos Humanos",sql);res.sendError(503);}}catch(SQLException ex){log("No se pudo cargar Recursos Humanos",ex);res.sendError(503);}
    }
    protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException,ServletException{
        Usuario u=usuario(req);Object token=req.getSession().getAttribute("rrhhCsrf");if(u==null||!"RECURSOS_HUMANOS".equals(u.getRol())||token==null||!token.equals(req.getParameter("csrf"))){res.sendError(403);return;}
        try{String accion=req.getParameter("accion");if("eliminar".equals(accion))dao.eliminar(u.getIdUsuario(),numero(req,"id"));else dao.guardar(u.getIdUsuario(),numeroOpcional(req,"id"),numero(req,"postulacion"),req.getParameter("observaciones"),valor(req,"retroalimentacion"),req.getParameter("resultado"),req.getParameter("estado"),req.getParameter("etapa"),porcentaje(req,"puntajeCv"),porcentaje(req,"puntajeEntrevista"),porcentaje(req,"puntajeDesempeno"),porcentaje(req,"compatibilidad"));res.sendRedirect(req.getContextPath()+"/recursos-humanos?ok=1");}catch(IllegalArgumentException ex){req.setAttribute("error",ex.getMessage());res.setStatus(400);doGet(req,res);}catch(SQLException ex){log("No se pudo guardar la evaluación",ex);res.sendError(503);}
    }
    private Usuario usuario(HttpServletRequest req){HttpSession s=req.getSession(false);return s==null?null:(Usuario)s.getAttribute("usuario");}
    private int numero(HttpServletRequest req,String campo){try{int n=Integer.parseInt(req.getParameter(campo));if(n>0)return n;}catch(Exception ex){}throw new IllegalArgumentException("Selecciona un registro válido.");}
    private int numeroOpcional(HttpServletRequest req,String campo){String v=req.getParameter(campo);return v==null||v.isEmpty()?0:numero(req,campo);}
    private int porcentaje(HttpServletRequest req,String campo){try{return Integer.parseInt(valor(req,campo));}catch(Exception ex){throw new IllegalArgumentException("Completa todos los porcentajes.");}}
    private String valor(HttpServletRequest req,String campo){String v=req.getParameter(campo);return v==null?"":v.trim();}
}
