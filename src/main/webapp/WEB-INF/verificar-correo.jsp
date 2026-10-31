<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.incluyelab.model.Usuario"%>
<%@include file="jspf/helpers.jspf"%>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect(request.getContextPath() + "/login?sesion=requerida");
        return;
    }
    String correoEnmascarado = (String) request.getAttribute("correoEnmascarado");
    if (correoEnmascarado == null) correoEnmascarado = usuario.getCorreo();
    String codigoDemo = (String) request.getAttribute("codigoDemo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Verificación de Correo (OTP) | IncluyeLab</title>
    <%@include file="jspf/head.jspf"%>
</head>
<body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard" id="contenido">
    <div class="otp-card-wrap">
        <div class="profile-section text-center p-4">
            <div style="display:inline-grid;place-items:center;width:64px;height:64px;border-radius:50%;background:var(--teal-soft);color:var(--teal);margin-bottom:16px;">
                <i data-lucide="shield-check" style="width:34px;height:34px;"></i>
            </div>

            <p class="eyebrow teal mb-1">PROTOCOLO DE SEGURIDAD · CÓDIGO OTP</p>
            <h1 style="font-size:1.75rem;margin-bottom:8px;">Confirma tu correo electrónico</h1>
            <p class="muted font-sm" style="max-width:420px;margin:0 auto 18px;">
                Hemos emitido un código de autenticación de un solo uso (OTP) a <strong><%=h(correoEnmascarado)%></strong>. Ingrésalo para verificar tu identidad y activar tu cuenta.
            </p>

            <% if (request.getParameter("registro") != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="status">
                    <i data-lucide="check-circle" style="width:18px;height:18px;display:inline;"></i> ¡Tu cuenta ha sido creada! Para continuar, verifica tu correo.
                </div>
            <% } %>
            <% if (request.getParameter("reenviado") != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="status">
                    <i data-lucide="send" style="width:18px;height:18px;display:inline;"></i> Se ha generado y enviado un nuevo código OTP de 6 dígitos.
                </div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger" role="alert">
                    <i data-lucide="alert-triangle" style="width:18px;height:18px;display:inline;"></i> <%=h(request.getAttribute("error"))%>
                </div>
            <% } %>

            <!-- Formulario de Entrada de 6 Dígitos OTP -->
            <form method="post" action="<%=request.getContextPath()%>/verificar-correo" id="otp-form" class="mt-3">
                <input type="hidden" name="accion" value="verificar">
                <input type="hidden" name="codigo" id="codigo-completo" value="">

                <label class="form-label font-sm text-muted d-block text-center" for="otp-1">
                    Ingresa los 6 dígitos del código:
                </label>

                <div class="otp-boxes-container" id="otp-inputs">
                    <input type="text" class="otp-digit-input" id="otp-1" name="d1" maxlength="1" pattern="[0-9]" inputmode="numeric" autocomplete="one-time-code" autofocus required>
                    <input type="text" class="otp-digit-input" id="otp-2" name="d2" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                    <input type="text" class="otp-digit-input" id="otp-3" name="d3" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                    <input type="text" class="otp-digit-input" id="otp-4" name="d4" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                    <input type="text" class="otp-digit-input" id="otp-5" name="d5" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                    <input type="text" class="otp-digit-input" id="otp-6" name="d6" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                </div>

                <button type="submit" class="btn primary w-100 py-2" id="btn-verificar" style="font-size:1rem;">
                    <i data-lucide="check" aria-hidden="true"></i> Verificar y Continuar
                </button>
            </form>

            <!-- Modo Demostración Académica para el Profesor -->
            <% if (codigoDemo != null) { %>
                <div class="otp-demo-card text-start">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <strong class="font-sm text-teal d-flex align-items-center gap-1">
                            <i data-lucide="sparkles" style="width:16px;height:16px;"></i> Modo Demostración / Entorno Académico
                        </strong>
                        <span class="badge badge-success font-sm">Válido 15 min</span>
                    </div>
                    <p class="font-sm mb-2" style="line-height:1.4;">
                        Para facilitar la sustentación y pruebas locales sin depender de un servicio SMTP externo, el código OTP generado en MySQL es:
                    </p>
                    <div class="d-flex align-items-center justify-content-between gap-2">
                        <span style="font-family:monospace;font-size:1.6rem;font-weight:800;letter-spacing:4px;color:var(--teal);background:var(--surface);padding:4px 12px;border-radius:6px;border:1px solid var(--line);">
                            <%=codigoDemo%>
                        </span>
                        <button type="button" class="btn btn-sm" onclick="autocompletarCodigo('<%=codigoDemo%>')">
                            <i data-lucide="copy-check" aria-hidden="true"></i> Autocompletar
                        </button>
                    </div>
                </div>
            <% } %>

            <!-- Reenvío de Código y Cierre de Sesión -->
            <div class="d-flex justify-content-between align-items-center mt-3 pt-2 border-top">
                <form method="post" action="<%=request.getContextPath()%>/verificar-correo" class="d-inline">
                    <input type="hidden" name="accion" value="reenviar">
                    <button type="submit" class="btn btn-link p-0 font-sm" style="text-decoration:underline;">
                        <i data-lucide="refresh-cw" style="width:14px;height:14px;display:inline;"></i> Reenviar código OTP
                    </button>
                </form>

                <a href="<%=request.getContextPath()%>/logout" class="text-muted font-sm" title="Salir a la pantalla principal">
                    Cerrar sesión
                </a>
            </div>
        </div>
    </div>
</main>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        var inputs = Array.from(document.querySelectorAll('.otp-digit-input'));
        var hiddenCodigo = document.getElementById('codigo-completo');
        var form = document.getElementById('otp-form');

        inputs.forEach(function (input, index) {
            // Avance automático al escribir
            input.addEventListener('input', function (e) {
                var val = input.value.replace(/[^0-9]/g, '');
                input.value = val;
                input.classList.toggle('has-value', val.length > 0);

                if (val.length === 1 && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
                actualizarCodigo();
            });

            // Retroceso con Backspace
            input.addEventListener('keydown', function (e) {
                if (e.key === 'Backspace' && !input.value && index > 0) {
                    inputs[index - 1].focus();
                }
            });

            // Soporte para pegar código completo (Ctrl+V)
            input.addEventListener('paste', function (e) {
                e.preventDefault();
                var pasteData = (e.clipboardData || window.clipboardData).getData('text').trim();
                var digits = pasteData.replace(/[^0-9]/g, '').slice(0, 6);
                if (digits.length > 0) {
                    digits.split('').forEach(function (digit, i) {
                        if (inputs[i]) {
                            inputs[i].value = digit;
                            inputs[i].classList.add('has-value');
                        }
                    });
                    var targetIndex = Math.min(digits.length, inputs.length - 1);
                    inputs[targetIndex].focus();
                    actualizarCodigo();
                    if (digits.length === 6) {
                        form.submit();
                    }
                }
            });
        });

        function actualizarCodigo() {
            var codigo = inputs.map(function (inp) { return inp.value; }).join('');
            hiddenCodigo.value = codigo;
            if (codigo.length === 6) {
                // Autoenvío cuando se completan los 6 dígitos
                form.submit();
            }
        }
    });

    function autocompletarCodigo(code) {
        if (!code || code.length !== 6) return;
        var inputs = document.querySelectorAll('.otp-digit-input');
        code.split('').forEach(function (digit, idx) {
            if (inputs[idx]) {
                inputs[idx].value = digit;
                inputs[idx].classList.add('has-value');
            }
        });
        document.getElementById('codigo-completo').value = code;
        document.getElementById('otp-form').submit();
    }
</script>

<%@include file="jspf/footer.jspf"%>
</body>
</html>
