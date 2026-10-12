import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
public class CBehaviorTest {
@Test
public void shouldReturnOneFromTest() {
C c = new C();
assertEquals(1L, c.test());
}
}
