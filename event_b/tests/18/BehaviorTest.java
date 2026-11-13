import org.junit.Test;
import static org.junit.Assert.*;

public class BehaviorTest {
    @Test
    public void testReturnValue() {
        C c = new C();
        assertEquals(1L, c.test());
    }
}
