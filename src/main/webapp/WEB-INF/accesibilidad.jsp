<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List,com.incluyelab.model.NecesidadesAccesibilidad.Necesidad"%>
<%@include file="jspf/helpers.jspf"%>
<% List<Necesidad> necesidadesAccesibilidad = (List<Necesidad>) request.getAttribute("necesidadesAccesibilidad"); %>
<!DOCTYPE html>
<html lang="es">
<head><title>Accesibilidad | IncluyeLab</title><%@include file="jspf/head.jspf"%></head>
<body>
<%@include file="jspf/header.jspf"%>
<main class="container accessibility-page" id="contenido">
    <div class="accessibility-intro">
        <p class="eyebrow teal">TALENTO SIN BARRERAS</p>
        <h1>Accesibilidad en IncluyeLab</h1>
        <p>Estas son las 13 necesidades contempladas por el proyecto. Por ahora está disponible la ayuda visual: lectura por voz, navegación por flechas, alto contraste y texto grande, desde la barra superior.</p>
        <p class="muted">Las demás funciones de la tabla están planificadas. La lectura por voz utiliza la voz disponible en tu navegador; puedes detenerla en cualquier momento.</p>
    </div>
    <section aria-labelledby="catalogo-accesibilidad">
        <h2 id="catalogo-accesibilidad">Discapacidades y necesidades de accesibilidad</h2>
        <p id="catalogo-ayuda">En pantallas pequeñas, desplaza la tabla horizontalmente para consultar todas las columnas.</p>
        <div class="accessibility-table-wrap" role="region" aria-labelledby="catalogo-accesibilidad" aria-describedby="catalogo-ayuda" tabindex="0">
            <table class="accessibility-catalog">
                <caption>Alcance y estado de las funcionalidades de accesibilidad</caption>
                <thead><tr><th scope="col">N.º</th><th scope="col">Discapacidad o necesidad</th><th scope="col">Funcionalidades</th><th scope="col">¿Cómo implementarlo?</th><th scope="col">Estado</th></tr></thead>
                <tbody>
                <% int numeroNecesidad = 0; for (Necesidad necesidad : necesidadesAccesibilidad) { %>
                    <tr data-necesidad="<%=h(necesidad.getCodigo())%>">
                        <td><%=++numeroNecesidad%></td>
                        <th scope="row"><%=h(necesidad.getNombre())%></th>
                        <td><%=h(necesidad.getFunciones())%></td>
                        <td><%=h(necesidad.getImplementacion())%></td>
                        <td class="accessibility-state"><span class="badge"><%=h(necesidad.getEstado())%></span></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
    <p>La selección de múltiples necesidades para personalizar la navegación y ampliar los filtros de empleo está prevista para una siguiente etapa. Los apoyos laborales que ya declaran las empresas siguen disponibles en el buscador.</p>
    <p class="muted">No necesitas declarar un diagnóstico para utilizar la ayuda visual.</p>
    <a class="btn primary" href="<%=request.getContextPath()%>/inicio#ofertas">Explorar empleos</a>
</main>
<%@include file="jspf/footer.jspf"%>
</body>
</html>
