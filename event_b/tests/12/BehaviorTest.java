import org.junit.Test;
import static org.junit.Assert.*;

public class BehaviorTest {
    @Test
    public void testBTestReturnValue() {
        B b = new B();
        assertEquals(10, b.test());
    }
}
