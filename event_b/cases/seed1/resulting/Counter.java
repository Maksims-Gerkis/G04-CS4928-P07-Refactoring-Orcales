public class Counter {
    private int count;

    public int next() {
        count++;
        return count;
    }

    public int doubleNext() {
        return next() + next();
    }

    public int getCount() {
        return count;
    }
}
