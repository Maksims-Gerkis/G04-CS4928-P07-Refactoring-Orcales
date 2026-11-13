public class Counter {
    private int count;

    public int next() {
        count++;
        return count;
    }

    public int doubleNext() {
        int n = next();
        return n + n;
    }

    public int getCount() {
        return count;
    }
}
