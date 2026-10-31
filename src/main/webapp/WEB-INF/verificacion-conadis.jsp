<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.incluyelab.model.VerificacionConadis"%>
<%@include file="jspf/helpers.jspf"%>
<% VerificacionConadis verif=(VerificacionConadis)request.getAttribute("verificacion");String estado=verif==null?"SIN_ENVIAR":verif.getEstadoEfectivo(); %>
<!DOCTYPE html><html lang="es"><head><title>Revisión de carnet | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body><%@include file="jspf/header.jspf"%>
<main class="container auth-layout register-layout" id="contenido"><section class="auth-form"><h1>Tu carnet CONADIS</h1>
<% if(session.getAttribute("conadisAviso")!=null){ %><p role="status"><%=h(session.getAttribute("conadisAviso"))%></p><% session.removeAttribute("conadisAviso"); } %>
<% if(request.getAttribute("error")!=null){ %><div class="alert alert-danger" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<% if("PENDIENTE".equals(estado)){ %><h2>Solicitud pendiente</h2><p>Recursos Humanos revisará manualmente el RUI y la fotografía. Esto no representa todavía una validación oficial en línea.</p><p><strong>RUI enviado:</strong> RD<%=h(verif.getRui())%></p>
<% }else if("APROBADA".equals(estado)){ %><p>Tu verificación fue aprobada manualmente por Recursos Humanos.</p><a class="btn primary" href="<%=request.getContextPath()%>/perfil-profesional">Ver mi perfil</a>
<% }else { %>
<% if(verif!=null&&verif.getMotivo()!=null&&!verif.getMotivo().isEmpty()){ %><div class="alert alert-warning"><%=h(verif.getMotivo())%></div><% } %>
<% if("VENCIDA".equals(estado)){ %><p>La verificación está vencida. Presenta el RUI y una fotografía actualizada.</p><% }else if("RECHAZADA".equals(estado)){ %><p>Corrige los datos observados y vuelve a enviar la solicitud.</p><% }else{ %><p>Completa los datos obligatorios para iniciar la revisión.</p><% } %>
<form method="post" action="<%=request.getContextPath()%>/verificacion-conadis" enctype="multipart/form-data"><input type="hidden" name="csrf" value="<%=h(session.getAttribute("conadisCsrf"))%>"><div class="field"><label for="rui">Código RUI o número de carnet</label><input class="form-control" id="rui" name="rui" maxlength="20" value="<%=h(request.getParameter("rui"))%>" placeholder="Ej. RD406923" required></div><div class="field"><label for="carnetFoto">Fotografía o escaneo del carnet</label><input class="form-control" id="carnetFoto" type="file" name="carnetFoto" accept="image/jpeg,image/png,.jpg,.jpeg,.png" required><small>JPG, JPEG o PNG; máximo 5 MB.</small></div><p>La solicitud quedará PENDIENTE hasta la revisión manual de RRHH.</p><button class="btn primary" type="submit">Enviar solicitud</button></form>
<% } %>
<% if(verif!=null&&verif.isTieneImagen()){ %><p><a href="<%=request.getContextPath()%>/conadis-foto?usuario=<%=verif.getIdUsuario()%>" target="_blank" rel="noopener">Ver carnet enviado</a></p><% } %><p><a href="<%=request.getContextPath()%>/logout">Cerrar sesión</a></p></section></main><%@include file="jspf/footer.jspf"%></body></html>
