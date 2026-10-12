import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
public class BBehaviorTest {
@Test
public void shouldReturnOneFromTest() {
B b = new B();
assertEquals(1L, b.test());
}
}
