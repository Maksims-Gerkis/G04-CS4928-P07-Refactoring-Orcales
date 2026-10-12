public class C extends B {
  public int m() {
    return super.k();
  }
  public static void main(String[] args) {
    C c = new C();
    System.out.println(c.m());
  }
}
