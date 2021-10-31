# Marti

**martiLQ** stands for metadata reconcilation for transfer information, load quality.

The objective is to provide transfer information for high volume data such as
in files.  The files can be transferred via HTTPS, SFTP, message queue, 
network share or other.  The transfer information being described here does not 
need to arrive via the same channel and could be received via email or 
even synchronous / asynchronous API. The transfer information does not dictate or 
determine how the data is formatted.

The transfer information can provide details on the file format, but in itself
it does not understand the data format.

**Note**: The terms file and document are intended to be interchangeable 
through out this documentation.

**martiLQ** is intended to provide minimum basic information on the transfer with  
ability to include optional information.  The metadata reconcilation 
transfer document being decscribed here wil be referred to as the [martiLQ document](MartiLQ.md)
throughout this documentation.

The transfer information is supplied as a separate document which could be another file
or supplied via API by the publisher notifying the consumer(s).

## Tools and Scenarios

Tools and code snippets are provided to generate the transfer information and then
assist in reconciling the document contents once received.  Refer to the 
[source programming folders](source/) for more details or [Tools](tools.md) for more general 
information

- [Java](source/java/README.md)
- [golang](source/golang/README.md)
- [python](source/python/README.md)
- [powershell](source/powershell/README.md)
- [docker](source/docker/README.md)

## Transfer information

The information in the **martiLQ** document is summarised below. For more detailed
information see [martiLQ definition](/docs/source/martiLQ.md)

### Mandatory information

The mandatory information is:

* Title
* Unique identifier
* Resource list - See Resource section summary below or detailed document [Resource](docs/source/resource.md)

### Optional information

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
* Spatial (*)
* Temporal (*)
* Described By - A link to the metadata describing the document.  
   More details information could be supplied in the distribution
* Landing page
* Theme

### Information extension

The information supplied can be extended by party agreement and there
are place holders in the defintion.

### Resource 

The resource section is intended to allow multiple data files to be
grouped together.  The resource section can be repeated, but at least 
one must be included.  If the resource is repeated it will commonly 
be for definiting multiple formats of the same data or batching of
different data together from the same extract process.

* Title
* Unique identifier
* Document name
* Issued date - When the document was made available. The date can include time 
* Modified - When the document was created or modified.  This is the data and time
* Size of document - The document size in bytes
* Hash of document - The hash of the document, which can be blank especially for large documents
* Hash algorithm

### Resource optional

The following are some of the optional items in the resource section.  See [Resource](docs/source/resources.md)
for more details

* Description
* Download URL
* Version
* Format
* Compression
* Encryption
