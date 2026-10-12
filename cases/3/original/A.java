public class A {
  long k(){
    return 1;
  }
  private long k(  int a){
    return 0;
  }
  public long m(){
    return k();
  }
}
