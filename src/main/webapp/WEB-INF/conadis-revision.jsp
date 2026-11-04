<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.incluyelab.model.VerificacionConadis,com.incluyelab.model.HistorialVerificacionConadis,java.util.List,java.util.Collections,java.time.format.DateTimeFormatter"%>
<%@include file="jspf/helpers.jspf"%>
<%
    VerificacionConadis v = (VerificacionConadis) request.getAttribute("verificacion");
    List<HistorialVerificacionConadis> historial = (List<HistorialVerificacionConadis>) request.getAttribute("historial");
    if (historial == null) historial = Collections.emptyList();
    DateTimeFormatter fechaHora = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String estadoVista = v.getEstadoEfectivo();
    String claseEstado = "PENDIENTE".equals(estadoVista) ? "is-pending" : "APROBADA".equals(estadoVista) ? "is-approved" : "RECHAZADA".equals(estadoVista) ? "is-rejected" : "is-expired";
%>
<!DOCTYPE html>
<html lang="es">
<head><title>Revisión de carnet · RRHH | IncluyeLab</title><%@include file="jspf/head.jspf"%></head>
<body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard conadis-review-page" id="contenido">
    <a class="text-link conadis-back-link" href="<%=request.getContextPath()%>/recursos-humanos#conadis"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver a verificaciones</a>
    <header class="conadis-review-header">
        <div><p class="eyebrow teal">EXPEDIENTE DOCUMENTARIO · RECURSOS HUMANOS</p><h1>Revisión de identidad CONADIS</h1><p><strong><%=h(v.getNombreCuenta())%></strong><span aria-hidden="true"> · </span><%=h(v.getCorreoCuenta())%></p></div>
        <div class="conadis-header-status"><span>Estado del expediente</span><strong class="conadis-state <%=claseEstado%>"><span aria-hidden="true"></span><%=h(estadoVista)%></strong></div>
    </header>
    <div class="conadis-review-notice" role="note"><i data-lucide="shield-alert" aria-hidden="true"></i><div><strong>Revisión manual responsable</strong><p>IncluyeLab no dispone de una consulta oficial en línea. Contrasta visualmente el carnet y registra únicamente la información necesaria para resolver la solicitud.</p></div></div>
    <% if(request.getAttribute("error") != null){ %><div class="alert alert-danger" role="alert"><i data-lucide="circle-alert" aria-hidden="true"></i> <%=h(request.getAttribute("error"))%></div><% } %>

    <div class="conadis-review-grid">
        <section class="conadis-document-panel" aria-labelledby="documento-title">
            <div class="conadis-panel-heading"><span><i data-lucide="id-card" aria-hidden="true"></i></span><div><p>Documento protegido</p><h2 id="documento-title">Carnet presentado</h2></div></div>
            <% if(v.isTieneImagen()){ %>
                <a class="conadis-secure-preview" href="<%=request.getContextPath()%>/conadis-foto?usuario=<%=v.getIdUsuario()%>" target="_blank" rel="noopener" aria-label="Ampliar fotografía privada del carnet CONADIS"><img src="<%=request.getContextPath()%>/conadis-foto?usuario=<%=v.getIdUsuario()%>" alt="Carnet CONADIS enviado por <%=h(v.getNombreCuenta())%>"><span><i data-lucide="maximize-2" aria-hidden="true"></i> Ampliar documento</span></a>
            <% }else{ %>
                <div class="conadis-no-document"><i data-lucide="file-x-2" aria-hidden="true"></i><strong>Documento no disponible</strong><span>La solicitud no puede aprobarse sin una fotografía legible.</span></div>
            <% } %>
            <dl class="conadis-document-meta"><div><dt>RUI declarado</dt><dd>RD<%=h(v.getRui())%></dd></div><div><dt>Fecha de envío</dt><dd><%=v.getFechaEnvio()==null?"Sin fecha":v.getFechaEnvio().format(fechaHora)%></dd></div><div><dt>Número de envíos</dt><dd><%=v.getEnvios()%></dd></div><div><dt>Tratamiento</dt><dd>Acceso restringido</dd></div></dl>
        </section>

        <section class="conadis-decision-panel" aria-labelledby="resolucion-title">
            <div class="conadis-panel-heading"><span><i data-lucide="clipboard-check" aria-hidden="true"></i></span><div><p>Dictamen interno</p><h2 id="resolucion-title">Resolución de Recursos Humanos</h2></div></div>
            <% if("PENDIENTE".equals(v.getEstado())){ %>
                <ol class="conadis-review-steps" aria-label="Pasos de revisión"><li><span>1</span>Compara RUI, DNI, nombres y apellidos.</li><li><span>2</span>Comprueba legibilidad y vigencia.</li><li><span>3</span>Registra una decisión sustentada.</li></ol>
                <form method="post" action="<%=request.getContextPath()%>/revision-conadis" class="conadis-resolution-form">
                    <input type="hidden" name="csrf" value="<%=h(session.getAttribute("revisionConadisCsrf"))%>"><input type="hidden" name="id" value="<%=v.getIdUsuario()%>">
                    <div class="field conadis-decision-field"><label for="decision">Decisión de revisión</label><select class="form-select" id="decision" name="decision" required><option value="">Selecciona una decisión</option><option value="aprobar">Aprobar manualmente</option><option value="rechazar">Rechazar y solicitar corrección</option><option value="vencer">Marcar como vencida</option></select></div>
                    <div class="conadis-form-grid">
                        <div class="field"><label for="rui">RUI del carnet</label><input class="form-control" id="rui" name="rui" maxlength="20" data-dato-carnet value="<%=h(v.getRui())%>" readonly aria-readonly="true"></div>
                        <div class="field"><label for="dni">DNI del titular</label><input class="form-control" id="dni" name="dni" inputmode="numeric" pattern="[0-9]{8}" maxlength="8" data-dato-carnet value="<%=h(request.getParameter("dni"))%>"></div>
                        <div class="field"><label for="nombres">Nombres</label><input class="form-control" id="nombres" name="nombres" maxlength="80" data-dato-carnet value="<%=h(request.getParameter("nombres"))%>"></div>
                        <div class="field"><label for="apellidos">Apellidos</label><input class="form-control" id="apellidos" name="apellidos" maxlength="80" data-dato-carnet value="<%=h(request.getParameter("apellidos"))%>"></div>
                        <div class="field conadis-full-field"><label for="fechaCaducidad">Fecha de caducidad</label><input class="form-control" id="fechaCaducidad" name="fechaCaducidad" type="date" data-dato-carnet value="<%=h(request.getParameter("fechaCaducidad"))%>"></div>
                        <div class="field conadis-full-field"><label for="motivo">Observación o motivo</label><textarea class="form-control" id="motivo" name="motivo" maxlength="1000" rows="4" placeholder="Describe el contraste realizado o el motivo de la observación"><%=h(request.getParameter("motivo"))%></textarea><small>Obligatorio para rechazo o vencimiento.</small></div>
                    </div>
                    <button class="btn primary conadis-submit-decision" type="submit"><i data-lucide="save" aria-hidden="true"></i> Guardar resolución</button>
                </form>
                <script>document.getElementById('decision').addEventListener('change',function(){var aprobar=this.value==='aprobar';document.querySelectorAll('[data-dato-carnet]').forEach(function(campo){if(!campo.readOnly)campo.required=aprobar;});document.getElementById('motivo').required=this.value==='rechazar'||this.value==='vencer';});</script>
            <% }else if("APROBADA".equals(v.getEstado())){ %>
                <div class="conadis-resolution-summary is-approved"><i data-lucide="badge-check" aria-hidden="true"></i><div><strong>Identidad revisada internamente</strong><span>La solicitud se encuentra habilitada para el uso de las funciones de postulante.</span></div></div>
                <dl class="conadis-resolved-data"><div><dt>Titular</dt><dd><%=h(v.getNombres())%> <%=h(v.getApellidos())%></dd></div><div><dt>DNI</dt><dd><%=h(v.getDni())%></dd></div><div><dt>Caducidad</dt><dd><%=h(v.getFechaCaducidad())%></dd></div><div><dt>Responsable</dt><dd><%=h(v.getNombreRevisor())%></dd></div></dl>
                <form method="post" action="<%=request.getContextPath()%>/revision-conadis" class="conadis-expire-form"><input type="hidden" name="csrf" value="<%=h(session.getAttribute("revisionConadisCsrf"))%>"><input type="hidden" name="id" value="<%=v.getIdUsuario()%>"><input type="hidden" name="decision" value="vencer"><div class="field"><label for="motivo">Motivo para marcar como vencida</label><textarea class="form-control" id="motivo" name="motivo" minlength="10" maxlength="1000" rows="3" required></textarea></div><button class="btn" type="submit"><i data-lucide="calendar-x" aria-hidden="true"></i> Marcar como vencida</button></form>
            <% }else{ %>
                <div class="conadis-resolution-summary <%=claseEstado%>"><i data-lucide="<%="RECHAZADA".equals(estadoVista)?"circle-x":"calendar-x"%>" aria-hidden="true"></i><div><strong>Expediente <%=h(estadoVista.toLowerCase())%></strong><span>El postulante puede corregir y reenviar sus datos desde su sesión.</span></div></div>
                <dl class="conadis-resolved-data"><div><dt>Estado</dt><dd><%=h(estadoVista)%></dd></div><div><dt>Motivo</dt><dd><%=h(v.getMotivo())%></dd></div><div><dt>Responsable</dt><dd><%=h(v.getNombreRevisor())%></dd></div><div><dt>Fecha</dt><dd><%=v.getFechaRevision()==null?"Sin fecha":v.getFechaRevision().format(fechaHora)%></dd></div></dl>
            <% } %>
        </section>
    </div>

    <section class="conadis-audit-section" aria-labelledby="auditoria-title">
        <div class="conadis-audit-heading"><div><p class="eyebrow teal">TRAZABILIDAD</p><h2 id="auditoria-title">Historial de auditoría</h2></div><span><%=historial.size()%> eventos registrados</span></div>
        <div class="table-responsive conadis-audit-table"><table class="table align-middle"><thead><tr><th scope="col">Fecha</th><th scope="col">Evento</th><th scope="col">Estado</th><th scope="col">Responsable</th><th scope="col">Motivo registrado</th></tr></thead><tbody><% for(HistorialVerificacionConadis hst:historial){ String estadoHistorial=hst.getEstado(); String claseHistorial="PENDIENTE".equals(estadoHistorial)?"is-pending":"APROBADA".equals(estadoHistorial)?"is-approved":"RECHAZADA".equals(estadoHistorial)?"is-rejected":"is-expired"; %><tr><td><%=hst.getFechaEvento()==null?"Sin fecha":hst.getFechaEvento().format(fechaHora)%></td><td><strong><%=h(hst.getAccion())%></strong></td><td><span class="conadis-state <%=claseHistorial%>"><span aria-hidden="true"></span><%=h(estadoHistorial)%></span></td><td><%=hst.getNombreRevisor()==null?"Postulante":h(hst.getNombreRevisor())%></td><td><%=hst.getMotivo()==null||hst.getMotivo().isEmpty()?"Sin observaciones":h(hst.getMotivo())%></td></tr><% } %><% if(historial.isEmpty()){ %><tr><td colspan="5"><div class="conadis-empty"><i data-lucide="history" aria-hidden="true"></i><strong>Sin eventos registrados</strong></div></td></tr><% } %></tbody></table></div>
    </section>
</main>
<%@include file="jspf/footer.jspf"%>
</body>
</html>
