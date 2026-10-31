<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.incluyelab.model.Empresa"%>
<%@include file="jspf/helpers.jspf"%>
<% Empresa ficha=(Empresa)request.getAttribute("ficha"); %>
<!DOCTYPE html><html lang="es"><head><title>Presentación de mi empresa | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard admin-editor" id="contenido">
<a class="text-link" href="<%=request.getContextPath()%>/empresa"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver a mi empresa</a>
<header class="editor-heading"><p class="eyebrow teal">PERFIL EMPRESARIAL</p><h1>Presenta tu empresa</h1><p class="muted">Al enviar esta ficha, quedará pendiente de aprobación. Tus ofertas no serán visibles hasta que el administrador la apruebe.</p></header>
<% if(request.getAttribute("error")!=null){ %><div class="alert alert-danger" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<form class="admin-form" method="post" action="<%=request.getContextPath()%>/empresa/perfil">
<input type="hidden" name="csrf" value="<%=h(session.getAttribute("empresaCsrf"))%>"><input type="hidden" name="version" value="<%=ficha.getVersionRevision()%>">
<div class="row g-3">
<div class="field col-md-6"><label for="razonSocial">Nombre o razón social</label><input class="form-control" id="razonSocial" name="razonSocial" maxlength="150" value="<%=h(ficha.getRazonSocial())%>" required></div>
<div class="field col-md-6"><label for="ruc">RUC</label><input class="form-control" id="ruc" name="ruc" inputmode="numeric" pattern="[0-9]{11}" maxlength="11" value="<%="00000000000".equals(ficha.getRuc())?"":h(ficha.getRuc())%>" required></div>
<div class="field col-md-6"><label for="sector">Sector o tipo de negocio</label><input class="form-control" id="sector" name="sector" maxlength="100" value="<%=h(ficha.getSector())%>" required></div>
<div class="field col-md-6"><label for="anioInicio">Año de inicio de actividades</label><input class="form-control" type="number" min="1800" max="<%=java.time.Year.now().getValue()%>" id="anioInicio" name="anioInicio" value="<%=h(ficha.getAnioInicio())%>" required></div>
<div class="field col-12"><label for="presentacion">Presentación del negocio</label><textarea class="form-control" id="presentacion" name="presentacion" rows="5" maxlength="5000" required><%=h(ficha.getPresentacion())%></textarea></div>
<div class="field col-12"><label for="logros">Logros y metas cumplidas</label><textarea class="form-control" id="logros" name="logros" rows="5" maxlength="5000" aria-describedby="logros-ayuda" required><%=h(ficha.getLogros())%></textarea><small id="logros-ayuda">Incluye hitos, fechas y resultados. Si aún no tienes logros registrados, indícalo.</small></div>
</div><div class="editor-actions"><button class="btn primary" type="submit"><i data-lucide="send" aria-hidden="true"></i> Enviar a revisión</button><a class="btn" href="<%=request.getContextPath()%>/empresa">Cancelar</a></div>
</form></main><%@include file="jspf/footer.jspf"%></body></html>
