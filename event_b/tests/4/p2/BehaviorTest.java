package p2;
import org.junit.Test;
import static org.junit.Assert.*;

public class BehaviorTest {
    @Test
    public void testTestMethod() {
        A a = new A();
        assertEquals(0L, a.test());
    }
}
