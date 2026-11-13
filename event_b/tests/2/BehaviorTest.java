import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class BehaviorTest {
 @Test
 public void testKDispatch() {
 B b = new B();
 assertEquals(1L, b.test());
 }
}
