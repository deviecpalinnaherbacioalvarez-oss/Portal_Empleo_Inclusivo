package com.incluyelab.service;

import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

/** Entrega códigos OTP por SMTP sin exponerlos en la interfaz ni en los logs. */
public final class CorreoOtpService {
    public void enviar(String destino, String codigo) {
        String host = valor("MAIL_HOST");
        String usuario = valor("MAIL_USER");
        String clave = valor("MAIL_PASSWORD");
        String remitente = valor("MAIL_FROM");
        if (host.isEmpty() || usuario.isEmpty() || clave.isEmpty() || remitente.isEmpty()) {
            throw new IllegalStateException("El envío de correo no está configurado. Define MAIL_HOST, MAIL_USER, MAIL_PASSWORD y MAIL_FROM.");
        }
        Properties props = new Properties();
        props.setProperty("mail.smtp.host", host);
        props.setProperty("mail.smtp.port", valor("MAIL_PORT").isEmpty() ? "587" : valor("MAIL_PORT"));
        props.setProperty("mail.smtp.auth", "true");
        props.setProperty("mail.smtp.starttls.enable", valor("MAIL_STARTTLS").isEmpty() ? "true" : valor("MAIL_STARTTLS"));
        props.setProperty("mail.smtp.connectiontimeout", "10000");
        props.setProperty("mail.smtp.timeout", "10000");
        props.setProperty("mail.smtp.writetimeout", "10000");
        Session session = Session.getInstance(props, new Authenticator() {
            @Override protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(usuario, clave);
            }
        });
        try {
            MimeMessage mensaje = new MimeMessage(session);
            mensaje.setFrom(new InternetAddress(remitente, "IncluyeLab", "UTF-8"));
            mensaje.setRecipient(Message.RecipientType.TO, new InternetAddress(destino));
            mensaje.setSubject("Código de verificación de IncluyeLab", "UTF-8");
            mensaje.setText("Tu código de verificación es " + codigo
                    + ". Vence en 15 minutos y solo puede utilizarse una vez.\n\n"
                    + "Si no solicitaste este código, ignora este mensaje.", "UTF-8");
            Transport.send(mensaje);
        } catch (Exception ex) {
            throw new IllegalStateException("No se pudo entregar el código al correo registrado.", ex);
        }
    }

    private String valor(String nombre) {
        String v = System.getProperty(nombre);
        if (v == null || v.trim().isEmpty()) v = System.getenv(nombre);
        return v == null ? "" : v.trim();
    }
}
