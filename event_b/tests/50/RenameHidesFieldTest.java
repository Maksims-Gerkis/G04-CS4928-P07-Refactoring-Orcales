import org.junit.Test;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import static org.junit.Assert.*;

public class RenameHidesFieldTest {
    @Test
    public void testOutputIs100() {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PrintStream ps = new PrintStream(baos);
        PrintStream old = System.out;
        System.setOut(ps);
        try {
            new RenameHidesField().method();
        } finally {
            System.setOut(old);
        }
        String output = baos.toString().trim();
        assertEquals("100", output);
    }
}
