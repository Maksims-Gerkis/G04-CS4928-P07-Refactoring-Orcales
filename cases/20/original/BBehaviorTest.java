import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
import p2.B;
public class BBehaviorTest {
@Test
public void shouldPreserveInheritedKBehavior() {
B b = new B();
assertEquals(1L, b.k(2));
}
}
