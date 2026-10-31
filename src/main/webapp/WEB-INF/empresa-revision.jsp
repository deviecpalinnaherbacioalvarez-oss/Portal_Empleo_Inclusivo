<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.incluyelab.model.Empresa"%>
<%@include file="jspf/helpers.jspf"%>
<% Empresa ficha=(Empresa)request.getAttribute("ficha"); %>
<!DOCTYPE html><html lang="es"><head><title>Revisar empresa | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard admin-editor" id="contenido">
<a class="text-link" href="<%=request.getContextPath()%>/admin#empresas"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver a empresas</a>
<%@include file="jspf/empresa-detalle.jspf"%>
<p><strong>RUC:</strong> <%=h(ficha.getRuc())%> · <span class="badge">Estado: <%=h(ficha.getEstadoRevision())%></span></p>
<% if(request.getAttribute("error")!=null){ %><div class="alert alert-danger" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<% if("pendiente".equals(ficha.getEstadoRevision())){ %>
<section class="business-copy"><h2>Revisión de la solicitud</h2>
<% if(!ficha.isFichaCompleta()){ %><div class="alert alert-warning">La ficha está incompleta. La empresa debe completarla antes de ser aprobada.</div><% } %>
<form method="post" action="<%=request.getContextPath()%>/revision-empresa" class="review-form">
<input type="hidden" name="csrf" value="<%=h(session.getAttribute("revisionCsrf"))%>"><input type="hidden" name="id" value="<%=ficha.getIdEmpresa()%>"><input type="hidden" name="version" value="<%=ficha.getVersionRevision()%>">
<div class="field"><label for="decision">Decisión</label><select class="form-select" id="decision" name="decision" required><option value="">Seleccionar</option><% if(ficha.isFichaCompleta()){ %><option value="aprobada">Aprobar empresa</option><% } %><option value="rechazada">Rechazar solicitud</option></select></div>
<div class="field"><label for="motivo">Observaciones para la empresa</label><textarea class="form-control" name="motivo" id="motivo" rows="3" maxlength="1000" aria-describedby="motivo-help"><%=h(request.getParameter("motivo"))%></textarea><small id="motivo-help">Obligatorias cuando se rechaza una solicitud.</small></div>
<div class="editor-actions"><button class="btn primary" type="submit"><i data-lucide="check-check" aria-hidden="true"></i> Confirmar decisión</button></div>
</form></section>
<% }else{ %><div class="alert alert-info">Esta ficha ya fue revisada. <%=h(ficha.getMotivoRevision())%></div><% } %>
</main><%@include file="jspf/footer.jspf"%></body></html>
