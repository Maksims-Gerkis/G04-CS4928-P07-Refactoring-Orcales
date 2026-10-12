class A {
    int y = 2;
    int main() {
        final int y = 1;
        
        int x = y;
        System.out.println(A.super.y);
        return 0;
    }
}
