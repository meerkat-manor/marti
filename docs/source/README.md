# Documentation

**martiLQ** stands for metadata reconcilation for transfer information, load quality

Before starting with **martiLQ** it is advisable to understand if it is right for
your organisation's needs.  Information is available in a number of short 
documents.

There is no quickstart document to get you started as each use case and
organisation is different. There are sample implementations which you
can adjust if they resonate with your circumstances,
see [sample implementations](samples/)


There are sample implementations which you
can adjust if they resonate with your circumstances.

The source, documentation and samples are available at `<https://github.com/meerkat-manor/marti>`_

## MartiLQ objective

The objective of **martiLQ** is to define a simple standard for
capturing the data files being transferred.  It is not for 
real time web service transactions.  

**martiLQ** is about file and document transfer and reconciling
that the all files have arrived and have not changed, and if so
required are also encrypted.

The proposition is to have a common, machine readable format
for file exchange that:

  * ensures data load quality and reconciles
  * can be used on Linux or Windows or Mac
  * can be used with Python, Java, PowerShell, Golang, etc 
  * can be used by web services
  * uses a text based format (JSON)
  * can form part of the data processing pipeline

And finally is easy to understand.

To get a better understanding have a look at the definition 
in [martiLQ](martiLQ.md)
