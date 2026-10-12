import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
import p2.A;
public class ABehaviorTest {
@Test
public void shouldReturnZeroFromTest() {
A a = new A();
assertEquals(0L, a.test());
}
}
