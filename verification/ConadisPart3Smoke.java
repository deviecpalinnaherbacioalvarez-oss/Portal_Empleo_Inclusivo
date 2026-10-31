import com.incluyelab.security.ConadisValidator;
import com.incluyelab.service.VerificadorConadisNoConfigurado;
import com.incluyelab.service.VerificadorConadisOficial;
import com.incluyelab.service.AlmacenCarnetConadis;

public final class ConadisPart3Smoke {
    public static void main(String[] args) {
        comprobar("406923".equals(ConadisValidator.rui(" rd- 406923 ")), "normalización RUI");
        comprobarFalla(() -> ConadisValidator.rui("   "), "RUI vacío");
        comprobarFalla(() -> ConadisValidator.rui("RD12<script>"), "RUI inválido");
        VerificadorConadisNoConfigurado servicio = new VerificadorConadisNoConfigurado();
        comprobar(!servicio.estaDisponible(), "servicio oficial desactivado por defecto");
        comprobar(servicio.verificar("406923", "12345678") == VerificadorConadisOficial.Resultado.NO_DISPONIBLE,
                "sin resultados oficiales simulados");
        comprobarFalla(() -> AlmacenCarnetConadis.resolver("../carnet.jpg"), "bloqueo de path traversal");
        comprobar(AlmacenCarnetConadis.resolver("123e4567-e89b-12d3-a456-426614174000.jpg").toString()
                .contains("IncluyeLab"), "ruta privada interna");
        System.out.println("CONADIS_PARTE_3_SMOKE_OK");
    }

    private static void comprobar(boolean condicion, String nombre) {
        if (!condicion) throw new AssertionError(nombre);
    }

    private static void comprobarFalla(Runnable accion, String nombre) {
        try { accion.run(); }
        catch (IllegalArgumentException esperado) { return; }
        throw new AssertionError(nombre);
    }
}
