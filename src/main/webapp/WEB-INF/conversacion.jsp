<%@page import="java.util.List,java.util.Collections,com.incluyelab.model.MensajePostulacion,com.incluyelab.model.Postulacion,com.incluyelab.model.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="jspf/helpers.jspf"%>
<%
    Usuario usuario=(Usuario)session.getAttribute("usuario");
    Postulacion postulacion=(Postulacion)request.getAttribute("postulacion");
    List<MensajePostulacion> mensajes=(List<MensajePostulacion>)request.getAttribute("mensajes");
    if(usuario==null||postulacion==null){response.sendRedirect(request.getContextPath()+"/login");return;}
    if(mensajes==null)mensajes=Collections.emptyList();
    boolean empresa="EMPRESA".equals(usuario.getRol());
    Object error=session.getAttribute("conversacionError");session.removeAttribute("conversacionError");
%>
<!DOCTYPE html><html lang="es"><head><title>Conversación de la postulación | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<%@include file="jspf/header.jspf"%>
<main class="container conversation-page" id="contenido">
    <div class="conversation-heading">
        <a class="btn" href="<%=request.getContextPath()%>/<%=empresa?"empresa#candidatos":"postulante#postulaciones"%>"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver a <%=empresa?"candidatos":"mis postulaciones"%></a>
        <div><p class="eyebrow teal">MENSAJERÍA DE LA POSTULACIÓN</p><h1><%=h(postulacion.getOferta())%></h1><p><strong><%=h(postulacion.getEmpresa())%></strong> · <%=h(postulacion.getPostulante())%></p></div>
        <span class="badge"><%=h(postulacion.getEstado())%></span>
    </div>
    <section class="conversation-shell" aria-labelledby="titulo-conversacion">
        <div class="conversation-intro"><div><h2 id="titulo-conversacion">Conversación</h2><p>Este espacio es privado entre la empresa y la persona que realizó la postulación.</p></div><i data-lucide="messages-square" aria-hidden="true"></i></div>
        <% if(error!=null){ %><div class="alert alert-danger" role="alert"><%=h(error)%></div><% } %>
        <div class="message-thread" aria-live="polite" aria-label="Historial de mensajes">
            <% if(mensajes.isEmpty()){ %><div class="conversation-empty"><i data-lucide="message-circle" aria-hidden="true"></i><h3>Inicia la conversación</h3><p>Consulta sobre el proceso, la entrevista, los documentos o las condiciones del puesto.</p></div><% } %>
            <% for(MensajePostulacion m:mensajes){boolean propio=m.getIdRemitente()==usuario.getIdUsuario();%>
            <article class="message-bubble <%=propio?"message-own":"message-other"%>">
                <div class="message-meta"><strong><%=propio?"Tú":h(m.getNombreRemitente())%></strong><span><%=h(m.getFechaCreacionTexto())%></span></div>
                <p><%=h(m.getMensaje())%></p>
            </article><% } %>
            <span id="ultimo-mensaje" aria-hidden="true"></span>
        </div>
        <form class="message-composer" method="post" action="<%=request.getContextPath()%>/conversacion">
            <input type="hidden" name="csrf" value="<%=h(session.getAttribute("conversacionCsrf"))%>">
            <input type="hidden" name="id" value="<%=postulacion.getIdPostulacion()%>">
            <label for="mensaje">Escribe un mensaje</label>
            <div class="message-compose-row"><textarea class="form-control" id="mensaje" name="mensaje" maxlength="2000" rows="3" placeholder="Escribe aquí. No compartas contraseñas ni información médica." required></textarea><button class="btn primary" type="submit"><i data-lucide="send" aria-hidden="true"></i> Enviar</button></div>
            <small>Máximo 2000 caracteres. El mensaje quedará registrado en esta postulación.</small>
        </form>
    </section>
</main><%@include file="jspf/footer.jspf"%></body></html>
