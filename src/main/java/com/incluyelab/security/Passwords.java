package com.incluyelab.security;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public final class Passwords {
    private static final int ITERATIONS = 600000;
    private Passwords() { }

    public static String hash(String password) {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        return "pbkdf2$" + ITERATIONS + "$" + Base64.getEncoder().encodeToString(salt)
                + "$" + Base64.getEncoder().encodeToString(derive(password, salt, ITERATIONS));
    }

    public static String policyError(String password) {
        if (password == null || password.length() < 8 || password.length() > 100) return "La contraseña debe tener entre 8 y 100 caracteres.";
        boolean upper=false,lower=false,digit=false,special=false;
        for (int i=0;i<password.length();i++) {
            char c=password.charAt(i);
            if (Character.isWhitespace(c)) return "La contraseña no debe contener espacios.";
            if (Character.isUpperCase(c)) upper=true;
            else if (Character.isLowerCase(c)) lower=true;
            else if (Character.isDigit(c)) digit=true;
            else special=true;
        }
        if (!upper) return "La contraseña debe incluir al menos una letra mayúscula.";
        if (!lower) return "La contraseña debe incluir al menos una letra minúscula.";
        if (!digit) return "La contraseña debe incluir al menos un número.";
        if (!special) return "La contraseña debe incluir al menos un carácter especial.";
        return null;
    }

    public static void requireStrong(String password) {
        String error=policyError(password);
        if (error!=null) throw new IllegalArgumentException(error);
    }

    public static String temporary() {
        final String chars="ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
        SecureRandom random=new SecureRandom();
        StringBuilder value=new StringBuilder("Tmp#Aq7");
        for(int i=0;i<9;i++) value.append(chars.charAt(random.nextInt(chars.length())));
        return value.toString();
    }

    public static boolean matches(String password, String stored) {
        if (password == null || stored == null || password.length() > 100) return false;
        // Existing academic accounts remain usable until their password is changed.
        if (!stored.startsWith("pbkdf2$")) {
            return MessageDigest.isEqual(password.getBytes(StandardCharsets.UTF_8), stored.getBytes(StandardCharsets.UTF_8));
        }
        try {
            String[] parts = stored.split("\\$");
            if (parts.length != 4) return false;
            int rounds = Integer.parseInt(parts[1]);
            if (rounds < 100000 || rounds > 1000000) return false;
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expected = Base64.getDecoder().decode(parts[3]);
            return salt.length == 16 && expected.length == 32
                    && MessageDigest.isEqual(derive(password, salt, rounds), expected);
        } catch (IllegalArgumentException ex) { return false; }
    }

    public static String version(String stored) {
        try {
            return Base64.getEncoder().encodeToString(MessageDigest.getInstance("SHA-256")
                    .digest(stored.getBytes(StandardCharsets.UTF_8)));
        } catch (GeneralSecurityException ex) { throw new IllegalStateException("No se pudo verificar la credencial", ex); }
    }

    private static byte[] derive(String password, byte[] salt, int rounds) {
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, rounds, 256);
        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (GeneralSecurityException ex) { throw new IllegalStateException("No se pudo proteger la credencial", ex); }
        finally { spec.clearPassword(); }
    }
}
