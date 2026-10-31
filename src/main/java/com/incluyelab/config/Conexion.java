package com.incluyelab.config;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * Punto unico de acceso JDBC. Las credenciales nunca se escriben en el codigo:
 * 1) DataSource JNDI java:comp/env/jdbc/IncluyeLab (pool del servidor), o
 * 2) variables de entorno / propiedades JVM DB_URL, DB_USER, DB_PASSWORD, o
 * 3) archivo externo indicado en INCLUYELAB_DB_CONFIG (por defecto ~/IncluyeLab/db.properties).
 */
public class Conexion {
    private static final String JNDI = "java:comp/env/jdbc/IncluyeLab";
    private static volatile DataSource dataSource;
    private static volatile boolean jndiConsultado;
    private static volatile Properties archivo;

    private Conexion() {
    }

    public static Connection getConnection() throws SQLException {
        DataSource ds = buscarDataSource();
        if (ds != null) {
            try {
                return ds.getConnection();
            } catch (SQLException ex) {
                // Una referencia declarada pero incompleta no debe impedir usar la configuracion externa.
                dataSource = null;
            }
        }
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("No se encontro el driver de MySQL.", ex);
        }

        String url = setting("DB_URL");
        String user = setting("DB_USER");
        String password = setting("DB_PASSWORD");
        if (url.isEmpty() || user.isEmpty()) {
            throw new SQLException("Configura el DataSource jdbc/IncluyeLab o las variables DB_URL, DB_USER y DB_PASSWORD.");
        }
        return DriverManager.getConnection(url, user, password);
    }

    /** La busqueda JNDI se realiza una sola vez para no repetirla en cada consulta. */
    private static DataSource buscarDataSource() {
        if (!jndiConsultado) {
            synchronized (Conexion.class) {
                if (!jndiConsultado) {
                    try {
                        dataSource = (DataSource) new InitialContext().lookup(JNDI);
                    } catch (NamingException | RuntimeException ex) {
                        dataSource = null; // Sin pool configurado: se usa la configuracion externa.
                    }
                    jndiConsultado = true;
                }
            }
        }
        return dataSource;
    }

    private static String setting(String name) {
        String value = System.getenv(name);
        if (value == null || value.trim().isEmpty()) value = System.getProperty(name, "");
        if (value.trim().isEmpty()) value = archivoExterno().getProperty(name, "");
        return value.trim();
    }

    private static Properties archivoExterno() {
        Properties cargado = archivo;
        if (cargado != null) return cargado;
        synchronized (Conexion.class) {
            if (archivo != null) return archivo;
            Properties props = new Properties();
            String ruta = System.getenv("INCLUYELAB_DB_CONFIG");
            if (ruta == null || ruta.trim().isEmpty()) ruta = System.getProperty("INCLUYELAB_DB_CONFIG", "");
            Path path = ruta.trim().isEmpty()
                    ? Paths.get(System.getProperty("user.home"), "IncluyeLab", "db.properties")
                    : Paths.get(ruta.trim());
            if (Files.isRegularFile(path)) {
                try (InputStream in = Files.newInputStream(path)) {
                    props.load(in);
                } catch (IOException ex) {
                    // Archivo ilegible: se informa como configuracion faltante sin exponer su contenido.
                }
            }
            archivo = props;
            return props;
        }
    }
}
