package com.incluyelab.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        javax.servlet.http.HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();
        String destino = request.getParameter("destino");
        if ("registro".equals(destino)) response.sendRedirect(request.getContextPath()+"/registro?rol=POSTULANTE");
        else if ("login".equals(destino)) response.sendRedirect(request.getContextPath()+"/login");
        else response.sendRedirect(request.getContextPath()+"/inicio");
    }
}
