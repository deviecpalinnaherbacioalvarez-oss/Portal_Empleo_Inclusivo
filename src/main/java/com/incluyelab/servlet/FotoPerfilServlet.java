package com.incluyelab.servlet;

import com.incluyelab.config.Conexion;
import com.incluyelab.model.Usuario;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/foto-perfil")
public class FotoPerfilServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req,HttpServletResponse res)throws IOException{
        Usuario actor=(Usuario)req.getSession().getAttribute("usuario");int postulante;
        try{postulante=Integer.parseInt(req.getParameter("usuario"));}catch(Exception ex){res.sendError(404);return;}
        if(actor==null||(!"POSTULANTE".equals(actor.getRol())&&!"EMPRESA".equals(actor.getRol())&&!"RECURSOS_HUMANOS".equals(actor.getRol()))){res.sendError(403);return;}
        try(Connection cn=Conexion.getConnection()){
            if("POSTULANTE".equals(actor.getRol())&&actor.getIdUsuario()!=postulante){res.sendError(403);return;}
            if("EMPRESA".equals(actor.getRol())){try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa WHERE p.id_usuario=? AND e.id_usuario=?")){ps.setInt(1,postulante);ps.setInt(2,actor.getIdUsuario());try(ResultSet rs=ps.executeQuery()){if(!rs.next()){res.sendError(403);return;}}}}
            if("RECURSOS_HUMANOS".equals(actor.getRol())){try(PreparedStatement ps=cn.prepareStatement("SELECT 1 FROM postulaciones WHERE id_usuario=?")){ps.setInt(1,postulante);try(ResultSet rs=ps.executeQuery()){if(!rs.next()){res.sendError(403);return;}}}}
            String archivo=null;try(PreparedStatement ps=cn.prepareStatement("SELECT foto_url FROM perfiles_postulantes WHERE id_usuario=?")){ps.setInt(1,postulante);try(ResultSet rs=ps.executeQuery()){if(rs.next())archivo=rs.getString(1);}}
            if(archivo==null||archivo.isEmpty()||archivo.startsWith("asset:")){res.sendError(404);return;}
            Path dir=Paths.get(System.getProperty("user.home"),"IncluyeLab","fotos"),file=dir.resolve(archivo).normalize();if(!file.startsWith(dir)||!Files.exists(file)){res.sendError(404);return;}
            res.setContentType("image/jpeg");res.setHeader("Cache-Control","private, max-age=300");res.setContentLengthLong(Files.size(file));Files.copy(file,res.getOutputStream());
        }catch(SQLException ex){log("No se pudo abrir la foto de perfil",ex);res.sendError(503);}
    }
}
