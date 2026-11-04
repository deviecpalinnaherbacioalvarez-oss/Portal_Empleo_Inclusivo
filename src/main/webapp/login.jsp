<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="WEB-INF/jspf/helpers.jspf"%>
<!DOCTYPE html><html lang="es"><head><title>Ingresar | IncluyeLab</title><%@include file="WEB-INF/jspf/head.jspf"%></head><body class="login-page">
<%@include file="WEB-INF/jspf/header.jspf"%>
<main class="container auth-layout login-layout" id="contenido">
<section class="auth-form" aria-labelledby="login-title"><h1 id="login-title">Iniciar sesión</h1>
        <% if ("pendiente".equals(request.getParameter("registro"))) { %><div class="alert alert-info" role="status">Solicitud recibida. Un administrador debe activar tu cuenta antes de que puedas ingresar.</div><% } %>
        <% if ("ok".equals(request.getParameter("registro"))) { %><div class="alert alert-success notice" role="status">Tu cuenta está lista. Ya puedes ingresar.</div><% } %>
        <% if ("actualizada".equals(request.getParameter("clave"))) { %><div class="alert alert-success notice" role="status">Contraseña actualizada. Ingresa con tu nueva contraseña.</div><% } %>
        <% if ("expirada".equals(request.getParameter("sesion"))) { %><div class="alert alert-warning" role="status">Tu sesión venció. Ingresa nuevamente para continuar.</div><% } %>
        <% if ("revocada".equals(request.getParameter("sesion"))) { %><div class="alert alert-warning" role="status">Tu acceso cambió. Inicia sesión nuevamente o consulta al administrador.</div><% } %>
        <% if ("requerida".equals(request.getParameter("sesion"))) { %><div class="alert alert-info" role="status">Inicia sesión para acceder a tu panel.</div><% } %>
        <% if (request.getAttribute("error") != null) { %><div class="alert alert-danger error" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
        <form method="post" action="<%=request.getContextPath()%>/login">
            <input type="hidden" name="oferta" value="<%=h(request.getParameter("oferta"))%>">
            <div class="field"><label id="correo-label" for="correo">Correo electrónico</label><input class="form-control" id="correo" name="correo" type="email" autocomplete="username" placeholder="tu@correo.com" value="<%=h(request.getParameter("correo"))%>" required maxlength="150" data-speech-label="Correo electrónico"></div>
            <div class="field"><label id="contrasena-label" for="contrasena">Contraseña</label><div class="password-input"><input class="form-control" id="contrasena" name="contrasena" type="password" autocomplete="current-password" required data-speech-label="Contraseña"><button class="icon-btn" type="button" data-toggle-password="contrasena" aria-label="Mostrar contraseña" title="Mostrar contraseña" aria-pressed="false"><i data-lucide="eye-off" aria-hidden="true"></i></button></div></div>
            <button class="btn primary" type="submit" data-speech-label="Ingresar">Ingresar <i data-lucide="arrow-right" aria-hidden="true"></i></button>
        </form>
        <p class="login-security-note"><i data-lucide="shield-check" aria-hidden="true"></i><span>Por seguridad, la cuenta se bloquea durante 1 hora después de 3 intentos incorrectos.</span></p>
        <p class="auth-foot">¿Primera vez aquí? <a href="<%=request.getContextPath()%>/registro?oferta=<%=h(request.getParameter("oferta"))%>" data-speech-label="Crea tu cuenta">Crea tu cuenta</a></p>
    </section>
    <figure class="login-illustration"><img src="<%=request.getContextPath()%>/assets/img/equipo-inclusivo-login.png" alt="Personas trabajando en equipo." width="305" height="290" decoding="async"></figure>
</main><%@include file="WEB-INF/jspf/footer.jspf"%></body></html>
