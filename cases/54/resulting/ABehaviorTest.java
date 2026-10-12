import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
public class ABehaviorTest {
@Test
public void shouldReturnTenWhenCallingInnerK() {
A a = new A();
A.B b = a.new B();
assertEquals(10, b.k());
}
}
