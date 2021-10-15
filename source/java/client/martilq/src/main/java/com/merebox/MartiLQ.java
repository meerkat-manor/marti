package com.merebox;

import java.util.ArrayList;
import java.util.UUID;

import com.merebox.martilq.*;

public class MartiLQ {

    public String title;
    public String uid = UUID.randomUUID().toString();
    public ArrayList<Resource> resources = new ArrayList<Resource>();;

    public String description;
    public String modified;
    public ArrayList<String> tags = new ArrayList<String>();
    public String publisher = System.getProperty("user.name");
    public String contactPoint;
    public String accessLevel = "Confidential";
    public String rights = "Restricted";
    public String license;
    public String state = "active";
    public Float batch = 1f;
    public String describedBy;
    public String landingPage;
    public String theme;

    public ArrayList<Object> custom = new ArrayList<Object>();

    public MartiLQ()
    {
        Object software = new Software();
        custom.add(software);
        this.AddTag("document");
        this.AddTag("martiLQ");
    }

    public void AddResource(Resource resource)
    {
        this.resources.add(resource);
    }

    public void AddTag(String tag)
    {
        this.tags.add(tag);
    }

}
