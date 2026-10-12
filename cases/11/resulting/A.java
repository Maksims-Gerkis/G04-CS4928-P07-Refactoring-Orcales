public class A {
  public long k(){
    return 3;
  }
  public long m(){
    return B.this.k();
  }
}
