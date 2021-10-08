# Distribution definition

The distrubution definition describes a single document, though
some documents may expand to multiple documents if they are
compressed with a utility such as WinZIP or 7ZIP


* Title
* Document name - Commonly being absolute or relative file name.
    This value could also be an URL address or network path
* Issued date - When the document was made available. The date can include time 
* Modified - When the document was created or modified.  This is the data and time
* Size of document - The document size in bytes
* Hash of document - The hash of the document, which can be blank especially for large documents
* Hash algorithm


The following are optional in the distribution section.

* Identifier
* Description
* Download URL
* Version - Document version.  The same document coudl be updated or this might denote the next version
    of a regular report.  For example a daily extract will have the version number incremented
    every day and provide a new URL.  The previous document can be retained.
* Format - if not specified then the consumer will in all likelihood use the document extension / mime type
* Media Type
* Expiry Date - The date and time that this document expires and can be removed from the download URL
    location.  This is not the document retention period as might be required for archiving.
* Described By - A link to the metadata describing this document data and format
* Compression - Type of compression used if any
* Encryption - Type of encryption used if any


## Compression

Documents can be compressed using a utility.  A single compressed document can contain
multiple documents.  The Marti definition document applies to the compressed document 
and not to the contents, which could be multiple documents.

In the case of a compressed document, there should be a Marti definition document in the
compressed document to match the data document.  That is the number of the records in a 
compressed document should always be an even number.

Compression of documents always occur before encryption.

### Marti definition for Compressed Document

For a compressed document that is not encrypted, the distribution definition will be:

* Title - The compressed document title which could be a group name
* Document name - Commonly being absolute or relative file name.
    This value could also be an URL address or network path
* Issued date - When the compressed document was made available. 
* Modified - When the compressed document was created or modified.  This is the data and time
    and is not the modified date of the document in the compressed document.
* Size of document - The compressed document size in bytes
* Hash of document - The hash of the compressed document, which can be 
    blank especially for large documents
* Hash algorithm

The reason for this approach is it allows a generic tool to be deployed to
check the validity of the contents without unpacking the received /fetched
document.  That is you can perform load quality pipeline processing.

## Encryption

The encryption of content is always applied after compression not before, if
you are not using the compression tool native encryption.  WinZIP and 7ZIP
provide encryption within the tool execution.

If the compression is TAR or GZIP then you may consider applying a GPG
or other encryption algorithm to the compressed file.

* Title - The encrypted document title 
* Document name - Commonly being absolute or relative file name.
    This value could also be an URL address or network path
* Issued date - When the **encrypted** document was made available. 
* Modified - When the **encrypted** document was created or modified.  
    This is the data and time and is not the modified date of the encrypted document.
* Size of document - The **decrypted** document size in bytes
* Hash of document - The hash of the **decrypted** document, which can be 
    blank especially for large documents
* Hash algorithm

The rational for using the decrypted document attributes is that an ecrypted
document is unlikely to be able to be modified without knowing encryption keys.
Checking the decrypted document attributes is a better check wheer appropriate.

The reason for this approach is it allows a generic tool to be deployed to
decrypt and check the validity of the received / fetched document without
needing to understand the contents.  That is you can perform load quality
pipeline processing.
