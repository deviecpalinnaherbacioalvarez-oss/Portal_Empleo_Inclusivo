package com.incluyelab.servlet;

import com.incluyelab.dao.PerfilPostulanteDAO;
import com.incluyelab.model.Usuario;
import java.io.*;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.nio.file.*;
import java.sql.SQLException;
import javax.imageio.ImageIO;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

@WebServlet("/perfil-profesional")
@MultipartConfig(maxFileSize=5*1024*1024, maxRequestSize=6*1024*1024)
public class PerfilPostulanteServlet extends HttpServlet {
    private final PerfilPostulanteDAO dao=new PerfilPostulanteDAO();
    protected void doGet(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException{
        Usuario u=usuario(req); if(u==null){res.sendError(403);return;}
        if(req.getSession().getAttribute("perfilCsrf")==null)req.getSession().setAttribute("perfilCsrf",java.util.UUID.randomUUID().toString());
        try{req.setAttribute("perfilProfesional",dao.obtener(u.getIdUsuario()));req.getRequestDispatcher("/WEB-INF/perfil-postulante.jsp").forward(req,res);}
        catch(SQLException ex){log("No se pudo cargar el perfil profesional",ex);res.sendError(503,"No se pudo cargar el perfil.");}
    }
    protected void doPost(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException{
        req.setCharacterEncoding("UTF-8");Usuario u=usuario(req);if(u==null){res.sendError(403);return;}
        Object token=req.getSession().getAttribute("perfilCsrf");if(token==null||!token.equals(req.getParameter("csrf"))){res.sendError(403);return;}
        String accion=v(req,"accion");
        try{
            switch(accion){
                case"resumen": dao.guardarResumen(u.getIdUsuario(),v(req,"nombre"),v(req,"telefono"),v(req,"titular"),v(req,"ubicacion"),v(req,"acercaDe"),v(req,"habilidades"),v(req,"adaptacion"));u.setNombre(v(req,"nombre"));req.getSession().setAttribute("usuario",u);break;
                case"experiencia":dao.agregarExperiencia(u.getIdUsuario(),v(req,"cargo"),v(req,"organizacion"),v(req,"inicio"),v(req,"fin"),v(req,"descripcion"));break;
                case"educacion":dao.agregarEducacion(u.getIdUsuario(),v(req,"institucion"),v(req,"carrera"),v(req,"inicio"),v(req,"fin"),v(req,"descripcion"));break;
                case"certificacion":dao.agregarCertificacion(u.getIdUsuario(),v(req,"nombreCert"),v(req,"emisor"),v(req,"fecha"),v(req,"url"));break;
                case"editarExperiencia":dao.actualizarExperiencia(u.getIdUsuario(),id(req),v(req,"cargo"),v(req,"organizacion"),v(req,"inicio"),v(req,"fin"),v(req,"descripcion"));break;
                case"editarEducacion":dao.actualizarEducacion(u.getIdUsuario(),id(req),v(req,"institucion"),v(req,"carrera"),v(req,"inicio"),v(req,"fin"),v(req,"descripcion"));break;
                case"editarCertificacion":dao.actualizarCertificacion(u.getIdUsuario(),id(req),v(req,"nombreCert"),v(req,"emisor"),v(req,"fecha"),v(req,"url"));break;
                case"eliminar":dao.eliminar(u.getIdUsuario(),v(req,"tipo"),Integer.parseInt(v(req,"id")));break;
                case"cv":guardarCv(req,u);break;
                case"foto":guardarFoto(req,u);break;
                default:throw new IllegalArgumentException("Accion no valida.");
            }
            req.getSession().setAttribute("profileNotice","Perfil actualizado correctamente.");
            res.sendRedirect(req.getContextPath()+"/perfil-profesional");
        }catch(IllegalArgumentException ex){req.setAttribute("error",ex.getMessage());res.setStatus(400);doGet(req,res);}
        catch(SQLException ex){log("No se pudo actualizar el perfil",ex);req.setAttribute("error","No se pudo guardar el cambio.");res.setStatus(503);doGet(req,res);}
    }
    private void guardarCv(HttpServletRequest req,Usuario u)throws IOException,ServletException,SQLException{
        Part part=req.getPart("cv");if(part==null||part.getSize()==0)throw new IllegalArgumentException("Selecciona un archivo PDF.");
        if(part.getSize()>5*1024*1024||!"application/pdf".equalsIgnoreCase(part.getContentType()))throw new IllegalArgumentException("El CV debe ser un PDF de hasta 5 MB.");
        String supplied=Paths.get(part.getSubmittedFileName()).getFileName().toString();if(!supplied.toLowerCase().endsWith(".pdf"))throw new IllegalArgumentException("El CV debe tener extension PDF.");
        String file="cv-"+u.getIdUsuario()+"-"+System.currentTimeMillis()+".pdf";
        Path dir=Paths.get(System.getProperty("user.home"),"IncluyeLab","cv");Files.createDirectories(dir);
        Path target=dir.resolve(file).normalize();if(!target.startsWith(dir))throw new IllegalArgumentException("Nombre de archivo no valido.");
        try(InputStream in=part.getInputStream()){
            byte[] signature=new byte[5];
            if(in.read(signature)!=5||signature[0]!='%'||signature[1]!='P'||signature[2]!='D'||signature[3]!='F'||signature[4]!='-')throw new IllegalArgumentException("El archivo seleccionado no es un PDF valido.");
            try(OutputStream out=Files.newOutputStream(target,StandardOpenOption.CREATE_NEW)){
                out.write(signature);byte[] buffer=new byte[8192];int read;while((read=in.read(buffer))!=-1)out.write(buffer,0,read);
            }
        }
        try{dao.guardarCv(u.getIdUsuario(),supplied,file);}catch(SQLException ex){Files.deleteIfExists(target);throw ex;}
    }
    private void guardarFoto(HttpServletRequest req,Usuario u)throws IOException,ServletException,SQLException{
        Part part=req.getPart("foto");if(part==null||part.getSize()==0)throw new IllegalArgumentException("Selecciona una imagen.");
        if(part.getSize()>5*1024*1024||!("image/jpeg".equalsIgnoreCase(part.getContentType())||"image/png".equalsIgnoreCase(part.getContentType())))throw new IllegalArgumentException("La foto debe ser JPG o PNG y pesar hasta 5 MB.");
        BufferedImage source;try(InputStream in=part.getInputStream()){source=ImageIO.read(in);}
        if(source==null||source.getWidth()<160||source.getHeight()<160||source.getWidth()>5000||source.getHeight()>5000)throw new IllegalArgumentException("La imagen debe medir entre 160 y 5000 pixeles por lado.");
        BufferedImage clean=new BufferedImage(source.getWidth(),source.getHeight(),BufferedImage.TYPE_INT_RGB);Graphics2D g=clean.createGraphics();g.setColor(Color.WHITE);g.fillRect(0,0,clean.getWidth(),clean.getHeight());g.drawImage(source,0,0,null);g.dispose();
        String file="perfil-"+u.getIdUsuario()+"-"+System.currentTimeMillis()+".jpg";Path dir=Paths.get(System.getProperty("user.home"),"IncluyeLab","fotos");Files.createDirectories(dir);Path target=dir.resolve(file).normalize();if(!target.startsWith(dir))throw new IllegalArgumentException("Nombre de imagen no valido.");
        if(!ImageIO.write(clean,"jpg",target.toFile()))throw new IOException("No se pudo procesar la imagen.");
        String anterior=dao.obtener(u.getIdUsuario()).getFotoUrl();try{dao.guardarFoto(u.getIdUsuario(),file);}catch(SQLException ex){Files.deleteIfExists(target);throw ex;}
        if(anterior!=null&&!anterior.isEmpty()&&!anterior.startsWith("asset:")){Path old=dir.resolve(anterior).normalize();if(old.startsWith(dir))Files.deleteIfExists(old);}
    }
    private Usuario usuario(HttpServletRequest req){Object x=req.getSession().getAttribute("usuario");return x instanceof Usuario&&"POSTULANTE".equals(((Usuario)x).getRol())?(Usuario)x:null;}
    private String v(HttpServletRequest req,String k){String x=req.getParameter(k);return x==null?"":x.trim();}
    private int id(HttpServletRequest req){try{int id=Integer.parseInt(v(req,"id"));if(id>0)return id;}catch(NumberFormatException ex){}throw new IllegalArgumentException("Selecciona un elemento válido.");}
}
