package com.incluyelab.servlet;

import com.incluyelab.dao.PostulacionDAO;
import com.incluyelab.model.Usuario;
import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/empresa/postulacion")
public class SeguimientoPostulacionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException{
        Usuario u=(Usuario)req.getSession().getAttribute("usuario");Object token=req.getSession().getAttribute("empresaCsrf");
        if(u==null||!"EMPRESA".equals(u.getRol())||token==null||!token.equals(req.getParameter("csrf"))){res.sendError(403);return;}
        try{int id=Integer.parseInt(req.getParameter("id"));if("eliminar".equals(req.getParameter("accion"))){new PostulacionDAO().eliminarPorEmpresa(id,u.getIdUsuario());req.getSession().setAttribute("empresaNotice","La postulación fue eliminada.");}else{new PostulacionDAO().cambiarEstadoEmpresa(id,u.getIdUsuario(),req.getParameter("estado"));req.getSession().setAttribute("empresaNotice","Estado de la postulación actualizado.");}res.sendRedirect(req.getContextPath()+"/empresa#candidatos");}
        catch(IllegalArgumentException|java.sql.SQLException ex){log("No se pudo actualizar la postulacion",ex);req.getSession().setAttribute("empresaError",ex instanceof IllegalArgumentException?ex.getMessage():"No se pudo guardar el cambio.");res.sendRedirect(req.getContextPath()+"/empresa#candidatos");}
    }
}
