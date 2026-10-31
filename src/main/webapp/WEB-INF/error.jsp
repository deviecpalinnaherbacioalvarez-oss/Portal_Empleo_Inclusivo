<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<%
    Object codigo = request.getAttribute("javax.servlet.error.status_code");
    boolean noEncontrado = codigo instanceof Integer && (Integer) codigo == 404;
%>
<!DOCTYPE html><html lang="es"><head><title><%=noEncontrado ? "Página no disponible" : "Servicio no disponible"%> | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<main class="container dashboard" id="contenido">
<h1><%=noEncontrado ? "No encontramos lo que buscas" : "No pudimos completar tu solicitud"%></h1>
<p class="muted"><%=noEncontrado ? "La empresa u oferta solicitada no existe o ya no está publicada." : "Ocurrió un problema temporal. Intenta nuevamente en unos minutos."%></p>
<a class="btn primary" href="<%=request.getContextPath()%>/inicio">Volver al inicio</a>
</main>
</body></html>

