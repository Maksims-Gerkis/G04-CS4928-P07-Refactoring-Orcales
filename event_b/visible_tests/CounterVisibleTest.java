import org.junit.Test;
import static org.junit.Assert.*;

// "Original visible tests": the tests that existed before the refactoring.
// They pass on BOTH versions, so they do not reveal the seeded bug.
public class CounterVisibleTest {
    @Test
    public void nextIncrementsCount() {
        Counter c = new Counter();
        c.next();
        c.next();
        assertEquals(2, c.getCount());
    }

    @Test
    public void doubleNextIsPositive() {
        Counter c = new Counter();
        assertTrue(c.doubleNext() > 0);
    }
}
