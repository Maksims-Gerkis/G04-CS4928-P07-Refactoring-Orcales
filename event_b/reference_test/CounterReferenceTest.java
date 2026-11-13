import org.junit.Test;
import static org.junit.Assert.*;

// Ground-truth detecting test for the seeded bug. NEVER send this to the model.
// Passes on original (doubleNext() == 2), fails on resulting (doubleNext() == 3).
public class CounterReferenceTest {
    @Test
    public void doubleNextCallsNextOnce() {
        Counter c = new Counter();
        assertEquals(2, c.doubleNext());
        assertEquals(1, c.getCount());
    }
}
