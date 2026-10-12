import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
import a.B;
public class BBehaviorTest {
@Test
public void shouldReturnTenFromTest() {
B b = new B();
assertEquals(10, b.test());
}
}
