public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
        
        // Print any arguments passed to the program
        if (args.length > 0) {
            System.out.println("Arguments passed:");
            for (int i = 0; i < args.length; i++) {
                System.out.println("  " + (i+1) + ": " + args[i]);
            }
        }
    }
}