class B extends A{
    void m(String m){
        System.out.println("B");
    }
    void f(){
        A.this.m("1");
    }
}
