<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map,java.util.List,com.incluyelab.model.*"%>
<%@include file="jspf/helpers.jspf"%>
<%
String entidad=(String)request.getAttribute("entidad");
int registroId=(Integer)request.getAttribute("registroId");
Map<String,String> valores=(Map<String,String>)request.getAttribute("valores");
String singular="usuarios".equals(entidad)?"usuario":"empresas".equals(entidad)?"empresa":"ofertas".equals(entidad)?"oferta":"postulaci&oacute;n";
String seccionVolver="usuarios".equals(entidad)&&"EMPRESA".equals(valores.get("rol"))?"empresas":entidad;
Usuario actorAdmin=(Usuario)session.getAttribute("usuario");
boolean cuentaPropia=registroId>0&&actorAdmin!=null&&actorAdmin.getIdUsuario()==registroId;
boolean cuentaPostulante=registroId>0&&"POSTULANTE".equals(valores.get("rol"));
%>
<!DOCTYPE html><html lang="es"><head><title>Administraci&oacute;n | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard admin-editor" id="contenido">
<a class="text-link" href="<%=request.getContextPath()%>/admin#<%=seccionVolver%>"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver a <%=seccionVolver%></a>
<header class="editor-heading"><p class="eyebrow teal">ADMINISTRACI&Oacute;N</p><h1><%=registroId==0?"Crear":"Editar"%> <%=singular%></h1><% if(registroId>0){ %><p class="muted"><%=h(valores.get("etiqueta"))%> &middot; #<%=registroId%></p><% } %></header>
<% if(request.getAttribute("error")!=null){ %><div class="alert alert-danger error" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<form method="post" action="<%=request.getContextPath()%>/admin" class="admin-form">
<input type="hidden" name="csrf" value="<%=h(session.getAttribute("adminCsrf"))%>">
<input type="hidden" name="entidad" value="<%=entidad%>">
<input type="hidden" name="id" value="<%=registroId%>">
<input type="hidden" name="accion" value="guardar">
<div class="row g-3">
<% if("usuarios".equals(entidad)){ %>
<div class="col-md-6 field"><label class="form-label" for="nombre">Nombre completo</label><input class="form-control" id="nombre" name="nombre" type="text" maxlength="120" value="<%=h(valores.get("nombre"))%>" required ></div>

<div class="col-md-6 field"><label class="form-label" for="correo">Correo electr&oacute;nico</label><input class="form-control" id="correo" name="correo" type="email" maxlength="150" value="<%=h(valores.get("correo"))%>" required ></div>

<div class="col-md-6 field"><label class="form-label" for="contrasena">Contrase&ntilde;a <%=registroId>0?"nueva (opcional)":""%></label><input class="form-control" id="contrasena" name="contrasena" type="password" minlength="8" maxlength="100" autocomplete="new-password" <%=registroId==0?"required":""%> aria-describedby="password-help password-rules-admin"><small id="password-help"><%=registroId>0?"Deja el campo vacío para conservar la actual.":"Debe cumplir todos los requisitos."%></small><ul class="password-rules compact" id="password-rules-admin" data-password-rules="contrasena" aria-label="Requisitos de contraseña"><li data-rule="length">8 caracteres</li><li data-rule="upper">Una mayúscula</li><li data-rule="lower">Una minúscula</li><li data-rule="digit">Un número</li><li data-rule="special">Un carácter especial</li><li data-rule="spaces">Sin espacios</li></ul></div>

<div class="col-md-6 field"><label class="form-label" for="rol">Rol</label><% if(cuentaPropia||cuentaPostulante){ %><input type="hidden" name="rol" value="<%=h(valores.get("rol"))%>"><select class="form-select" id="rol" disabled><option><%=cuentaPostulante?"Postulante":"Administrador Central"%></option></select><small>Este rol est&aacute; protegido y no puede cambiarse.</small><% }else{ %><select class="form-select" id="rol" name="rol" required><option value="ADMIN" <%="ADMIN".equals(valores.get("rol"))?"selected":""%>>Administrador Central</option><option value="RECURSOS_HUMANOS" <%="RECURSOS_HUMANOS".equals(valores.get("rol"))?"selected":""%>>Recursos Humanos</option><option value="SOPORTE_TECNICO" <%="SOPORTE_TECNICO".equals(valores.get("rol"))?"selected":""%>>Soporte T&eacute;cnico</option></select><% } %></div>

<div class="col-md-6 field"><label class="form-label" for="estado">Estado</label><% if(cuentaPropia){ %><input type="hidden" name="estado" value="activo"><select class="form-select" id="estado" disabled><option>Activo</option></select><small>No puedes desactivar tu propia cuenta.</small><% }else{ %><select class="form-select" id="estado" name="estado" required><option value="activo" <%="activo".equals(valores.get("estado"))?"selected":""%>>Activo</option><option value="inactivo" <%="inactivo".equals(valores.get("estado"))?"selected":""%>>Inactivo</option></select><% } %></div>

<% } else if("ofertas".equals(entidad)){ %>
<div class="col-md-6 field"><label class="form-label" for="idEmpresa">Empresa</label><select class="form-select" id="idEmpresa" name="idEmpresa" required><option value="">Seleccionar empresa</option><% for(Empresa e:(List<Empresa>)request.getAttribute("empresas")){ %><option value="<%=e.getIdEmpresa()%>" <%=String.valueOf(e.getIdEmpresa()).equals(valores.get("idEmpresa"))?"selected":""%>><%=h(e.getRazonSocial())%></option><% } %></select></div>
<div class="col-md-6 field"><label class="form-label" for="titulo">T&iacute;tulo del puesto</label><input class="form-control" id="titulo" name="titulo" type="text" maxlength="150" value="<%=h(valores.get("titulo"))%>" required ></div>

<div class="col-md-6 field"><label class="form-label" for="modalidad">Modalidad</label><select class="form-select" id="modalidad" name="modalidad" required><option value="Presencial accesible" <%="Presencial accesible".equals(valores.get("modalidad"))?"selected":""%>>Presencial accesible</option><option value="Remoto" <%="Remoto".equals(valores.get("modalidad"))?"selected":""%>>Remoto</option><option value="Hibrido" <%="Hibrido".equals(valores.get("modalidad"))?"selected":""%>>H&iacute;brido</option></select></div>

<div class="col-md-6 field"><label class="form-label" for="ubicacion">Ciudad o distrito</label><input class="form-control" id="ubicacion" name="ubicacion" type="text" maxlength="120" value="<%=h(valores.get("ubicacion"))%>" required ></div>

<div class="col-md-6 field"><label class="form-label" for="salario">Salario mensual (S/)</label><input class="form-control" id="salario" name="salario" type="number" maxlength="20" value="<%=h(valores.get("salario"))%>" required min="0" max="99999999.99" step="0.01"></div>

<div class="col-md-6 field"><label class="form-label" for="estado">Estado</label><select class="form-select" id="estado" name="estado" required><option value="activa" <%="activa".equals(valores.get("estado"))?"selected":""%>>Activa</option><option value="cerrada" <%="cerrada".equals(valores.get("estado"))?"selected":""%>>Cerrada</option></select></div>

<% request.setAttribute("apoyosSeleccionados",valores.get("apoyos")); %>
<%@include file="jspf/apoyos-form.jspf"%>
<div class="col-12 field"><label class="form-label" for="adaptaciones">Detalle y condiciones de las adaptaciones</label><input class="form-control" id="adaptaciones" name="adaptaciones" type="text" maxlength="255" value="<%=h(valores.get("adaptaciones"))%>" required></div>

<div class="col-12 field"><label class="form-label" for="descripcion">Descripci&oacute;n del puesto</label><textarea class="form-control" id="descripcion" name="descripcion" rows="6" maxlength="10000" required><%=h(valores.get("descripcion"))%></textarea></div>
<% } else if("postulaciones".equals(entidad)){ if(registroId==0){ %>
<div class="col-md-6 field"><label class="form-label" for="idUsuario">Postulante</label><select class="form-select" id="idUsuario" name="idUsuario" required><option value="">Seleccionar postulante</option><% for(Usuario u:(List<Usuario>)request.getAttribute("usuarios")){ if("POSTULANTE".equals(u.getRol())&&"activo".equals(u.getEstado())){ %><option value="<%=u.getIdUsuario()%>" <%=String.valueOf(u.getIdUsuario()).equals(valores.get("idUsuario"))?"selected":""%>><%=h(u.getNombre())%> &middot; <%=h(u.getCorreo())%></option><% }} %></select></div>
<div class="col-md-6 field"><label class="form-label" for="idOferta">Oferta activa</label><select class="form-select" id="idOferta" name="idOferta" required><option value="">Seleccionar oferta</option><% for(Oferta o:(List<Oferta>)request.getAttribute("ofertas")){ if("activa".equals(o.getEstado())){ %><option value="<%=o.getIdOferta()%>" <%=String.valueOf(o.getIdOferta()).equals(valores.get("idOferta"))?"selected":""%>><%=h(o.getTitulo())%> &middot; <%=h(o.getEmpresa())%></option><% }} %></select></div>
<% } %>
<div class="col-md-6 field"><label class="form-label" for="estado">Estado de la postulaci&oacute;n</label><select class="form-select" id="estado" name="estado" required><option value="pendiente" <%="pendiente".equals(valores.get("estado"))?"selected":""%>>Pendiente</option><option value="en revision" <%="en revision".equals(valores.get("estado"))?"selected":""%>>En revisi&oacute;n</option><option value="aceptado" <%="aceptado".equals(valores.get("estado"))?"selected":""%>>Aceptado</option><option value="rechazado" <%="rechazado".equals(valores.get("estado"))?"selected":""%>>Rechazado</option></select></div>

<% } %>
</div>
<div class="editor-actions"><button class="btn primary" type="submit"><i data-lucide="save" aria-hidden="true"></i> Guardar cambios</button><a class="btn" href="<%=request.getContextPath()%>/admin#<%=seccionVolver%>">Cancelar</a></div>
</form></main><%@include file="jspf/footer.jspf"%></body></html>
