package com.incluyelab.servlet;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Usuario;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/cv")
public class CvServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req,HttpServletResponse res)throws IOException{
        Usuario actor=(Usuario)req.getSession().getAttribute("usuario");int postulante=0,postulacion=0;
        try{if(req.getParameter("postulacion")!=null)postulacion=Integer.parseInt(req.getParameter("postulacion"));else postulante=Integer.parseInt(req.getParameter("usuario"));}catch(Exception ex){res.sendError(404);return;}
        if(actor==null||(!"POSTULANTE".equals(actor.getRol())&&!"EMPRESA".equals(actor.getRol())&&!"RECURSOS_HUMANOS".equals(actor.getRol()))){res.sendError(403);return;}
        try(Connection cn=Conexion.getConnection()){
            if("RECURSOS_HUMANOS".equals(actor.getRol())){
                if(!new com.incluyelab.dao.RecursosHumanosDAO().puedeConsultarExpediente(actor.getIdUsuario(),postulacion)){res.sendError(403,"Debes registrar una evaluación antes de consultar el expediente privado.");return;}
                try(PreparedStatement ps=cn.prepareStatement("SELECT p.id_usuario FROM postulaciones p WHERE p.id_postulacion=?")){ps.setInt(1,postulacion);try(ResultSet rs=ps.executeQuery()){if(!rs.next()){res.sendError(404);return;}postulante=rs.getInt(1);}}
            }
            if("POSTULANTE".equals(actor.getRol())&&actor.getIdUsuario()!=postulante){res.sendError(403);return;}
            if("EMPRESA".equals(actor.getRol())){try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa WHERE p.id_usuario=? AND e.id_usuario=?")){ps.setInt(1,postulante);ps.setInt(2,actor.getIdUsuario());try(ResultSet rs=ps.executeQuery()){if(!rs.next()){res.sendError(403);return;}}}}
            String archivo=null,nombre=null;try(PreparedStatement ps=cn.prepareStatement("SELECT cv_archivo,cv_nombre FROM perfiles_postulantes WHERE id_usuario=?")){ps.setInt(1,postulante);try(ResultSet rs=ps.executeQuery()){if(rs.next()){archivo=rs.getString(1);nombre=rs.getString(2);}}}
            if(archivo==null||archivo.isEmpty()){res.sendError(404,"El postulante no ha adjuntado un CV.");return;}
            Path dir=Paths.get(System.getProperty("user.home"),"IncluyeLab","cv"),file=dir.resolve(archivo).normalize();if(!file.startsWith(dir)||!Files.exists(file)){res.sendError(404);return;}
            res.setContentType("application/pdf");res.setHeader("Content-Disposition","inline; filename*=UTF-8''"+java.net.URLEncoder.encode(nombre,"UTF-8").replace("+","%20"));res.setContentLengthLong(Files.size(file));Files.copy(file,res.getOutputStream());
        }catch(SQLException ex){log("No se pudo abrir el CV",ex);res.sendError(503);}
    }
}
