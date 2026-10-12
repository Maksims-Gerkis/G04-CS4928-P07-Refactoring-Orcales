public class A {
  long k(int y){
    return 1;
  }
  private long k(  int a){
    return 0;
  }
  public long m(){
    return k(1);
  }
}
