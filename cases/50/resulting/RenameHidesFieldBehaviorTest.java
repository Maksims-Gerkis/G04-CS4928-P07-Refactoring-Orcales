import static org.junit.jupiter.api.Assertions.assertEquals;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;
public class RenameHidesFieldBehaviorTest {
@Test
public void shouldPrintOneHundred() {
PrintStream originalOut = System.out;
ByteArrayOutputStream buffer = new ByteArrayOutputStream();
try {
System.setOut(new PrintStream(buffer, true, StandardCharsets.UTF_8));
new RenameHidesField().method();
} finally {
System.setOut(originalOut);
}
String output = buffer.toString(StandardCharsets.UTF_8).replace("\r\n", "\n");
assertEquals("100\n", output);
}
}
