MartiLQ document
================

The metadata reconciliation transfer information is referred
to as the **martiLQ** document throughout this documentation.

The **martiLQ** document can be part of a message or a file
in its own right. The definition is curently a Json file.

Mandatory information
---------------------

The mandatory information is:

* Title
* Unique identifier
* Resource list - See Resource section summary below or detailed document [Resource](resources.md)

Optional information
++++++++++++++++++++

The optional information is:

* Description
* Modified
* Tags or keywords
* Publisher
* Contact point
* Acces level
* Rights
* Batch
* License
* Described By - A link to the metadata describing the document.  
   More detailed information could be supplied at the link
* Landing page
* Theme
* Custom list - List of custom entries, one being the **martiLQ** software details
  see [custom](custom.md)

Information extension
+++++++++++++++++++++

The information supplied can be extended by party agreement and there
are place holders in the defintion.

Resource 
--------

The resource section is a list of documents or files that are to be grouped
together are listed under the same **martiLQ** definition.

At least one document or file must be included.  If the same resource is repeated 
it will commonly be for definiting multiple formats, with each file having a 
different extension.  Commonly the definition includes at least the following
items:

* Title - A summary description of the document contents
* Unique identifier - A unique identifier, commonly a GUID
* Document name - A name of the document such as thefile name
* Issued date - When the document was made available. The date can include time 
* Modified - When the document was created or modified.  This is the data and time
* Size of document - The document size in bytes
* URL - This can be ``file://``, ``https://``, ``ftp://``, etc resource location

Resource optional
+++++++++++++++++

The following are some of the optional items in the resource section.  See [Resource](resources.md)
for more details

* Hash of document - The hash of the document, which can be blank especially for large documents
* Hash algorithm - Algoroithm used to generate the hash value or sign it
* Description - A more detailed description 
* Version - A document version
* Encoding
* Content Type 
* Compression
* Encryption
* Author
