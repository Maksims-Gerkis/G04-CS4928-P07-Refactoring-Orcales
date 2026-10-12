import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
public class CBehaviorTest {
@Test
public void shouldPrintTenThroughM() {
C c = new C();
assertEquals(10, c.m());
}
}
