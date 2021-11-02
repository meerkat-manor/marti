# Sample with configuration file

The sample **martiLQ** document below has been generated 
using the client GOLANG program and a configuration file
with changed values from the default

The source is the project document ``/docs/source/martiLQ.md``

GOLANG program arguments are :
```
-t GEN -m test_Sample02.json -c GEN002.ini -s docs/source/ --title "GEN002" --description "Simple example"
```

The configuration file is

```ini

[MartiLQ]

tags         = sample,docs
publisher    = meerkat@merebox.com
contactPoint = Your friendly Meerkat
accessLevel  = Confidential
rights       = Public
license      = MIT
batch        = @./config/batch.no
theme        = Documentation


[Resources]

author   = Hive
title    = {{documentName}}
state    = active
expires  = 0:0:7
urlPrefix = https://github.com/meerkat-manor/marti/blob/draft_specifications/docs/source/

```

The **martiLQ** document

```json
{
    "content-type": "application/vnd.martilq.json",
    "title": "GEN002",
    "uid": "42532ae8-4d42-4875-b7c8-bcb7a5c38eaa",
    "description": "Simple example",
    "modified": "2021-11-03T07:23:22.9177182+11:00",
    "publisher": "meerkat@merebox.com",
    "contactPoint": "Your friendly Meerkat",
    "accessLevel": "Confidential",
    "rights": "Public",
    "tags": [
        "sample",
        "docs"
    ],
    "license": "MIT",
    "state": "active",
    "batch": 1.001,
    "describedBy": "",
    "landingPage": "",
    "theme": "Documentation",
    "resources": [
        {
            "title": "martiLQ.md",
            "uid": "965fc95b-5d36-468c-abe4-7df618914180",
            "documentName": "martiLQ.md",
            "issueDate": "2021-11-03T07:23:22.909717+11:00",
            "modified": "2021-11-02T22:57:00.0061831+11:00",
            "expires": "2021-11-10T00:00:00+11:00",
            "state": "active",
            "author": "Hive",
            "length": 6046,
            "hash": {
                "algo": "SHA256",
                "value": "111f3ad34d94dc346ac282c9a1cc9a3e5802706b5274684b660d2f9b1721abcf",
                "signed": false
            },
            "description": "",
            "url": "https://github.com/meerkat-manor/marti/blob/draft_specifications/docs/source/martiLQ.md",
            "version": "",
            "content-type": "",
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
                    "value": "172"
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

