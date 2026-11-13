package p2;
import org.junit.Test;
import static org.junit.Assert.*;
public class BehaviorTest {
    @Test
    public void testKOnBInstance() {
        B b = new B();
        long result = b.k(2);
        assertEquals(1L, result);
    }
}
