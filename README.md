# Marti

Marti is for metadata reconcilation for transfer information.

The objective is the provide transfer information for high volume data such as
in files.  The document (files) can be transferred via HTTPS, SFTP, message queue, 
network share or other.  The transfer information being described here does not 
need to arrive via the same channel and cluld be received via email or 
even synchronous / asynchronous API. The transfer information does not dictate or 
determine how the data is formatted.

The transfer information can provide details on the document format, but in itself
it does not understand the data fomrat.

Marti is intended to provide minimum basic information on the transfer with  
ability to include additional optional information.  The metadata reconcilation 
transfer document being decscribed here wil be referred to as the [Marti](Marti.md)
document throughout this documentation.

The information is supplied as a separate document which could be another file
or supplied via API by the publisher notifying the consumer(s).

## Tools and Scenarios

Tools and code snippets are provided to generate the information and then
assist in reconcile the document contents once received.  Refer to the 
programming folders for more details or [Tools](tools.md) for more general 
information

## Transfer information

### Mandatory information

The mandatory information is:

* Title
* Unique identifier
* Distribution list - See Distribution section summary below or detailed document [Distribution](docs/distribution.md)


### Optional information

The option information is:

* Description
* Modified
* Tags or keywords
* Publisher
* Contact point
* Acces level
* Rights
* License
* Spatial (*)
* Temporal (*)
* Described By - A link to the metadata describing the document.  
   More details information could be supplied in the distribution
* Landing page
* Theme

### Information extension

The information supplied can be extended by agreeing parties and there
are place holders in the defintion.

### Distribution 

The distribution section can be repeated, but at least one must be included.
If the distribution is repeated it will comonly be for definiting
multiple formats of the same data.

* Title
* Unique identifier
* Document name - If no download URL, then this will be the document name
* Issued date - When the document was made available. The date can include time 
* Modified - When the document was created or modified.  This is the data and time
* Size of document - The document size in bytes
* Hash of document - The hash of the document, which can be blank especially for large documents
* Hash algorithm

### Distribution optional

The following are some of the optional items in the distribution section.  See [Distribution](dstribution.md)
for more items and details

* Description
* Download URL
* Version
* Format
* Compression
* Encryption


