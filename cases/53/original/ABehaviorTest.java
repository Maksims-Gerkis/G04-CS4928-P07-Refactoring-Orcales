import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
public class ABehaviorTest {
@Test
public void shouldReturnOne() {
A a = new A();
assertEquals(1, a.m());
}
}
