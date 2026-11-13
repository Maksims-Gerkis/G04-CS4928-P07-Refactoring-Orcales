import org.junit.Test;
import static org.junit.Assert.*;

public class BehaviorTest {
    @Test
    public void testCTestMethod() {
        C c = new C();
        // In Code1: C.k = 20, so test() returns 20L
        // In Code2: C inherits k = 10 from A, so test() returns 10L
        assertEquals(20L, c.test());
    }
}
