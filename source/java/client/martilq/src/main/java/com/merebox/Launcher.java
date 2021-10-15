package com.merebox;


import com.google.gson.*;
import com.merebox.martilq.Attribute;
import com.merebox.martilq.Resource;

public final class Launcher {
    private Launcher() {


    }

    public static void main(String[] args) {
        if (args.length > 0)
        {

            MartiLQ m = new MartiLQ();
            m.title = args[0];
        
            String fileName = "C:/Users/meerkat/source/marti/docs/samples/powershell/test/BSBDirectoryJul21-304.csv";
            Resource re = new Resource(fileName);
            Attribute at = new Attribute();
            at.category = "cat";
            re.AddAttribute(at);
            m.AddResource(re);

            Gson gson = new Gson();

            String json = gson.toJson(m);

            System.out.println("Json " + json);
        }  else {
            System.out.println("Hello World there! Please supply");

        }
    }
}
