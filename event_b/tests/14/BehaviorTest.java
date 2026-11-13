import org.junit.Test;
import static org.junit.Assert.*;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

public class BehaviorTest {
    @Test
    public void testMReturnValue() {
        C c = new C();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PrintStream old = System.out;
        System.setOut(new PrintStream(baos));
        C.main(new String[]{});
        System.setOut(old);
        String output = baos.toString().trim();
        // In CODE1, super.k() in B refers to A.k() => 10
        // In CODE2, super.k() in C refers to B.k() => 20
        // This assertion will pass for CODE1 (10) but fail for CODE2 (20)
        assertEquals("10", output);
    }
}
