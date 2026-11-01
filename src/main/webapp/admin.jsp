<%@page import="java.util.List,java.util.ArrayList,java.util.Collections,com.incluyelab.model.Postulacion,com.incluyelab.model.Oferta,com.incluyelab.model.Empresa,com.incluyelab.model.Usuario,com.incluyelab.model.EvaluacionRRHH,com.incluyelab.model.IncidenciaSoporte"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="WEB-INF/jspf/helpers.jspf"%>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getRol())) { response.sendRedirect(request.getContextPath()+"/login"); return; }
    if (request.getAttribute("usuarios") == null && request.getAttribute("error") == null) { response.sendRedirect(request.getContextPath()+"/admin"); return; }
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    List<Empresa> empresas = (List<Empresa>) request.getAttribute("empresas");
    List<Oferta> ofertas = (List<Oferta>) request.getAttribute("ofertas");
    List<Postulacion> postulaciones = (List<Postulacion>) request.getAttribute("postulaciones");
    List<EvaluacionRRHH> evaluacionesRRHH = (List<EvaluacionRRHH>) request.getAttribute("evaluacionesRRHH");
    List<IncidenciaSoporte> incidenciasSoporte = (List<IncidenciaSoporte>) request.getAttribute("incidenciasSoporte");

    if (usuarios == null) usuarios = Collections.emptyList();
    if (empresas == null) empresas = Collections.emptyList();
    if (ofertas == null) ofertas = Collections.emptyList();
    if (postulaciones == null) postulaciones = Collections.emptyList();
    if (evaluacionesRRHH == null) evaluacionesRRHH = Collections.emptyList();
    if (incidenciasSoporte == null) incidenciasSoporte = Collections.emptyList();

    List<Usuario> usuariosPersonales = new ArrayList<Usuario>();
    for (Usuario cuenta : usuarios) {
        if (!"EMPRESA".equals(cuenta.getRol())) usuariosPersonales.add(cuenta);
    }
%>
<!DOCTYPE html><html lang="es"><head><title>Administración General | IncluyeLab</title><%@include file="WEB-INF/jspf/head.jspf"%></head><body>
<%@include file="WEB-INF/jspf/header.jspf"%>
<main class="container dashboard" id="contenido">
    <div class="dashboard-heading">
        <div>
            <p class="eyebrow teal">PANEL PRINCIPAL · ADMINISTRACIÓN GENERAL</p>
            <h1>Gestión integral de la plataforma</h1>
            <p>Bienvenido, <%=h(usuario.getNombre())%>. Administra cuentas internas y consulta la auditor&iacute;a general sin intervenir en operaciones de otros roles.</p>
        </div>
        <a class="btn" href="<%=request.getContextPath()%>/inicio">Ver portal <i data-lucide="arrow-up-right" aria-hidden="true"></i></a>
    </div>

    <!-- Navegación por los 5 CRUDs Principales + CONADIS -->
    <nav class="dashboard-nav" aria-label="Secciones del panel">
        <a href="#usuarios">1. Usuarios (<%=usuariosPersonales.size()%>)</a>
        <a href="#empresas">2. Empresas (<%=empresas.size()%>)</a>
        <a href="#ofertas">3. Ofertas (<%=ofertas.size()%>)</a>
        <a href="#recursos-humanos">4. Recursos Humanos (<%=evaluacionesRRHH.size()%>)</a>
        <a href="#soporte">5. Soporte e Incidencias (<%=incidenciasSoporte.size()%>)</a>
        <a href="#postulaciones">Postulaciones (<%=postulaciones.size()%>)</a>
    </nav>

    <% if (request.getAttribute("error") != null) { %><div class="error" role="alert">No se pudo cargar toda la información del panel.</div><% } %>
    <% if (session.getAttribute("adminNotice") != null) { %><div class="alert alert-success alert-dismissible fade show notice" role="status"><%=h(session.getAttribute("adminNotice"))%><button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar aviso"></button></div><% session.removeAttribute("adminNotice"); } %>

    <!-- Cuadrícula de Métricas Globales de los 5 Módulos -->
    <div class="metric-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));">
        <div class="metric"><i data-lucide="users" aria-hidden="true"></i><div><strong><%=usuariosPersonales.size()%></strong><span>1. Usuarios</span></div></div>
        <div class="metric"><i data-lucide="building-2" aria-hidden="true"></i><div><strong><%=empresas.size()%></strong><span>2. Empresas</span></div></div>
        <div class="metric"><i data-lucide="briefcase-business" aria-hidden="true"></i><div><strong><%=ofertas.size()%></strong><span>3. Ofertas</span></div></div>
        <div class="metric"><i data-lucide="user-check" aria-hidden="true"></i><div><strong><%=evaluacionesRRHH.size()%></strong><span>4. Evaluaciones RRHH</span></div></div>
        <div class="metric"><i data-lucide="wrench" aria-hidden="true"></i><div><strong><%=incidenciasSoporte.size()%></strong><span>5. Incidencias</span></div></div>
    </div>
    <section class="section" id="usuarios"><div class="section-toolbar"><div><h2>Usuarios registrados</h2><p class="muted">Crea cuentas internas y activa o desactiva cuentas existentes.</p></div><a class="btn primary" href="<%=request.getContextPath()%>/admin?entidad=usuarios&amp;accion=nuevo"><i data-lucide="plus" aria-hidden="true"></i> Crear cuenta interna</a><input class="form-control" type="search" data-table-search="users-table" aria-label="Buscar usuarios" placeholder="Nombre, correo o rol"></div><div class="table-wrap table-responsive"><table class="table table-hover align-middle" id="users-table"><thead><tr><th scope="col">ID</th><th scope="col">Nombre</th><th scope="col">Correo</th><th scope="col">Rol</th><th scope="col">Estado</th><th scope="col">Cuenta</th></tr></thead><tbody><% for (Usuario u : usuariosPersonales) { String rolVisible="RECURSOS_HUMANOS".equals(u.getRol())?"Recursos Humanos":"SOPORTE_TECNICO".equals(u.getRol())?"Soporte T&eacute;cnico":"POSTULANTE".equals(u.getRol())?"Postulante":"Administrador Central"; %><tr><td><%=u.getIdUsuario()%></td><td><strong><%=h(u.getNombre())%></strong></td><td><%=h(u.getCorreo())%></td><td><%=rolVisible%></td><td><span class="badge"><%=h(u.getEstado())%></span></td><td><div class="table-actions"><a class="icon-btn" title="Gestionar cuenta" aria-label="Gestionar usuario #<%=u.getIdUsuario()%>" href="<%=request.getContextPath()%>/admin?entidad=usuarios&amp;accion=editar&amp;id=<%=u.getIdUsuario()%>"><i data-lucide="user-cog" aria-hidden="true"></i></a><% if("activo".equals(u.getEstado())&&u.getIdUsuario()!=usuario.getIdUsuario()){ %><form method="post" action="<%=request.getContextPath()%>/admin" onsubmit="return confirm('¿Desactivar esta cuenta conservando su historial?');"><input type="hidden" name="csrf" value="<%=h(session.getAttribute("adminCsrf"))%>"><input type="hidden" name="entidad" value="usuarios"><input type="hidden" name="accion" value="dar_baja"><input type="hidden" name="id" value="<%=u.getIdUsuario()%>"><button class="icon-btn danger-action" type="submit" title="Dar de baja" aria-label="Dar de baja a <%=h(u.getNombre())%>"><i data-lucide="user-x"></i></button></form><% } %></div></td></tr><% } %><% if(usuariosPersonales.isEmpty()){ %><tr><td colspan="6">No hay usuarios personales registrados.</td></tr><% } %></tbody></table></div></section>
    
    <section class="section" id="empresas"><div class="section-toolbar"><div><h2>Empresas registradas</h2><p class="muted">Cuentas empresariales y estado de su solicitud.</p></div><input class="form-control" type="search" data-table-search="companies-table" aria-label="Buscar empresas" placeholder="Empresa, correo, sector o estado"></div>
    <div class="table-wrap table-responsive"><table class="table table-hover align-middle" id="companies-table"><thead><tr><th>Empresa</th><th>Correo de acceso</th><th>RUC</th><th>Sector</th><th>Cuenta</th><th>Aprobación</th><th>Ficha</th></tr></thead><tbody>
    <% for(Empresa e:empresas){ %><tr><td><div class="company-identity"><% if(!e.getLogoPublico().isEmpty()){ %><span class="logo-box"><img src="<%=request.getContextPath()%>/<%=h(e.getLogoPublico())%>" alt=""></span><% } %><strong><%=h(e.getRazonSocial())%></strong></div></td><td><%=h(e.getCorreoCuenta())%></td><td><%=h(e.getRuc())%></td><td><%=h(e.getSector())%></td><td><span class="badge"><%=h(e.getEstadoCuenta())%></span></td><td><span class="badge"><%=h(e.getEstadoRevision())%></span></td><td><a class="btn" href="<%=request.getContextPath()%>/revision-empresa?id=<%=e.getIdEmpresa()%>"><i data-lucide="clipboard-check" aria-hidden="true"></i> <%="pendiente".equals(e.getEstadoRevision())?"Revisar":"Ver ficha"%></a></td></tr><% } %>
    <% if(empresas.isEmpty()){ %><tr><td colspan="7">Aún no hay empresas registradas.</td></tr><% } %>
    </tbody></table></div></section>
    <section class="section" id="ofertas">
        <div class="section-toolbar">
            <div>
                <h2>3. Ofertas laborales</h2>
                <p class="muted">Ofertas publicadas y administradas por cada empresa.</p>
            </div>
            <input class="form-control" type="search" data-table-search="offers-table" aria-label="Buscar ofertas" placeholder="Puesto, empresa o modalidad">
        </div>
        <div class="table-wrap table-responsive">
            <table class="table table-hover align-middle" id="offers-table">
                <thead>
                    <tr>
                        <th scope="col">ID</th>
                        <th scope="col">Empresa</th>
                        <th scope="col">Puesto</th>
                        <th scope="col">Modalidad</th>
                        <th scope="col">Salario</th>
                        <th scope="col">Adaptaciones</th>
                        <th scope="col">Estado</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Oferta o : ofertas) { %>
                    <tr>
                        <td><%=o.getIdOferta()%></td>
                        <td><%=h(o.getEmpresa())%></td>
                        <td><strong><%=h(o.getTitulo())%></strong></td>
                        <td><%=h(o.getModalidad())%></td>
                        <td>S/ <%=o.getSalario()%></td>
                        <td><small><%=h(o.getAdaptaciones())%></small></td>
                        <td><span class="badge <%="activa".equalsIgnoreCase(o.getEstado()) ? "badge-success" : "badge-secondary"%>"><%=h(o.getEstado())%></span></td>
                    </tr>
                <% } %>
                <% if (ofertas.isEmpty()) { %>
                    <tr><td colspan="7">No hay ofertas registradas.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
    <section class="section" id="recursos-humanos">
        <div class="section-toolbar">
            <div>
                <h2>4. Módulo de Recursos Humanos (Evaluaciones de Selección)</h2>
                <p class="muted">Supervisión administrativa de veredictos, puntajes y compatibilidad de candidatos.</p>
            </div>
        </div>
        <div class="table-wrap table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>Candidato</th>
                        <th>Oferta / Empresa</th>
                        <th>Etapa</th>
                        <th>Puntajes (CV/Entr/Des)</th>
                        <th>Compatibilidad</th>
                        <th>Veredicto</th>
                        <th>Estado</th>
                        <th>Evaluador</th>
                    </tr>
                </thead>
                <tbody>
                <% for (EvaluacionRRHH ev : evaluacionesRRHH) { %>
                    <tr>
                        <td><strong><%=h(ev.getNombrePostulante())%></strong></td>
                        <td><%=h(ev.getTituloOferta())%><br><small class="muted"><%=h(ev.getRazonSocialEmpresa())%></small></td>
                        <td><span class="badge"><%=h(ev.getEtapa())%></span></td>
                        <td><%=ev.getPuntajeCv()%> / <%=ev.getPuntajeEntrevista()%> / <%=ev.getPuntajeDesempeno()%></td>
                        <td><strong><%=ev.getPorcentajeCompatibilidad()%>%</strong></td>
                        <td><span class="badge <%="APROBADO".equals(ev.getResultado()) ? "badge-success" : "NO_APROBADO".equals(ev.getResultado()) ? "badge-danger" : "badge-warning"%>"><%=h(ev.getResultado())%></span></td>
                        <td><span class="badge"><%=h(ev.getEstado())%></span></td>
                        <td><small><%=h(ev.getNombreEvaluador())%></small></td>
                    </tr>
                <% } %>
                <% if (evaluacionesRRHH.isEmpty()) { %>
                    <tr><td colspan="8">No hay evaluaciones registradas en el sistema.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <section class="section" id="soporte">
        <div class="section-toolbar">
            <div>
                <h2>5. Módulo de Soporte Técnico y Seguridad (Incidencias)</h2>
                <p class="muted">Gestión de tickets técnicos, recuperación de cuentas y reportes de seguridad.</p>
            </div>
        </div>
        <div class="table-wrap table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Título / Categoría</th>
                        <th>Correo Afectado</th>
                        <th>Prioridad</th>
                        <th>Decisión</th>
                        <th>Estado</th>
                        <th>Responsable</th>
                        <th>Fecha</th>
                    </tr>
                </thead>
                <tbody>
                <% for (IncidenciaSoporte inc : incidenciasSoporte) { %>
                    <tr>
                        <td>#<%=inc.getIdIncidencia()%></td>
                        <td><strong><%=h(inc.getTitulo())%></strong><br><small class="badge"><%=h(inc.getCategoria())%></small></td>
                        <td><%=h(inc.getCorreo())%></td>
                        <td><span class="badge <%= ("URGENTE".equals(inc.getPrioridad())||"ALTA".equals(inc.getPrioridad())) ? "badge-danger" : "badge-warning" %>"><%=h(inc.getPrioridad())%></span></td>
                        <td><span class="badge"><%=h(inc.getDecision())%></span></td>
                        <td><span class="badge <%="RESUELTA".equals(inc.getEstado())?"badge-success":"badge-warning"%>"><%=h(inc.getEstado())%></span></td>
                        <td><small><%=h(inc.getNombreResponsable())%></small></td>
                        <td><small class="muted"><%=h(inc.getFechaCreacionTexto())%></small></td>
                    </tr>
                <% } %>
                <% if (incidenciasSoporte.isEmpty()) { %>
                    <tr><td colspan="8">No hay incidencias técnicas ni reportes registrados.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <section class="section" id="postulaciones">
        <div class="section-toolbar">
            <div>
                <h2>Postulaciones a ofertas</h2>
                <p class="muted">Solicitudes presentadas por los postulantes a las empresas.</p>
            </div>
            <input class="form-control" type="search" data-table-search="applications-table" aria-label="Buscar postulaciones" placeholder="Postulante, empresa o estado">
        </div>
        <div class="table-wrap table-responsive">
            <table class="table table-hover align-middle" id="applications-table">
                <thead>
                    <tr>
                        <th scope="col">ID</th>
                        <th scope="col">Postulante</th>
                        <th scope="col">Oferta</th>
                        <th scope="col">Empresa</th>
                        <th scope="col">Estado</th>
                        <th scope="col">Fecha</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Postulacion p : postulaciones) { %>
                    <tr>
                        <td><%=p.getIdPostulacion()%></td>
                        <td><strong><%=h(p.getPostulante())%></strong></td>
                        <td><%=h(p.getOferta())%></td>
                        <td><%=h(p.getEmpresa())%></td>
                        <td><span class="badge"><%=h(p.getEstado())%></span></td>
                        <td><%=h(p.getFechaPostulacion())%></td>
                    </tr>
                <% } %>
                <% if (postulaciones.isEmpty()) { %>
                    <tr><td colspan="6">No hay postulaciones registradas.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main><%@include file="WEB-INF/jspf/footer.jspf"%></body></html>
