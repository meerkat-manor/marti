package com.merebox.martilq;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;


public class Resource {

    public String title;
    public String uid = UUID.randomUUID().toString();
    public String documentName;
    public Date issuedDate;
    public Date modified;
    public String state;
    public String author = System.getProperty("user.name");
    public long length = 0;
    public Hash hash;

    public String description;
    public String url;
    public String structure;
    public String version;
    public String content_type;
    public String compression;
    public String encryption;

    public ArrayList<Attribute> attributes = new ArrayList<Attribute>();

    
    public Resource(String filePath)
    {
        try {
            Path path = Paths.get(filePath);
            this.length = Files.size(path);
            this.documentName = java.nio.file.Paths.get(filePath).getFileName().toString();
            String extPattern = "(?<!^)[.][^.]*$";
            this.title = this.documentName.replaceAll(extPattern, "");
            this.hash = Hash.GenerateHash("SHA512", filePath, null);
        } catch (IOException ex) {
            System.out.println("Exception in resource generation: "+ ex.getMessage());
            System.out.println("File: "+ filePath);
        }
    }

    public void AddAttribute(Attribute attribute)
    {
        this.attributes.add(attribute);
    }


}
