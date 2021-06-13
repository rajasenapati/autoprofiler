import java.util.ArrayList;

public class SampleMemoryLeaker {

    public static void main(String[] args) throws InterruptedException {
        System.out.println("Triggering an OOM");
        ArrayList<String> list = new ArrayList<String>();
        for (int i = 0; i < 1000000; i++) {
            list.add(i+"");
        }
    }
    
}
