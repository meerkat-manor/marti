# Sample with configuration file

The sample **martiLQ** document below has been generated 
using the client GOLANG program and a configuration file
with changed values from the default

The source is the project folder /docs/source

The configuration file is

```ini

[MartiLQ]
tags         = sample
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
state    = expired
expires  = 2:0:0
encoding = UTF-8
urlPrefix = http://localhost/martilq/

[Custom_Spatial]
enabled = true
country = Netherland
region = 
town = Amsterdam

[Custom_Temporal]
enabled = true
businessDate = {{yesterday}}
runDate = {{today}}

```

The **martiLQ** document

```json
{
    "content-type": "application/vnd.martilq.json",
    "title": "GEN001",
    "uid": "369fb6c4-3628-4f61-a3ee-7b03a0fc8e25",
    "description": "Simple example",
    "modified": "2021-11-02T22:56:03.5897714+11:00",
    "publisher": "meerkat@merebox.com",
    "contactPoint": "Your friendly Meerkat",
    "accessLevel": "Confidential",
    "rights": "Public",
    "tags": [
        "sample"
    ],
    "license": "MIT",
    "state": "expired",
    "batch": 1.001,
    "describedBy": "",
    "landingPage": "",
    "theme": "Documentation",
    "resources": [
        {
            "title": "martilq.md",
            "uid": "b0206363-5dcb-485d-83e9-9495e75662c1",
            "documentName": "martilq.md",
            "issueDate": "2021-11-02T22:56:03.5892511+11:00",
            "modified": "2021-11-02T22:47:49.7108132+11:00",
            "expires": "2023-11-02T00:00:00+11:00",
            "state": "expired",
            "author": "Hive",
            "length": 5873,
            "hash": {
                "algo": "SHA256",
                "value": "38714907ced5ff5efbf939f6404634dfa51762cec075b82187c0c6fa880aa37b",
                "signed": false
            },
            "description": "",
            "url": "http://localhost/martilq/martilq.md",
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
                    "value": "169"
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
        },
        {
            "extension": "spatial",
            "country": "Netherland",
            "region": "",
            "town": "Amsterdam"
        },
        {
            "extension": "temporal",
            "businessDate": "2021-11-01T00:00:00+11:00",
            "runDate": "2021-11-02T00:00:00+11:00"
        }
    ]
}
```

