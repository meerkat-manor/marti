# Attribute definition

A Resource can list attributes related to the document / file.

An attribute is a generic definition and conventions are 
observed in the definitions that are captured here.  The attribute
section is where load quality metrics are defined.

## Attribute definition 

The Attribute is described by the table below.  Recommended
values are listed but custom values can also be defined, just be
certain the recipient is able to understand them.

Name|Description|Values or Default
---|---|---
category|A type of attribute|dataset, format
name|A name for the attribute|records,columns,header,footer,separator,quote, escape 
function|A function to perform|count,sum,unique
comparison|A comparison value or NA|NA, EQ, NE, GT, GE, LT,LE
value|The value for the attribute based on the above complex key, excluding comparison|numeric 

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
