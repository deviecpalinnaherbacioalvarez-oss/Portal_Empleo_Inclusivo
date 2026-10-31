package com.incluyelab.service;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import javax.imageio.ImageIO;
import javax.servlet.http.Part;

public final class AlmacenCarnetConadis {
    public static final long MAX_BYTES = 5L * 1024 * 1024;
    private static final Set<String> TIPOS = new HashSet<>(Arrays.asList("image/jpeg", "image/png"));

    private AlmacenCarnetConadis() { }

    public static String guardar(Part parte) throws IOException {
        if (parte == null || parte.getSize() == 0) throw new IllegalArgumentException("Debes adjuntar una fotografía legible del carnet CONADIS.");
        if (parte.getSize() > MAX_BYTES) throw new IllegalArgumentException("La fotografía no debe superar los 5 MB.");
        String tipo = parte.getContentType() == null ? "" : parte.getContentType().toLowerCase();
        if (!TIPOS.contains(tipo)) throw new IllegalArgumentException("La fotografía debe estar en formato JPG, JPEG o PNG.");

        BufferedImage origen;
        try (InputStream in = parte.getInputStream()) { origen = ImageIO.read(in); }
        if (origen == null) throw new IllegalArgumentException("El archivo no contiene una imagen JPG o PNG válida.");
        long pixeles = (long) origen.getWidth() * origen.getHeight();
        if (origen.getWidth() < 200 || origen.getHeight() < 200 || origen.getWidth() > 8000 || origen.getHeight() > 8000 || pixeles > 40_000_000L) {
            throw new IllegalArgumentException("La fotografía debe ser legible, tener al menos 200x200 píxeles y un tamaño de imagen razonable.");
        }

        BufferedImage limpia = new BufferedImage(origen.getWidth(), origen.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = limpia.createGraphics();
        try {
            g.setColor(Color.WHITE);
            g.fillRect(0, 0, limpia.getWidth(), limpia.getHeight());
            g.drawImage(origen, 0, 0, null);
        } finally { g.dispose(); }

        Path directorio = directorio();
        Files.createDirectories(directorio);
        String nombre = UUID.randomUUID().toString() + ".jpg";
        Path destino = resolver(nombre);
        if (!ImageIO.write(limpia, "jpg", destino.toFile())) throw new IOException("No se pudo procesar la fotografía del carnet.");
        return nombre;
    }

    public static Path resolver(String nombreInterno) {
        if (nombreInterno == null || !nombreInterno.matches("[a-f0-9-]{36}\\.jpg")) throw new IllegalArgumentException("Referencia de imagen no válida.");
        Path base = directorio();
        Path archivo = base.resolve(nombreInterno).normalize();
        if (!archivo.startsWith(base)) throw new IllegalArgumentException("Referencia de imagen no válida.");
        return archivo;
    }

    public static Path resolverLectura(String nombreInterno) {
        if (nombreInterno != null && nombreInterno.matches("[a-f0-9-]{36}\\.jpg")) return resolver(nombreInterno);
        if (nombreInterno == null || !nombreInterno.matches("conadis(?:-reg)?-[a-zA-Z0-9-]+\\.jpg")) throw new IllegalArgumentException("Referencia de imagen no válida.");
        Path legado=Paths.get(System.getProperty("user.home"),"IncluyeLab","conadis").toAbsolutePath().normalize();
        Path archivo=legado.resolve(nombreInterno).normalize();
        if(!archivo.startsWith(legado))throw new IllegalArgumentException("Referencia de imagen no válida.");
        return archivo;
    }

    public static void eliminarSiExiste(String nombreInterno) {
        if (nombreInterno == null) return;
        try { Files.deleteIfExists(resolver(nombreInterno)); } catch (Exception ignored) { }
    }

    private static Path directorio() {
        return Paths.get(System.getProperty("user.home"), "IncluyeLab", "privado", "conadis").toAbsolutePath().normalize();
    }
}
