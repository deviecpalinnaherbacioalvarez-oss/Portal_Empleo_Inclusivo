<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="jspf/helpers.jspf"%>
<!DOCTYPE html><html lang="es"><head><title>Mi perfil | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<%@include file="jspf/header.jspf"%>
<main class="container profile-page" id="contenido">
    <header class="editor-heading"><p class="eyebrow teal">MI CUENTA</p><h1>Mi perfil</h1></header>
    <% if (signedUser.isRequiereCambioClave()) { %><div class="alert alert-warning" role="alert"><strong>Cambio obligatorio:</strong> ingresaste con una clave temporal. Define una contraseña personal antes de continuar.</div><% } %>
    <div class="profile-layout">
        <section class="profile-identity" aria-labelledby="account-title">
            <i data-lucide="circle-user-round" class="profile-symbol" aria-hidden="true"></i>
            <h2 id="account-title"><%=h(signedUser.getNombre())%></h2>
            <dl><dt>Correo electrónico</dt><dd><%=h(signedUser.getCorreo())%></dd>
            <dt>Tipo de cuenta</dt><dd><%="ADMIN".equals(signedUser.getRol()) ? "Administrador Central" : "EMPRESA".equals(signedUser.getRol()) ? "Empresa" : "RECURSOS_HUMANOS".equals(signedUser.getRol()) ? "Recursos Humanos" : "SOPORTE_TECNICO".equals(signedUser.getRol()) ? "Soporte Técnico" : "Postulante"%></dd></dl>
            <a class="btn secondary" href="<%=request.getContextPath()%>/<%=panelRoute%>"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver a mi panel</a>
        </section>
        <section class="profile-security" aria-labelledby="password-title">
            <h2 id="password-title">Cambiar contraseña</h2>
            <p class="muted" id="password-help">Al guardar, se cerrará tu sesión y deberás ingresar con la nueva contraseña.</p>
            <% if (request.getAttribute("error") != null) { %><div class="alert alert-danger" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
            <form action="<%=request.getContextPath()%>/perfil" method="post" aria-describedby="password-help">
                <input type="hidden" name="csrf" value="<%=h(session.getAttribute("perfilCsrf"))%>">
                <div class="field"><label for="actual">Contraseña actual</label><div class="password-input"><input class="form-control" type="password" id="actual" name="actual" autocomplete="current-password" maxlength="100" required><button class="icon-btn" type="button" data-toggle-password="actual" aria-label="Mostrar contraseña actual" title="Mostrar contraseña actual" aria-pressed="false"><i data-lucide="eye" aria-hidden="true"></i></button></div></div>
                <div class="field"><label for="nueva">Nueva contraseña</label><div class="password-input"><input class="form-control" type="password" id="nueva" name="nueva" autocomplete="new-password" minlength="8" maxlength="100" aria-describedby="password-rules-profile" required><button class="icon-btn" type="button" data-toggle-password="nueva" aria-label="Mostrar nueva contraseña" title="Mostrar nueva contraseña" aria-pressed="false"><i data-lucide="eye" aria-hidden="true"></i></button></div><ul class="password-rules" id="password-rules-profile" data-password-rules="nueva" aria-label="Requisitos de contraseña"><li data-rule="length">Mínimo 8 caracteres</li><li data-rule="upper">Al menos una mayúscula (A-Z)</li><li data-rule="lower">Al menos una minúscula (a-z)</li><li data-rule="digit">Al menos un número (0-9)</li><li data-rule="special">Al menos un carácter especial (!, @, #, $, %, etc.)</li><li data-rule="spaces">Sin espacios</li></ul></div>
                <div class="field"><label for="confirmar">Confirmar nueva contraseña</label><div class="password-input"><input class="form-control" type="password" id="confirmar" name="confirmar" autocomplete="new-password" minlength="8" maxlength="100" required><button class="icon-btn" type="button" data-toggle-password="confirmar" aria-label="Mostrar confirmación" title="Mostrar confirmación" aria-pressed="false"><i data-lucide="eye" aria-hidden="true"></i></button></div></div>
                <div class="editor-actions"><button class="btn primary" type="submit"><i data-lucide="lock-keyhole" aria-hidden="true"></i> Guardar contraseña</button></div>
            </form>
        </section>
    </div>
</main><%@include file="jspf/footer.jspf"%></body></html>
