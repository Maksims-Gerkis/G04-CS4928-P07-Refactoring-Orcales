import org.junit.Test;
import static org.junit.Assert.*;

public class BehaviorTest {
    @Test
    public void testBTestMethod() {
        B b = new B();
        // In CODE1: b.test() -> b.m() -> super.k() -> 10
        // In CODE2: b.test() -> A.m() with this=b -> this.k() -> B.k() -> 20
        assertEquals(10, b.test());
    }
}
