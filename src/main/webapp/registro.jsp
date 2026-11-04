<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="WEB-INF/jspf/helpers.jspf"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Crear cuenta | IncluyeLab</title>
    <%@include file="WEB-INF/jspf/head.jspf"%>
</head>
<body>
<%@include file="WEB-INF/jspf/header.jspf"%>

<main class="container auth-layout register-layout" id="contenido">
<!-- Panel Derecho: Formulario en Pasos (Multi-step Wizard) -->
    <section class="auth-form" aria-labelledby="register-title">
        <h2 id="register-title" style="margin-bottom:6px;">Crear tu cuenta</h2>
        <p class="muted font-sm" style="margin-bottom:18px;">Completa tus datos para crear una cuenta.</p>

        <!-- Indicador de Pasos Visual (Stepper) -->
        <div class="reg-stepper" id="reg-stepper" aria-label="Progreso de registro">
            <div class="step-item active" id="indicator-step-1">
                <span class="step-circle">1</span>
                <span class="step-label">Datos de Acceso</span>
            </div>
            <div class="step-item" id="indicator-step-2">
                <span class="step-circle">2</span>
                <span class="step-label">Carnet CONADIS</span>
            </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger error" role="alert"><%=h(request.getAttribute("error"))%></div>
        <% } %>

        <form method="post" action="<%=request.getContextPath()%>/registro" enctype="multipart/form-data" id="registerForm">
            <input type="hidden" name="oferta" value="<%=h(request.getParameter("oferta"))%>">

            <!-- ===================== PASO 1: CUENTA Y ACCESO ===================== -->
            <div id="step-1" class="step-panel" aria-labelledby="indicator-step-1">
                <div class="field">
                    <label for="rol">Tipo de cuenta</label>
                    <select class="form-select" id="rol" name="rol" required onchange="handleRolChange(this.value)">
                        <option value="POSTULANTE">Postulante: busco empleo inclusivo</option>
                        <option value="EMPRESA" <%="EMPRESA".equals(request.getParameter("rol")) ? "selected" : ""%>>Empresa: busco talento</option>
                    </select>
                </div>
                <div class="field">
                    <label id="nombre-label" for="nombre">Nombre completo o Razón Social</label>
                    <input class="form-control" id="nombre" name="nombre" autocomplete="name" maxlength="120" value="<%=h(request.getParameter("nombre"))%>" required placeholder="Ej. Alonso Gabriel Pazos">
                </div>

                <div class="field register-email">
                    <label for="correo">Correo electrónico</label>
                    <input class="form-control" id="correo" name="correo" type="email" autocomplete="email" maxlength="150" value="<%=h(request.getParameter("correo"))%>" required placeholder="tu@correo.com">
                </div>

                <div class="field">
                    <label for="contrasena">Contraseña</label>
                    <div class="password-input">
                        <input class="form-control" id="contrasena" name="contrasena" type="password" minlength="8" maxlength="100" autocomplete="new-password" aria-describedby="password-rules-register" required placeholder="Mínimo 8 caracteres">
                        <button class="icon-btn" type="button" data-toggle-password="contrasena" aria-label="Mostrar contraseña" title="Mostrar contraseña" aria-pressed="false">
                            <i data-lucide="eye" aria-hidden="true"></i>
                        </button>
                    </div>

                </div>

                <div class="field">
                    <label for="confirmarContrasena">Confirmar contraseña</label>
                    <div class="password-input">
                        <input class="form-control" id="confirmarContrasena" name="confirmarContrasena" type="password" maxlength="100" autocomplete="new-password" aria-describedby="confirmacion-ayuda" required>
                        <button class="icon-btn" type="button" data-toggle-password="confirmarContrasena" aria-label="Mostrar contraseña" title="Mostrar contraseña" aria-pressed="false"><i data-lucide="eye-off" aria-hidden="true"></i></button>
                    </div>
                    <small id="confirmacion-ayuda" role="status" aria-live="polite">Escribe la misma contraseña.</small>
                </div>
                <div class="register-password-help">
                    <ul class="password-rules compact" id="password-rules-register" data-password-rules="contrasena" aria-label="Requisitos de contraseña">
                        <li data-rule="length">Mínimo 8 caracteres</li>
                        <li data-rule="upper">Al menos una mayúscula (A-Z)</li>
                        <li data-rule="lower">Al menos una minúscula (a-z)</li>
                        <li data-rule="digit">Al menos un número (0-9)</li>
                        <li data-rule="special">Un símbolo especial (!, @, #, etc.)</li>
                        <li data-rule="spaces">Sin espacios</li>
                    </ul>
                </div>
                <div class="step-actions">
                    <button class="btn magenta" type="button" id="btnNext" onclick="goToStep2()">
                        Continuar a Verificación <i data-lucide="arrow-right" aria-hidden="true"></i>
                    </button>
                    <button class="btn magenta" type="submit" id="btnSubmitDirect" style="display:none;">
                        Crear cuenta de Empresa <i data-lucide="arrow-right" aria-hidden="true"></i>
                    </button>
                </div>
            </div>

            <!-- ===================== PASO 2: VERIFICACIÓN DIGITAL CONADIS ===================== -->
            <div id="step-2" class="step-panel" aria-labelledby="indicator-step-2" hidden>
                <div class="field">
                    <label for="rui">Código RUI o número de carnet CONADIS *</label>
                    <input class="form-control" id="rui" name="rui" maxlength="20" autocomplete="off" value="<%=h(request.getParameter("rui"))%>" placeholder="Ej. RD406923">
                    <small class="muted">Se normalizarán espacios, guiones y el prefijo RD antes de guardar.</small>
                </div>
                <!-- Dropzone Estilizado para la foto del carnet -->
                <div class="field">
                    <label for="carnetFoto">Fotografía o escaneo de tu carnet *</label>
                    <div class="file-drop-area" id="dropArea">
                        <input type="file" id="carnetFoto" name="carnetFoto" accept="image/jpeg,image/png,.jpg,.jpeg,.png" onchange="previewFile(this)">
                        <div class="file-drop-content">
                            <i data-lucide="upload-cloud" aria-hidden="true"></i>
                            <span id="fileNameLabel">Arrastra tu carnet aquí o haz clic para subir</span>
                            <small class="muted">Formatos JPG, JPEG o PNG (hasta 5 MB). Asegura buena iluminación.</small>
                        </div>
                    </div>
                </div>

                <p class="muted" id="aviso-revision-rrhh">Su carnet será revisado por RRHH.</p>
                <label class="check consent-check"><input type="checkbox" name="consentimientoDatos" value="si" required> Autorizo el tratamiento del RUI, DNI y fotografía del carnet exclusivamente para verificar mi acceso al portal, conforme a la Ley 29733. Puedo consultar el estado y solicitar soporte sobre estos datos.</label>
                <div class="step-actions">
                    <button class="btn btn-outline" type="button" onclick="goToStep1()">
                        <i data-lucide="arrow-left" aria-hidden="true"></i> Volver
                    </button>
                    <button class="btn magenta" type="submit">
                        Completar Registro <i data-lucide="check" aria-hidden="true"></i>
                    </button>
                </div>
            </div>
            <p class="visually-hidden" id="register-step-status" role="status" aria-live="polite"></p>
        </form>

        <p class="auth-foot">¿Ya tienes una cuenta? <a href="<%=request.getContextPath()%>/login">Ingresa aquí</a></p>
    </section>
</main>

<script>
    function actualizarConfirmacion() {
        var clave = document.getElementById('contrasena');
        var confirmar = document.getElementById('confirmarContrasena');
        var distintas = confirmar.value.length > 0 && confirmar.value !== clave.value;
        confirmar.setCustomValidity(distintas ? 'Las contraseñas no coinciden.' : '');
        document.getElementById('confirmacion-ayuda').textContent = confirmar.value.length === 0
            ? 'Escribe la misma contraseña.'
            : distintas ? 'Las contraseñas no coinciden.' : 'Las contraseñas coinciden.';
    }
    function handleRolChange(rol) {
        var stepper = document.getElementById('reg-stepper');
        var btnNext = document.getElementById('btnNext');
        var btnSubmitDirect = document.getElementById('btnSubmitDirect');
        if (rol !== 'POSTULANTE') {
            stepper.style.display = 'none';
            btnNext.style.display = 'none';
            btnSubmitDirect.style.display = 'flex';
            btnSubmitDirect.textContent = 'Crear cuenta de Empresa';
        } else {
            stepper.style.display = 'flex';
            btnNext.style.display = 'flex';
            btnSubmitDirect.style.display = 'none';
        }
    }

    function goToStep2() {
        var nombre = document.getElementById('nombre');
        var correo = document.getElementById('correo');
        var clave = document.getElementById('contrasena');

        if (!nombre.checkValidity()) { nombre.reportValidity(); return; }
        if (!correo.checkValidity()) { correo.reportValidity(); return; }
        if (!clave.checkValidity()) { clave.reportValidity(); return; }
        actualizarConfirmacion();
        var confirmar = document.getElementById('confirmarContrasena');
        if (!confirmar.checkValidity()) { confirmar.reportValidity(); return; }

        document.getElementById('step-1').hidden = true;
        document.getElementById('step-2').hidden = false;

        // Requerir campos en paso 2
        ['rui', 'carnetFoto'].forEach(function(id) {
            var el = document.getElementById(id);
            if (el) el.setAttribute('required', 'required');
        });

        document.getElementById('indicator-step-1').classList.add('completed');
        document.getElementById('indicator-step-1').classList.remove('active');
        document.getElementById('indicator-step-1').removeAttribute('aria-current');
        document.getElementById('indicator-step-2').classList.add('active');
        document.getElementById('indicator-step-2').setAttribute('aria-current', 'step');
        document.getElementById('register-step-status').textContent = 'Paso 2 de 2: verificación del carnet CONADIS.';
        window.lucide?.createIcons();
        window.requestAnimationFrame(function() { document.getElementById('rui').focus(); });
    }

    function goToStep1() {
        document.getElementById('step-2').hidden = true;
        document.getElementById('step-1').hidden = false;

        // Quitar obligatoriedad temporal al regresar
        ['rui', 'carnetFoto'].forEach(function(id) {
            var el = document.getElementById(id);
            if (el) el.removeAttribute('required');
        });

        document.getElementById('indicator-step-2').classList.remove('active');
        document.getElementById('indicator-step-2').removeAttribute('aria-current');
        document.getElementById('indicator-step-1').classList.remove('completed');
        document.getElementById('indicator-step-1').classList.add('active');
        document.getElementById('indicator-step-1').setAttribute('aria-current', 'step');
        document.getElementById('register-step-status').textContent = 'Paso 1 de 2: datos de acceso.';
        window.lucide?.createIcons();
        window.requestAnimationFrame(function() { document.getElementById('btnNext').focus(); });
    }

    function previewFile(input) {
        if (input.files && input.files[0]) {
            var name = input.files[0].name;
            var sizeKb = Math.round(input.files[0].size / 1024);
            document.getElementById('fileNameLabel').textContent = '✓ Archivo: ' + name + ' (' + sizeKb + ' KB)';
            document.getElementById('dropArea').style.borderColor = 'var(--teal)';
            document.getElementById('dropArea').style.background = 'var(--teal-soft)';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('indicator-step-1').setAttribute('aria-current', 'step');
        handleRolChange(document.getElementById('rol').value);
        ['contrasena', 'confirmarContrasena'].forEach(function(id) {
            document.getElementById(id).addEventListener('input', actualizarConfirmacion);
            document.getElementById(id).addEventListener('change', actualizarConfirmacion);
        });
        actualizarConfirmacion();
        document.getElementById('registerForm').addEventListener('submit', function(event) {
            actualizarConfirmacion();
            if (!document.getElementById('confirmarContrasena').reportValidity()) event.preventDefault();
        });
    });
</script>

<%@include file="WEB-INF/jspf/footer.jspf"%>
</body>
</html>
