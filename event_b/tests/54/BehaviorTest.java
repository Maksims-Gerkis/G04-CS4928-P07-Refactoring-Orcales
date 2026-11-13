import org.junit.Test;
import static org.junit.Assert.*;

public class BehaviorTest {
    @Test
    public void testKReturns10() {
        A a = new A();
        A.B b = a.new B();
        assertEquals(10, b.k());
    }
}
