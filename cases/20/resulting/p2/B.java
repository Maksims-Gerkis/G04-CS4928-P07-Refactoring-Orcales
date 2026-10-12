package p2;
import p1.*;
public class B extends A {
  public long m(){
    return new A().k(2);
  }
  public long k(  int a){
    return 0;
  }
}
