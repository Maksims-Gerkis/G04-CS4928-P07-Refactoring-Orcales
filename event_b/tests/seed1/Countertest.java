import org.junit.Test;
import static org.junit.Assert.*;

public class CounterTest {
    @Test
    public void testDoubleNextReturnValue() {
        Counter counter = new Counter();
        int result = counter.doubleNext();
        // Code1: next() called once, count=1, returns 1+1=2
        // Code2: next() called twice, count=2, returns 1+2=3
        assertEquals(2, result);
        assertEquals(1, counter.getCount());
    }
}
