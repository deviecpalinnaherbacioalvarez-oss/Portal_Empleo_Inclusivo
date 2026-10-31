<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map,java.util.List,com.incluyelab.model.*"%>
<%@include file="jspf/helpers.jspf"%>
<%
String entidad=(String)request.getAttribute("entidad");
int registroId=(Integer)request.getAttribute("registroId");
Map<String,String> valores=(Map<String,String>)request.getAttribute("valores");
String singular="usuarios".equals(entidad)?"usuario":"empresas".equals(entidad)?"empresa":"ofertas".equals(entidad)?"oferta":"postulaci&oacute;n";
%>
<!DOCTYPE html><html lang="es"><head><title>Confirmar eliminaci&oacute;n | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard admin-editor" id="contenido">
<a class="text-link" href="<%=request.getContextPath()%>/admin#<%=entidad%>"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver a <%=entidad%></a>
<header class="editor-heading"><p class="eyebrow teal">ADMINISTRACI&Oacute;N</p><h1>Eliminar <%=singular%></h1></header>
<% if(request.getAttribute("error")!=null){ %><div class="alert alert-danger error" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<div class="alert alert-warning" role="note"><strong>Esta acci&oacute;n no se puede deshacer.</strong> Los registros con informaci&oacute;n relacionada no se pueden eliminar.</div>
<p>Registro seleccionado: <strong><%=h(valores.get("etiqueta"))%></strong> (#<%=registroId%>).</p>
<% if("empresas".equals(entidad)){ %><p>La cuenta de acceso se conserva y puede desactivarse desde Usuarios.</p><% } %>
<form method="post" action="<%=request.getContextPath()%>/admin" class="editor-actions">
<input type="hidden" name="csrf" value="<%=h(session.getAttribute("adminCsrf"))%>">
<input type="hidden" name="entidad" value="<%=entidad%>"><input type="hidden" name="id" value="<%=registroId%>"><input type="hidden" name="accion" value="eliminar">
<button class="btn btn-danger" type="submit"><i data-lucide="trash-2" aria-hidden="true"></i> Eliminar definitivamente</button><a class="btn" href="<%=request.getContextPath()%>/admin#<%=entidad%>">Cancelar</a>
</form></main><%@include file="jspf/footer.jspf"%></body></html>
