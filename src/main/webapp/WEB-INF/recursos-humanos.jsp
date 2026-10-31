<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List,java.util.ArrayList,java.util.Collections,com.incluyelab.model.Usuario,com.incluyelab.model.Postulacion,com.incluyelab.model.EvaluacionRRHH"%>
<%@include file="jspf/helpers.jspf"%>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"RECURSOS_HUMANOS".equals(usuario.getRol())) {
        response.sendRedirect(request.getContextPath()+"/login");
        return;
    }
    List<Postulacion> candidatos = (List<Postulacion>) request.getAttribute("candidatos");
    List<EvaluacionRRHH> evaluaciones = (List<EvaluacionRRHH>) request.getAttribute("evaluaciones");
    if (candidatos == null) candidatos = Collections.emptyList();
    if (evaluaciones == null) evaluaciones = Collections.emptyList();

    int totalCandidatos = candidatos.size();
    int totalEvaluaciones = evaluaciones.size();
    int recomendados = 0;
    int sumaCompatibilidad = 0;
    for (EvaluacionRRHH ev : evaluaciones) {
        if ("APROBADO".equals(ev.getResultado())) recomendados++;
        sumaCompatibilidad += ev.getPorcentajeCompatibilidad();
    }
    int promedioCompatibilidad = totalEvaluaciones > 0 ? Math.round((float) sumaCompatibilidad / totalEvaluaciones) : 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Recursos Humanos &amp; Selección Inclusiva | IncluyeLab</title>
    <%@include file="jspf/head.jspf"%>
</head>
<body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard" id="contenido">
    <div class="dashboard-heading">
        <div>
            <p class="eyebrow teal">SISTEMA CORPORATIVO · GESTIÓN DE TALENTO INCLUSIVO</p>
            <h1>Recursos Humanos &amp; Selección</h1>
            <p>Monitoreo integral de postulantes, perfiles de competencias, entrevistas accesibles y dictámenes de compatibilidad.</p>
        </div>
        <div class="d-flex gap-2">
            <button type="button" class="btn primary" onclick="activarTab('formulario'); resetearFormulario();">
                <i data-lucide="plus" aria-hidden="true"></i> Nueva Evaluación
            </button>
        </div>
    </div>

    <% if (request.getParameter("ok") != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="status">
            <i data-lucide="check-circle-2" aria-hidden="true"></i> La evaluación ha sido guardada y sincronizada correctamente en el expediente.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
        </div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i data-lucide="alert-circle" aria-hidden="true"></i> <%=h(request.getAttribute("error"))%>
        </div>
    <% } %>

    <!-- Tarjetas de Métricas Ejecutivas (KPIs) -->
    <div class="metric-grid" style="grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));">
        <div class="metric">
            <i data-lucide="users" aria-hidden="true"></i>
            <div>
                <strong><%=totalCandidatos%></strong>
                <span>Postulantes en Pipeline</span>
            </div>
        </div>
        <div class="metric">
            <i data-lucide="clipboard-check" aria-hidden="true"></i>
            <div>
                <strong><%=totalEvaluaciones%></strong>
                <span>Evaluaciones Realizadas</span>
            </div>
        </div>
        <div class="metric">
            <i data-lucide="award" aria-hidden="true"></i>
            <div>
                <strong><%=recomendados%></strong>
                <span>Candidatos Recomendados</span>
            </div>
        </div>
        <div class="metric">
            <i data-lucide="trending-up" aria-hidden="true"></i>
            <div>
                <strong><%=promedioCompatibilidad%>%</strong>
                <span>Compatibilidad Promedio</span>
            </div>
        </div>
    </div>

    <!-- Navegación por Pestañas Corporativas -->
    <nav class="corp-tabs" role="tablist" aria-label="Secciones de Recursos Humanos">
        <button type="button" class="corp-tab-btn active" id="tab-btn-candidatos" onclick="activarTab('candidatos')" role="tab" aria-selected="true" aria-controls="panel-candidatos">
            <i data-lucide="user-search" aria-hidden="true"></i>
            <span>1. Pipeline de Candidatos</span>
            <span class="tab-badge"><%=totalCandidatos%></span>
        </button>
        <button type="button" class="corp-tab-btn" id="tab-btn-evaluaciones" onclick="activarTab('evaluaciones')" role="tab" aria-selected="false" aria-controls="panel-evaluaciones">
            <i data-lucide="file-check-2" aria-hidden="true"></i>
            <span>2. Historial de Evaluaciones</span>
            <span class="tab-badge"><%=totalEvaluaciones%></span>
        </button>
        <button type="button" class="corp-tab-btn" id="tab-btn-formulario" onclick="activarTab('formulario')" role="tab" aria-selected="false" aria-controls="panel-formulario">
            <i data-lucide="edit-3" aria-hidden="true"></i>
            <span id="tab-form-label">3. Formulario de Evaluación</span>
        </button>
    </nav>

    <!-- PESTAÑA 1: PIPELINE DE CANDIDATOS -->
    <section id="panel-candidatos" role="tabpanel" aria-labelledby="tab-btn-candidatos">
        <div class="section-toolbar">
            <div>
                <h2>Candidatos postulados a las vacantes</h2>
                <p class="muted">Revisa postulaciones reales recibidas en la plataforma, abre su CV y califícalos.</p>
            </div>
            <input class="form-control" type="search" data-table-search="candidatos-table" aria-label="Buscar candidatos" placeholder="Postulante, puesto o empresa">
        </div>
        <div class="table-wrap table-responsive">
            <table class="table table-hover align-middle" id="candidatos-table">
                <thead>
                    <tr>
                        <th scope="col">Candidato</th>
                        <th scope="col">Oferta Laboral / Empresa</th>
                        <th scope="col">Habilidades Clave</th>
                        <th scope="col">Curriculum Vitae</th>
                        <th scope="col">Estado</th>
                        <th scope="col">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Postulacion c : candidatos) { %>
                    <tr>
                        <td>
                            <strong><%=h(c.getPostulante())%></strong><br>
                            <small class="muted"><%=h(c.getCorreo())%></small>
                            <% if (c.getTitular() != null && !c.getTitular().isEmpty()) { %>
                                <br><small class="text-teal font-medium"><%=h(c.getTitular())%></small>
                            <% } %>
                        </td>
                        <td>
                            <strong><%=h(c.getOferta())%></strong><br>
                            <small class="muted"><%=h(c.getEmpresa())%></small><br>
                            <small class="muted" style="font-size:.75rem;"><i data-lucide="calendar" style="width:12px;height:12px;display:inline;"></i> <%=h(c.getFechaPostulacion())%></small>
                        </td>
                        <td>
                            <% if (c.getHabilidades() != null && !c.getHabilidades().isEmpty()) { 
                                for (String h : c.getHabilidades().split(",")) { if (!h.trim().isEmpty()) { %>
                                    <span class="skill-tag"><%=h(h.trim())%></span>
                            <% }}} else { %>
                                <span class="muted" style="font-size:.8rem;">Sin habilidades registradas</span>
                            <% } %>
                        </td>
                        <td>
                            <% if (c.getCvNombre() != null && !c.getCvNombre().isEmpty()) { %>
                                <a class="btn btn-sm" target="_blank" href="<%=request.getContextPath()%>/cv?postulacion=<%=c.getIdPostulacion()%>" title="Abrir CV en PDF">
                                    <i data-lucide="file-text" aria-hidden="true"></i> Abrir CV
                                </a>
                            <% } else { %>
                                <span class="badge" style="background:var(--teal-soft);color:var(--muted);">Sin archivo</span>
                            <% } %>
                        </td>
                        <td>
                            <span class="badge <%="aceptado".equals(c.getEstado()) ? "badge-success" : "rechazado".equals(c.getEstado()) ? "badge-danger" : "badge-warning"%>">
                                <%=h(c.getEstado())%>
                            </span>
                        </td>
                        <td>
                            <div class="table-actions">
                                <button type="button" class="btn btn-sm primary" onclick="iniciarEvaluacion('<%=c.getIdPostulacion()%>', '<%=h(c.getPostulante())%> · <%=h(c.getOferta())%> · <%=h(c.getEmpresa())%>')" title="Calificar a este postulante">
                                    <i data-lucide="user-check" aria-hidden="true"></i> Evaluar
                                </button>
                                <a class="btn btn-sm" href="<%=request.getContextPath()%>/recursos-humanos/candidato?id=<%=c.getIdPostulacion()%>" title="Ver perfil integral y adaptaciones">
                                    <i data-lucide="eye" aria-hidden="true"></i> Perfil
                                </a>
                            </div>
                        </td>
                    </tr>
                <% } %>
                <% if (candidatos.isEmpty()) { %>
                    <tr><td colspan="6" class="text-center py-4 muted">No hay postulantes registrados en este momento.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- PESTAÑA 2: HISTORIAL DE EVALUACIONES -->
    <section id="panel-evaluaciones" style="display:none;" role="tabpanel" aria-labelledby="tab-btn-evaluaciones">
        <div class="section-toolbar">
            <div>
                <h2>Expedientes de evaluación concluidos y en borrador</h2>
                <p class="muted">Resultados de auditoría técnica, puntajes de compatibilidad y retroalimentación emitida.</p>
            </div>
            <input class="form-control" type="search" data-table-search="evaluaciones-table" aria-label="Buscar evaluaciones" placeholder="Candidato, puesto, veredicto o etapa">
        </div>
        <div class="table-wrap table-responsive">
            <table class="table table-hover align-middle" id="evaluaciones-table">
                <thead>
                    <tr>
                        <th scope="col">Candidato / Puesto</th>
                        <th scope="col">Etapa</th>
                        <th scope="col">Puntajes (CV/Entr/Des)</th>
                        <th scope="col">Compatibilidad</th>
                        <th scope="col">Veredicto</th>
                        <th scope="col">Visibilidad</th>
                        <th scope="col">Última Actualización</th>
                        <th scope="col">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                <% for (EvaluacionRRHH e : evaluaciones) { 
                    int compVal = e.getPorcentajeCompatibilidad();
                %>
                    <tr>
                        <td>
                            <strong><%=h(e.getNombrePostulante())%></strong><br>
                            <small class="muted"><%=h(e.getTituloOferta())%> &middot; <%=h(e.getRazonSocialEmpresa())%></small>
                        </td>
                        <td>
                            <span class="badge" style="background:var(--teal-soft);color:var(--ink);font-weight:600;">
                                <%=h(e.getEtapa().replace('_', ' '))%>
                            </span>
                        </td>
                        <td>
                            <div class="score-badge-detail">
                                <span>CV: <strong><%=e.getPuntajeCv()%>%</strong></span> &middot;
                                <span>Entr: <strong><%=e.getPuntajeEntrevista()%>%</strong></span> &middot;
                                <span>Des: <strong><%=e.getPuntajeDesempeno()%>%</strong></span>
                            </div>
                        </td>
                        <td style="min-width:130px;">
                            <div class="d-flex align-items-center gap-2">
                                <strong class="text-teal"><%=compVal%>%</strong>
                                <div class="compat-meter-track flex-grow-1" style="height:6px;margin:0;">
                                    <div class="compat-meter-fill" style="width:<%=compVal%>%;background:<%=compVal >= 75 ? "#18734d" : compVal >= 50 ? "#c3a334" : "#be0066"%>;"></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="badge <%="APROBADO".equals(e.getResultado()) ? "badge-success" : "NO_APROBADO".equals(e.getResultado()) ? "badge-danger" : "badge-warning"%>">
                                <%="APROBADO".equals(e.getResultado()) ? "✓ RECOMENDADO" : "NO_APROBADO".equals(e.getResultado()) ? "✗ NO RECOMENDADO" : "⧖ PENDIENTE"%>
                            </span>
                        </td>
                        <td>
                            <span class="badge" style="background:<%="PUBLICADO".equals(e.getEstado()) ? "rgba(0,118,129,0.12)" : "rgba(100,100,100,0.12)"%>;color:var(--ink);">
                                <%=h(e.getEstado())%>
                            </span>
                        </td>
                        <td>
                            <small class="muted"><%=h(e.getFechaActualizacionTexto())%></small>
                        </td>
                        <td>
                            <div class="table-actions">
                                <button type="button" class="icon-btn" title="Editar evaluación" aria-label="Editar evaluación #<%=e.getIdEvaluacion()%>" 
                                    onclick="cargarParaEditar('<%=e.getIdEvaluacion()%>', '<%=e.getIdPostulacion()%>', '<%=e.getEtapa()%>', '<%=e.getResultado()%>', '<%=e.getEstado()%>', '<%=e.getPuntajeCv()%>', '<%=e.getPuntajeEntrevista()%>', '<%=e.getPuntajeDesempeno()%>', '<%=e.getPorcentajeCompatibilidad()%>', '<%=h(e.getObservaciones()).replace("'", "\\'").replace("\n", "\\n").replace("\r", "")%>', '<%=h(e.getRetroalimentacion()).replace("'", "\\'").replace("\n", "\\n").replace("\r", "")%>')">
                                    <i data-lucide="pencil" aria-hidden="true"></i>
                                </button>
                                <% if ("BORRADOR".equals(e.getEstado())) { %>
                                    <form method="post" action="<%=request.getContextPath()%>/recursos-humanos" style="display:inline;" onsubmit="return confirm('¿Seguro que deseas eliminar este borrador de evaluación?');">
                                        <input type="hidden" name="csrf" value="<%=h(session.getAttribute("rrhhCsrf"))%>">
                                        <input type="hidden" name="accion" value="eliminar">
                                        <input type="hidden" name="id" value="<%=e.getIdEvaluacion()%>">
                                        <button type="submit" class="icon-btn danger-action" title="Eliminar borrador" aria-label="Eliminar evaluación #<%=e.getIdEvaluacion()%>">
                                            <i data-lucide="trash-2" aria-hidden="true"></i>
                                        </button>
                                    </form>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <% } %>
                <% if (evaluaciones.isEmpty()) { %>
                    <tr><td colspan="8" class="text-center py-4 muted">No hay expedientes de evaluación registrados todavía.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- PESTAÑA 3: FORMULARIO CORPORATIVO DE EVALUACIÓN -->
    <section id="panel-formulario" style="display:none;" role="tabpanel" aria-labelledby="tab-btn-formulario">
        <div class="profile-section" style="max-width:960px;margin:0 auto;">
            <div class="section-toolbar" style="margin-bottom:20px;border-bottom:1px solid var(--line);padding-bottom:12px;">
                <div>
                    <h2 id="form-titulo">Nueva evaluación de candidato</h2>
                    <p class="muted" id="form-subtitulo">Completa el análisis de competencias, puntajes por etapa y dictamen técnico inclusivo.</p>
                </div>
                <button type="button" class="btn btn-sm" onclick="resetearFormulario()">
                    <i data-lucide="rotate-ccw" aria-hidden="true"></i> Limpiar Formulario
                </button>
            </div>

            <form method="post" action="<%=request.getContextPath()%>/recursos-humanos" id="eval-form" class="row g-3">
                <input type="hidden" name="csrf" value="<%=h(session.getAttribute("rrhhCsrf"))%>">
                <input type="hidden" name="id" id="eval-id" value="0">
                <input type="hidden" name="accion" value="guardar">

                <!-- 1. Datos Generales de la Postulación -->
                <div class="col-md-6 field">
                    <label class="form-label" for="postulacion">Postulante y Oferta Laboral <span class="text-danger">*</span></label>
                    <select class="form-select" name="postulacion" id="postulacion" required>
                        <option value="">-- Selecciona el candidato a evaluar --</option>
                        <% for (Postulacion c : candidatos) { %>
                            <option value="<%=c.getIdPostulacion()%>"><%=h(c.getPostulante())%> &middot; <%=h(c.getOferta())%> (<%=h(c.getEmpresa())%>)</option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-6 field">
                    <label class="form-label" for="etapa">Etapa Actual del Proceso <span class="text-danger">*</span></label>
                    <select class="form-select" name="etapa" id="etapa" required>
                        <option value="REVISION_CV">1. Revisión y Filtro de CV</option>
                        <option value="ENTREVISTA">2. Entrevista por Competencias</option>
                        <option value="DESEMPENO">3. Evaluación Técnica / Desempeño</option>
                        <option value="FINAL">4. Decisión Final de Contratación</option>
                    </select>
                </div>

                <!-- 2. Tarjeta Interactiva de Puntajes y Compatibilidad en Vivo -->
                <div class="col-12">
                    <div class="compat-score-box">
                        <div class="compat-score-header">
                            <div>
                                <strong>Ponderación y Compatibilidad con el Perfil</strong>
                                <p class="muted font-sm mb-0">Ingresa los porcentajes individuales (0-100%). La compatibilidad total se actualiza en tiempo real.</p>
                            </div>
                            <div class="text-end">
                                <span class="compat-val-badge" id="compat-display">0%</span>
                            </div>
                        </div>

                        <!-- Barra de Compatibilidad Dinámica -->
                        <div class="compat-meter-track">
                            <div class="compat-meter-fill" id="compat-bar" style="width:0%;"></div>
                        </div>
                        <div class="compat-suggestion" id="compat-suggestion">
                            <i data-lucide="info" style="width:15px;height:15px;"></i> Ingresa los valores para generar el diagnóstico sugerido.
                        </div>

                        <!-- 3 Columnas de Puntajes -->
                        <div class="row g-3 mt-2">
                            <div class="col-md-3 field">
                                <label class="form-label font-sm" for="puntajeCv">CV &amp; Formación (%)</label>
                                <input class="form-control" type="number" min="0" max="100" name="puntajeCv" id="puntajeCv" value="0" required oninput="calcularCompatibilidad()">
                            </div>
                            <div class="col-md-3 field">
                                <label class="form-label font-sm" for="puntajeEntrevista">Entrevista Accesible (%)</label>
                                <input class="form-control" type="number" min="0" max="100" name="puntajeEntrevista" id="puntajeEntrevista" value="0" required oninput="calcularCompatibilidad()">
                            </div>
                            <div class="col-md-3 field">
                                <label class="form-label font-sm" for="puntajeDesempeno">Desempeño / Práctico (%)</label>
                                <input class="form-control" type="number" min="0" max="100" name="puntajeDesempeno" id="puntajeDesempeno" value="0" required oninput="calcularCompatibilidad()">
                            </div>
                            <div class="col-md-3 field">
                                <label class="form-label font-sm" for="compatibilidad">Compatibilidad Total (%)</label>
                                <input class="form-control" type="number" min="0" max="100" name="compatibilidad" id="compatibilidad" value="0" required>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 3. Veredicto y Visibilidad -->
                <div class="col-md-6 field">
                    <label class="form-label" for="resultado">Veredicto de Selección <span class="text-danger">*</span></label>
                    <select class="form-select" name="resultado" id="resultado" required>
                        <option value="PENDIENTE">⧖ En Evaluación / Pendiente</option>
                        <option value="APROBADO">✓ Recomendado para la Posición</option>
                        <option value="NO_APROBADO">✗ No Recomendado</option>
                    </select>
                </div>

                <div class="col-md-6 field">
                    <label class="form-label" for="estado">Visibilidad del Dictamen <span class="text-danger">*</span></label>
                    <select class="form-select" name="estado" id="estado" required>
                        <option value="BORRADOR">Borrador privado (Solo equipo evaluador)</option>
                        <option value="PUBLICADO">Publicado (Visible para la empresa contratante)</option>
                    </select>
                </div>

                <!-- 4. Texto de Análisis y Retroalimentación -->
                <div class="col-12 field">
                    <label class="form-label" for="observaciones">Análisis Técnico y Observaciones de Selección <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="observaciones" id="observaciones" maxlength="4000" rows="4" placeholder="Detalla las fortalezas observadas, adecuación a las tareas del puesto y pertinencia de adaptaciones..." required></textarea>
                </div>

                <div class="col-12 field">
                    <label class="form-label" for="retroalimentacion">Retroalimentación Inclusiva y Mejoras Sugeridas</label>
                    <textarea class="form-control" name="retroalimentacion" id="retroalimentacion" maxlength="4000" rows="3" placeholder="Recomendaciones constructivas para el postulante o adaptaciones requeridas para su puesto de trabajo..."></textarea>
                </div>

                <div class="col-12 d-flex gap-3 pt-3">
                    <button class="btn primary flex-grow-1" type="submit" id="btn-submit-eval">
                        <i data-lucide="save" aria-hidden="true"></i> Guardar Evaluación
                    </button>
                    <button type="button" class="btn" onclick="activarTab('candidatos')">
                        Cancelar
                    </button>
                </div>
            </form>
        </div>
    </section>
<% if("RECURSOS_HUMANOS".equals(usuario.getRol())){ java.util.List<com.incluyelab.model.VerificacionConadis> solicitudes=(java.util.List<com.incluyelab.model.VerificacionConadis>)request.getAttribute("verificacionesConadis");if(solicitudes==null)solicitudes=java.util.Collections.emptyList(); %>
<section class="section" id="conadis"><div class="section-toolbar"><div><h2>Verificaciones CONADIS</h2><p class="muted">Revisión manual de solicitudes. La aprobación no afirma una consulta oficial en línea.</p></div></div>
<form method="get" action="<%=request.getContextPath()%>/recursos-humanos#conadis" class="row g-2 mb-3">
<div class="col-md-4"><label for="estadoConadis">Estado</label><select class="form-select" id="estadoConadis" name="estadoConadis"><option value="">Todos</option><% for(String estadoFiltro:new String[]{"PENDIENTE","APROBADA","RECHAZADA","VENCIDA"}){ %><option value="<%=estadoFiltro%>" <%=estadoFiltro.equals(request.getParameter("estadoConadis"))?"selected":""%>><%=estadoFiltro%></option><% } %></select></div>
<div class="col-md-6"><label for="buscarConadis">Nombre, correo, DNI o RUI</label><input class="form-control" id="buscarConadis" name="buscarConadis" maxlength="120" value="<%=h(request.getParameter("buscarConadis"))%>"></div>
<div class="col-md-2 d-flex align-items-end"><button class="btn primary w-100" type="submit">Buscar</button></div></form>
<div class="table-wrap table-responsive"><table class="table table-hover align-middle"><thead><tr><th>Postulante</th><th>RUI</th><th>Documento</th><th>Estado</th><th>Solicitud</th><th>Última revisión</th><th>Acción</th></tr></thead><tbody>
<% for(com.incluyelab.model.VerificacionConadis solicitud:solicitudes){ %><tr><td><strong><%=h(solicitud.getNombreCuenta())%></strong><br><small class="muted"><%=h(solicitud.getCorreoCuenta())%></small></td><td>RD<%=h(solicitud.getRui())%></td><td><%=h(solicitud.getDni())%></td><td><span class="badge"><%=h(solicitud.getEstadoEfectivo())%></span></td><td><%=solicitud.getFechaEnvio()==null?"":solicitud.getFechaEnvio().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))%></td><td><%=solicitud.getFechaRevision()==null?"Sin revisar":h(solicitud.getNombreRevisor())+" · "+solicitud.getFechaRevision().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))%></td><td><a class="btn" href="<%=request.getContextPath()%>/revision-conadis?id=<%=solicitud.getIdUsuario()%>"><i data-lucide="clipboard-check" aria-hidden="true"></i> <%="PENDIENTE".equals(solicitud.getEstado())?"Revisar":"Consultar"%></a></td></tr><% } %>
<% if(solicitudes.isEmpty()){ %><tr><td colspan="7">No hay verificaciones que coincidan con los filtros.</td></tr><% } %></tbody></table></div></section><% } %></main>

<script>
    function activarTab(tabId) {
        document.getElementById('panel-candidatos').style.display = tabId === 'candidatos' ? 'block' : 'none';
        document.getElementById('panel-evaluaciones').style.display = tabId === 'evaluaciones' ? 'block' : 'none';
        document.getElementById('panel-formulario').style.display = tabId === 'formulario' ? 'block' : 'none';

        document.getElementById('tab-btn-candidatos').classList.toggle('active', tabId === 'candidatos');
        document.getElementById('tab-btn-evaluaciones').classList.toggle('active', tabId === 'evaluaciones');
        document.getElementById('tab-btn-formulario').classList.toggle('active', tabId === 'formulario');

        document.getElementById('tab-btn-candidatos').setAttribute('aria-selected', tabId === 'candidatos');
        document.getElementById('tab-btn-evaluaciones').setAttribute('aria-selected', tabId === 'evaluaciones');
        document.getElementById('tab-btn-formulario').setAttribute('aria-selected', tabId === 'formulario');

        window.scrollTo({ top: 180, behavior: 'smooth' });
    }

    function calcularCompatibilidad() {
        var cv = parseInt(document.getElementById('puntajeCv').value) || 0;
        var ent = parseInt(document.getElementById('puntajeEntrevista').value) || 0;
        var des = parseInt(document.getElementById('puntajeDesempeno').value) || 0;
        
        cv = Math.max(0, Math.min(100, cv));
        ent = Math.max(0, Math.min(100, ent));
        des = Math.max(0, Math.min(100, des));

        var comp = Math.round((cv + ent + des) / 3);
        document.getElementById('compatibilidad').value = comp;
        document.getElementById('compat-display').textContent = comp + '%';

        var bar = document.getElementById('compat-bar');
        bar.style.width = comp + '%';

        var sug = document.getElementById('compat-suggestion');
        var res = document.getElementById('resultado');

        if (comp >= 75) {
            bar.style.backgroundColor = '#18734d';
            sug.innerHTML = '<span style="color:#18734d;">✓ Compatibilidad óptima (' + comp + '%): Se sugiere "Recomendado para la Posición".</span>';
            if (res.value === 'PENDIENTE') res.value = 'APROBADO';
        } else if (comp >= 50) {
            bar.style.backgroundColor = '#c3a334';
            sug.innerHTML = '<span style="color:#c3a334;">⧖ Compatibilidad media (' + comp + '%): Revisar detalles antes de emitir veredicto final.</span>';
        } else {
            bar.style.backgroundColor = '#be0066';
            sug.innerHTML = '<span style="color:#be0066;">✗ Compatibilidad baja (' + comp + '%): Se sugiere reforzar competencias o evaluar otra oferta.</span>';
        }
    }

    function iniciarEvaluacion(idPostulacion, labelCandidato) {
        resetearFormulario();
        var sel = document.getElementById('postulacion');
        sel.value = idPostulacion;
        document.getElementById('form-titulo').textContent = 'Evaluar Candidato: ' + labelCandidato;
        document.getElementById('form-subtitulo').textContent = 'Registrando evaluación directa para la postulación #' + idPostulacion;
        activarTab('formulario');
        document.getElementById('etapa').focus();
    }

    function cargarParaEditar(id, postulacion, etapa, resultado, estado, cv, ent, des, comp, obs, retro) {
        document.getElementById('eval-id').value = id;
        document.getElementById('postulacion').value = postulacion;
        document.getElementById('etapa').value = etapa;
        document.getElementById('resultado').value = resultado;
        document.getElementById('estado').value = estado;
        document.getElementById('puntajeCv').value = cv;
        document.getElementById('puntajeEntrevista').value = ent;
        document.getElementById('puntajeDesempeno').value = des;
        document.getElementById('compatibilidad').value = comp;
        document.getElementById('observaciones').value = obs;
        document.getElementById('retroalimentacion').value = retro;

        document.getElementById('form-titulo').textContent = 'Editar Evaluación #' + id;
        document.getElementById('form-subtitulo').textContent = 'Modificando dictamen registrado en el sistema.';
        document.getElementById('tab-form-label').textContent = 'Editar Evaluación #' + id;
        document.getElementById('btn-submit-eval').innerHTML = '<i data-lucide="check" aria-hidden="true"></i> Actualizar Evaluación';

        calcularCompatibilidad();
        activarTab('formulario');
        if (window.lucide) lucide.createIcons();
    }

    function resetearFormulario() {
        document.getElementById('eval-form').reset();
        document.getElementById('eval-id').value = '0';
        document.getElementById('form-titulo').textContent = 'Nueva evaluación de candidato';
        document.getElementById('form-subtitulo').textContent = 'Completa el análisis de competencias, puntajes por etapa y dictamen técnico inclusivo.';
        document.getElementById('tab-form-label').textContent = '3. Formulario de Evaluación';
        document.getElementById('btn-submit-eval').innerHTML = '<i data-lucide="save" aria-hidden="true"></i> Guardar Evaluación';
        calcularCompatibilidad();
        if (window.lucide) lucide.createIcons();
    }
</script>

<%@include file="jspf/footer.jspf"%>
</body>
</html>
