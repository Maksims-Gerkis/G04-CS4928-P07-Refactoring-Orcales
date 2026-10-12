class RenameHidesField {
    public void method() {
        int outer = 100;
        class InnerClass {
            int outer; 
            public void testmethod2() {
                this.outer = outer;
                System.out.println(outer);
            }
        }
        new InnerClass().testmethod2();
    }
}
