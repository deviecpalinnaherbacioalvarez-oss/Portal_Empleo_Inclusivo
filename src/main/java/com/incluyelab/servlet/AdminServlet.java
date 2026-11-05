package com.incluyelab.servlet;

import com.incluyelab.dao.*;
import com.incluyelab.model.*;
import com.incluyelab.security.Roles;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {
    private final AdminDAO dao = new AdminDAO();
    private static final Set<String> ENTIDADES = Collections.singleton("usuarios");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if (!autorizar(req,res)) return;
        if (req.getSession().getAttribute("adminCsrf") == null)
            req.getSession().setAttribute("adminCsrf",UUID.randomUUID().toString());
        String accion = valor(req,"accion");
        if (accion.isEmpty()) {
            try { cargar(req); } catch (SQLException ex) { log("Error al consultar el panel",ex); req.setAttribute("error","No se pudo cargar el panel."); }
            req.getRequestDispatcher("/admin.jsp").forward(req,res);
            return;
        }
        try {
            String entidad = entidad(req);
            if (!Arrays.asList("nuevo","editar").contains(accion)) throw new IllegalArgumentException("Accion no valida.");
            int id = "nuevo".equals(accion) ? 0 : positivo(valor(req,"id"));
            cargar(req);
            Map<String,String> valores = registro(req,entidad,id);
            if ("usuarios".equals(entidad) && "EMPRESA".equals(valores.get("rol"))) {
                res.sendError(403,"Las cuentas empresariales son administradas por sus representantes.");
                return;
            }
            preparar(req,entidad,id,valores);
            req.getRequestDispatcher("/WEB-INF/admin-form.jsp").forward(req,res);
        } catch (SecurityException ex) { res.sendError(403,ex.getMessage()); }
          catch (IllegalArgumentException ex) { res.sendError(404,"Registro o accion no disponible."); }
          catch (SQLException ex) { log("Error al abrir formulario",ex); res.sendError(503,"No se pudo consultar la base de datos."); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!autorizar(req,res)) return;
        Object token = req.getSession().getAttribute("adminCsrf");
        if (token == null || !token.equals(req.getParameter("csrf"))) { res.sendError(403,"Formulario vencido. Vuelve al panel."); return; }
        String entidad, accion = valor(req,"accion");
        int id;
        try {
            entidad = entidad(req);
            id = Integer.parseInt(valor(req,"id"));
            if (id < 0 || (!"guardar".equals(accion) && !"dar_baja".equals(accion) && !"eliminar".equals(accion)))
                throw new IllegalArgumentException();
        } catch (SecurityException ex) { res.sendError(403,ex.getMessage()); return; }
          catch (IllegalArgumentException ex) { res.sendError(400,"Solicitud no valida."); return; }
        Usuario actor = (Usuario)req.getSession().getAttribute("usuario");
        if ("dar_baja".equals(accion)) {
            try { dao.darBaja(id,actor.getIdUsuario());req.getSession().setAttribute("adminNotice","Cuenta desactivada. El historial se conserva.");res.sendRedirect(req.getContextPath()+"/admin#usuarios"); }
            catch (IllegalArgumentException ex) { res.sendError(400,ex.getMessage()); }
            catch (SQLException ex) { manejarErrorSql(req,res,ex,"No se pudo desactivar la cuenta"); }
            return;
        }
        if ("eliminar".equals(accion)) {
            try { dao.eliminar(entidad,id,actor.getIdUsuario());req.getSession().setAttribute("adminNotice","Cuenta eliminada definitivamente.");res.sendRedirect(req.getContextPath()+"/admin#usuarios"); }
            catch (IllegalArgumentException ex) { req.getSession().setAttribute("adminError",ex.getMessage());res.sendRedirect(req.getContextPath()+"/admin#usuarios"); }
            catch (SQLException ex) { manejarErrorSql(req,res,ex,"No se pudo eliminar la cuenta"); }
            return;
        }
        Map<String,String> valores = new HashMap<>();
        for (String campo : Arrays.asList("nombre","correo","rol","estado","razonSocial","ruc","sector","selloInclusivo","idEmpresa","titulo","modalidad","ubicacion","adaptaciones","descripcion","salario","idUsuario","idOferta"))
            valores.put(campo,valor(req,campo));
        valores.put("contrasena", req.getParameter("contrasena") == null ? "" : req.getParameter("contrasena"));
        valores.put("apoyos", com.incluyelab.model.ApoyosOferta.validar(req.getParameterValues("apoyos")));
        try {
            cargar(req);
            if (id > 0 && "usuarios".equals(entidad) && "EMPRESA".equals(registro(req,"usuarios",id).get("rol"))) {
                res.sendError(403,"Las cuentas empresariales son administradas por sus representantes.");
                return;
            }
            validar(entidad,id,valores);
            dao.guardar(entidad,id,valores,actor.getIdUsuario());
            if ("usuarios".equals(entidad) && id == actor.getIdUsuario()) {
                actor.setNombre(valores.get("nombre")); actor.setCorreo(valores.get("correo"));
            }
            req.getSession().setAttribute("adminNotice","Cambios guardados correctamente.");
            res.sendRedirect(req.getContextPath()+"/admin#" + entidad);
        } catch (IllegalArgumentException | SQLException ex) {
            String mensaje;
            if (ex instanceof SQLException) {
                SQLException sql=(SQLException)ex;
                int codigo = sql.getErrorCode();
                mensaje = SqlBusinessErrors.isBusinessRule(sql) ? SqlBusinessErrors.message(sql,"La operación fue rechazada.")
                    : codigo == 1451 ? "No se puede eliminar: existen registros relacionados. Conserva el historial; desactiva la cuenta o cierra la oferta."
                    : codigo == 1062 ? "Ese correo ya esta registrado. Usa otro correo."
                    : "No se pudo guardar el cambio. Intenta nuevamente.";
                log("Operacion administrativa rechazada",ex);
            } else mensaje = ex.getMessage();
            valores.remove("contrasena");
            req.setAttribute("error",mensaje);
            try {
                cargar(req);
                Map<String,String> guardado = registro(req,entidad,id);
                guardado.putAll(valores);
                preparar(req,entidad,id,guardado);
                req.getRequestDispatcher("/WEB-INF/admin-form.jsp").forward(req,res);
            } catch (IllegalArgumentException missing) { res.sendError(404,"El registro ya no existe."); }
              catch (SQLException unavailable) { log("Error al recargar formulario",unavailable); res.sendError(503); }
        }
    }

    private boolean autorizar(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        Usuario u = session == null ? null : (Usuario)session.getAttribute("usuario");
        try {
            if (u != null && "ADMIN".equals(u.getRol()) && dao.esAdministradorActivo(u.getIdUsuario())) return true;
        } catch (SQLException ex) { log("No se pudo verificar el acceso",ex); res.sendError(503); return false; }
        if (u == null && "GET".equals(req.getMethod())) res.sendRedirect(req.getContextPath()+"/login?sesion=requerida");
        else res.sendError(403,"Acceso exclusivo para el Administrador Central.");
        return false;
    }

    private void manejarErrorSql(HttpServletRequest req,HttpServletResponse res,SQLException ex,String logMessage)throws IOException{
        if(SqlBusinessErrors.isBusinessRule(ex)||ex.getErrorCode()==1451){
            String message=ex.getErrorCode()==1451
                    ?"No se puede eliminar esta cuenta porque conserva información relacionada. Puedes desactivarla sin perder el historial."
                    :SqlBusinessErrors.message(ex,"La operación fue rechazada.");
            req.getSession().setAttribute("adminError",message);
            res.sendRedirect(req.getContextPath()+"/admin#usuarios");
        }else{
            log(logMessage,ex);
            res.sendError(503,"No se pudo conectar con la base de datos.");
        }
    }

    private void cargar(HttpServletRequest req) throws SQLException {
        req.setAttribute("usuarios",new UsuarioDAO().listar());
        req.setAttribute("empresas",new EmpresaDAO().listar());
        req.setAttribute("ofertas",new OfertaDAO().listarTodas());
        req.setAttribute("postulaciones",new PostulacionDAO().listarTodas());
        req.setAttribute("evaluacionesRRHH", new com.incluyelab.dao.RecursosHumanosDAO().listarTodas());
        req.setAttribute("incidenciasSoporte", new com.incluyelab.dao.IncidenciaDAO().listarTodas());
    }
    private void preparar(HttpServletRequest req,String entidad,int id,Map<String,String> valores) {
        req.setAttribute("entidad",entidad); req.setAttribute("registroId",id); req.setAttribute("valores",valores);
    }
    @SuppressWarnings("unchecked")
    private Map<String,String> registro(HttpServletRequest req,String entidad,int id) {
        Map<String,String> v = new HashMap<>();
        if (id == 0) return v;
        for (Object obj : (List<?>)req.getAttribute(entidad)) {
            if (obj instanceof Usuario && ((Usuario)obj).getIdUsuario()==id) {
                Usuario u=(Usuario)obj; v.put("nombre",u.getNombre());v.put("correo",u.getCorreo());v.put("rol",u.getRol());v.put("estado",u.getEstado());v.put("etiqueta",u.getNombre());return v;
            }
            if (obj instanceof Empresa && ((Empresa)obj).getIdEmpresa()==id) {
                Empresa e=(Empresa)obj;v.put("razonSocial",e.getRazonSocial());v.put("ruc",e.getRuc());v.put("sector",e.getSector());v.put("selloInclusivo",e.getSelloInclusivo());v.put("etiqueta",e.getRazonSocial());return v;
            }
            if (obj instanceof Oferta && ((Oferta)obj).getIdOferta()==id) {
                Oferta o=(Oferta)obj;v.put("idEmpresa",String.valueOf(o.getIdEmpresa()));v.put("titulo",o.getTitulo());v.put("modalidad",o.getModalidad());v.put("ubicacion",o.getUbicacion());v.put("adaptaciones",o.getAdaptaciones());v.put("apoyos",o.getApoyos());v.put("descripcion",o.getDescripcion());v.put("salario",o.getSalario().toPlainString());v.put("estado",o.getEstado());v.put("etiqueta",o.getTitulo());return v;
            }
            if (obj instanceof Postulacion && ((Postulacion)obj).getIdPostulacion()==id) {
                Postulacion p=(Postulacion)obj;v.put("idUsuario",String.valueOf(p.getIdUsuario()));v.put("idOferta",String.valueOf(p.getIdOferta()));v.put("estado",p.getEstado());v.put("etiqueta",p.getPostulante()+" / "+p.getOferta());return v;
            }
        }
        throw new IllegalArgumentException("El registro ya no existe.");
    }
    private String entidad(HttpServletRequest req) {
        String e=valor(req,"entidad");
        if ("ofertas".equals(e) || "postulaciones".equals(e) || "empresas".equals(e))
            throw new SecurityException("El Administrador Central solo consulta estos registros; la gestion corresponde a su propietario.");
        if (!ENTIDADES.contains(e)) throw new IllegalArgumentException("Seccion no valida.");
        return e;
    }
    private String valor(HttpServletRequest req,String campo) { String v=req.getParameter(campo);return v==null?"":v.trim(); }
    private int positivo(String s) {
        try { int n=Integer.parseInt(s);if(n>0)return n; } catch(NumberFormatException ex) { }
        throw new IllegalArgumentException("Selecciona un registro valido.");
    }
    private void texto(Map<String,String> v,String campo,String etiqueta,int max) {
        String s=v.get(campo); if(s==null||s.isEmpty()||s.length()>max)throw new IllegalArgumentException(etiqueta+": completa el campo (maximo "+max+" caracteres).");
    }
    private void opcion(Map<String,String> v,String campo,String... opciones) {
        if(!Arrays.asList(opciones).contains(v.get(campo)))throw new IllegalArgumentException("Selecciona una opcion valida para "+campo+".");
    }
    private void credenciales(Map<String,String> v,boolean nueva) {
        texto(v,"correo","Correo",150);
        if(!v.get("correo").matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"))throw new IllegalArgumentException("Ingresa un correo valido.");
        String p=v.get("contrasena");
        if(nueva||!p.isEmpty())com.incluyelab.security.Passwords.requireStrong(p);
    }
    private void validar(String entidad,int id,Map<String,String> v) {
        switch(entidad) {
            case "usuarios":
                texto(v,"nombre","Nombre",120);credenciales(v,id==0);
                if (id == 0 && !Roles.esInterno(v.get("rol")))
                    throw new IllegalArgumentException("El Administrador Central solo crea cuentas internas.");
                opcion(v,"rol",Roles.ADMINISTRADOR_CENTRAL,Roles.POSTULANTE,Roles.RECURSOS_HUMANOS,Roles.SOPORTE_TECNICO);
                opcion(v,"estado","activo","inactivo");break;
            case "empresas":
                texto(v,"razonSocial","Razon social",id==0?120:150);texto(v,"sector","Sector",100);
                if(!v.get("ruc").matches("[0-9]{11}"))throw new IllegalArgumentException("El RUC debe tener 11 digitos.");
                opcion(v,"selloInclusivo","Certificado","En revision","Pendiente");if(id==0)credenciales(v,true);break;
            case "ofertas":
                positivo(v.get("idEmpresa"));texto(v,"titulo","Titulo",150);texto(v,"ubicacion","Ubicacion",120);
                texto(v,"adaptaciones","Adaptaciones",255);texto(v,"descripcion","Descripcion",10000);
                opcion(v,"modalidad","Presencial accesible","Remoto","Hibrido");opcion(v,"estado","activa","cerrada");
                try { BigDecimal n=new BigDecimal(v.get("salario"));if(n.signum()<0||n.compareTo(new BigDecimal("99999999.99"))>0||n.scale()>2)throw new NumberFormatException(); }
                catch(NumberFormatException ex) {throw new IllegalArgumentException("Ingresa un salario entre 0 y 99999999.99 con hasta dos decimales.");}break;
            case "postulaciones":
                opcion(v,"estado","pendiente","en revision","aceptado","rechazado");
                if(id==0){positivo(v.get("idUsuario"));positivo(v.get("idOferta"));}break;
            default: throw new IllegalArgumentException("Seccion no valida.");
        }
    }
}
