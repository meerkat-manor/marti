# Attribute definition

A Resource can list attributes related to the document / file.

An attribute is a generic definition and conventions are 
observed in the definitions that are captured here.

## Attribute definition 

The Attribute consists of:

   * category - A value of "dataset",
   * name
   * function - A value such as "count"
   * comparison - A comparisn value or NA.  Values are "EQ", 
        "NE", "GT", "LT
   * value - The value for the attribute based on the above complex key, excluding comparison

A sample JSON is shown below which describes the 
number of records in the file for the given format.

```json
    "attributes": [
        {
            "category": "dataset",
            "name": "records",
            "function": "count",
            "comparison": "EQ",
            "value": "9"
        }
    ]
```