package com.incluyelab.servlet;

import com.incluyelab.model.NecesidadesAccesibilidad;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AccesibilidadServlet", urlPatterns = {"/accesibilidad"})
public class AccesibilidadServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("necesidadesAccesibilidad", NecesidadesAccesibilidad.catalogo());
        request.getRequestDispatcher("/WEB-INF/accesibilidad.jsp").forward(request, response);
    }
}
