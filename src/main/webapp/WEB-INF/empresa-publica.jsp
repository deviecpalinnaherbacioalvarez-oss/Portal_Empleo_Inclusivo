<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.incluyelab.model.Empresa,com.incluyelab.model.Oferta,java.util.List,java.util.Collections"%>
<%@include file="jspf/helpers.jspf"%>
<% Empresa ficha=(Empresa)request.getAttribute("ficha"); List<Oferta> ofertas=(List<Oferta>)request.getAttribute("ofertasEmpresa"); if(ofertas==null)ofertas=Collections.emptyList(); %>
<!DOCTYPE html><html lang="es"><head><title><%=h(ficha.getRazonSocial())%> | IncluyeLab</title><%@include file="jspf/head.jspf"%></head><body>
<%@include file="jspf/header.jspf"%>
<main class="container dashboard admin-editor" id="contenido">
<a class="text-link" href="<%=request.getContextPath()%>/inicio#empresas"><i data-lucide="arrow-left" aria-hidden="true"></i> Volver al directorio</a>
<%@include file="jspf/empresa-detalle.jspf"%>
<p class="muted">Información declarada por la empresa. La aprobación del portal no constituye una certificación de accesibilidad ni acredita representación oficial de la marca.</p>
<div class="editor-actions"><a class="btn primary" href="<%=request.getContextPath()%>/inicio?empresa=<%=ficha.getIdEmpresa()%>#ofertas"><i data-lucide="briefcase-business" aria-hidden="true"></i> Ver <%=ficha.getTotalOfertas()%> ofertas</a>
<% if(!ficha.getSitioOficial().isEmpty()){ %><a class="btn" href="<%=h(ficha.getSitioOficial())%>" target="_blank" rel="noopener noreferrer">Sitio oficial <i data-lucide="external-link" aria-hidden="true"></i></a><% } %></div>
<section class="jobs-section" aria-labelledby="company-offers"><div class="section-heading"><div><p class="eyebrow teal">OPORTUNIDADES PUBLICADAS</p><h2 id="company-offers">Ofertas de <%=h(ficha.getRazonSocial())%></h2></div></div><div class="offer-grid"><% for(Oferta oferta:ofertas){ %><article class="offer-card"><h3><a class="text-link" href="<%=request.getContextPath()%>/inicio?oferta=<%=oferta.getIdOferta()%>#ofertas"><%=h(oferta.getTitulo())%></a></h3><p class="offer-location"><i data-lucide="map-pin" aria-hidden="true"></i><%=h(oferta.getUbicacion())%></p><div class="tags"><span class="badge"><%=h(oferta.getModalidad())%></span><span class="salary">S/ <%=h(oferta.getSalario())%></span></div><p><%=h(oferta.getResumen())%></p><a class="text-link" href="<%=request.getContextPath()%>/inicio?oferta=<%=oferta.getIdOferta()%>#ofertas">Ver detalle <i data-lucide="arrow-up-right" aria-hidden="true"></i></a></article><% } %></div><% if(ofertas.isEmpty()){ %><p class="empty-state">Esta empresa no tiene ofertas públicas vigentes.</p><% } %></section>
</main><%@include file="jspf/footer.jspf"%></body></html>
