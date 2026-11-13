import org.junit.Test;
import static org.junit.Assert.*;

public class ATest {
    @Test
    public void testMReturnValue() {
        A a = new A();
        assertEquals(1, a.m());
    }
}
