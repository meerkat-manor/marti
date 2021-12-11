# MartiLQ document

The metadata reconciliation transfer information is referred
to as the **martiLQ** document throughout this documentation.

The **martiLQ** document can be part of a message or a file
in its own right. The definition is currently a JSON file.

## Structure

The JSON is composed of:

* A root definition that contains information applicable to all reosurces
* A [resource](resources.md) list that contains information related
  to each document or file
* [Attribute](attributes.md) list as a child to each resource
* A [custom](custom.md) list 

## Mandatory root information

The mandatory information in the root of the **martiLQ** document is:

Name|Description|Default or values
---|---|---
title|A title or batch identifier. Use a name that is easy to understand or relate to|None
uid|Unique identifier for the document.  If the same document is reproduced this may not change but the minor number of the batch must change|Auto generated
resources|Resource list. See Resource section summary below or detailed document [Resource](resources.md)|At least one required

### Optional information


The optional information is described in the table below.  A number of elements can be configured for their
default value(s) in a configuration file.

Name|Description|Default or values
---|---|--
description|Long description of the purpose, background or files included|None
modified|Modified date and time of the **martiLQ** document|Now
tags|List of tags or keywords|
publisher|Publisher name|
contactPoint|Contact point of a person or team|
accessLevel|Acces level|
rights|Rights|

* Batch
* License
* Described By - A link to the metadata describing the document.  
   More detailed information could be supplied at the link
* Landing page
* Theme
* Custom list - List of custom entries, one being the **martiLQ** software details
  see [custom](custom.md)

### Information extension

The information supplied can be extended by party agreement and there
are place holders in the defintion.

## Resource 

The resource section is a list of documents or files that are to be grouped
together are listed under the same **martiLQ** definition.

At least one document or file must be included.  If the same resource is repeated 
it will commonly be for definiting multiple formats, with each file having a 
different extension.  Commonly the definition includes at least the following
items:

Name|Description|Default or values
---|---|--
title|Title for the resource|Document name
uid|A unique identifier, commonly a GUID|Auto generated
documentName|A name of the document such as the file name
issueDate|Issued date - When the document was made available. The date can include time 
modified|Modified - When the document was created or modified.  This is the data and time
size|Size of document - The document size in bytes
url|URL - This can be ``file://``, ``https://``, ``ftp://``, etc resource location

### Resource optional

The following are some of the optional items in the resource section.  See [Resource](resources.md)
for more details

Name|Description|Default or values
---|---|--
hash|Hash of document - The hash of the document, which can be blank especially for large documents
algo|Hash algorithm - Algoroithm used to generate the hash value or sign it
description|Description - A more detailed description 
version|Version - A document version
encoding|Encoding
contentType|Content Type 
compression|Compression|None
encryption|Encryption|None
author|Author
attributes|List of attributes for the resource|Record count

## Simple sample

A sample of a single resource **martiLQ** document is shown below.  The
sample can be generated using the GOLANG client program with parameters:

```
-t GEN -m Sample.json -s ./docs/source/martilq.md --title "GEN001" --description "Simple example"
```

```json
{
    "contentType": "application/vnd.martilq.json",
    "title": "GEN001",
    "uid": "9a0a7edb-dd81-4fc5-a6cb-c5716eda7b51",
    "description": "Simple example",
    "modified": "2021-11-02T22:44:29.6887001+11:00",
    "publisher": "",
    "contactPoint": "",
    "accessLevel": "Confidential",
    "rights": "Restricted",
    "tags": null,
    "license": "",
    "state": "active",
    "stateModified": "2021-11-02T22:44:29.6887001+11:00",
    "batch": 1.001,
    "describedBy": "",
    "landingPage": "",
    "theme": "",
    "resources": [
        {
            "title": "martilq.md",
            "uid": "a88b4e5f-66b7-4003-ac24-831c95d0da07",
            "documentName": "martilq.md",
            "issueDate": "2021-11-02T22:44:29.6881663+11:00",
            "modified": "2021-11-02T07:47:13.9410018+11:00",
            "expires": "2023-11-02T00:00:00+11:00",
            "state": "active",
            "stateModified": "2021-11-02T22:44:29.6881663+11:00",
            "author": "",
            "length": 3654,
            "hash": {
                "algo": "SHA256",
                "value": "213a6254ddc02423b6c3bb3d977892678258539d37f06410ef18d27c14ffa821",
                "signed": false
            },
            "description": "",
            "url": "http://localhost/martilq/martilq.md",
            "version": "",
            "contentType": "",
            "encoding": "UTF-8",
            "compression": "",
            "encryption": "",
            "describedBy": "",
            "attributes": [
                {
                    "category": "dataset",
                    "name": "records",
                    "function": "count",
                    "comparison": "EQ",
                    "value": "95"
                }
            ]
        }
    ],
    "custom": [
        {
            "extension": "software",
            "softwareName": "MARTILQREFERENCE",
            "author": "Meerkat@merebox.com",
            "version": "0.0.1"
        }
    ]
}
```

You can view a more complete sample [samples/json/sample_02.md](samples/json/sample_02.md)
which has been generated using a configuration file to supply default values.

