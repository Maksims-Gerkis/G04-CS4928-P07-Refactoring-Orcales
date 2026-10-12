class RenameHidesField {
    public void method() {
        int outer = 100;
        class InnerClass {
            int inner; 
            public void testmethod2() {
                this.inner = outer;
                System.out.println(inner);
            }
        }
        new InnerClass().testmethod2();
    }
}
