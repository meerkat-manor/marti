# Distribution definition

The distrubution section defines the files that are grouped
together by association.  This association is not defined but can
include different formats of the same data or a common batch extract 
such as end of day.

Some files may expand to multiple files if they are
compressed with a utility such as WinZIP or 7ZIP.  In the situation
where a ZIP file expands to multiple documents, then the expectation is
that the ZIP file contains a **martiLQ** document describing its contents.

The elements in the distribution section are:

* Title
* Document name - Commonly being absolute or relative file name.
    This value could also be an URL address or network path
* Issued date - When the document was made available. The date can include time 
* Modified - When the document was created or modified.  This is the data and time
* Size of file - The file size in bytes
* Hash of file - The hash of the file, which can be blank especially for large files
* Hash algorithm

The following are optional in the distribution section.

* Identifier
* Description
* Download URL
* Version - File version.  The same file could be updated or this might denote the next version
    of a regular report.  For example a daily extract will have the version number incremented
    every day and provide a new URL.  The previous file can be retained.
* Format - if not specified then the consumer will in all likelihood use the file extension / mime type
* Media Type
* Expiry Date - The date and time that this file expires and can be removed from the download URL
    location.  This is not the file retention period as might be required for archiving.
* Described By - A link to the metadata describing this file data and format
* Compression - Type of compression used if any
* Encryption - Type of encryption used if any


## Compression

Files can be compressed using a utility.  A single compressed file can contain
multiple files.  The **martiLQ** definition document applies to the compressed file 
and not to the contents, which could be multiple files.

In the case of a compressed files, there should be a **martiLQ** definition document in the
compressed file.  

Compression of files always occur before encryption.

### martiLQ definition for Compressed File

For a compressed file that is not encrypted, the distribution definition will be:

* Title - The compressed file title which could be a group name
* Document name - Commonly being absolute or relative file name.
    This value could also be an URL address or network path
* Issued date - When the compressed file was made available. 
* Modified - When the compressed file was created or modified.  This is the date and time
    and is not the modified date of the file in the compressed file.
* Size of file - The compressed file size in bytes
* Hash of file - The hash of the compressed file, which can be 
    blank especially for large files
* Hash algorithm

The reason for this approach is it allows a generic tool to be deployed to
check the validity of the contents without unpacking the received /fetched
file.  That is you can perform load quality pipeline processing.

## Encryption

The encryption of content is always applied after compression not before, if
you are not using the compression tool native encryption.  WinZIP and 7ZIP
provide encryption within the tool execution.

If the compression is TAR or GZIP then you may consider applying a GPG
or other encryption algorithm to the compressed file.

* Title - The encrypted file title 
* Document name - Commonly being absolute or relative file name.
    This value could also be an URL address or network path
* Issued date - When the **encrypted** file was made available. 
* Modified - When the **encrypted** file was created or modified.  
    This is the data and time and is not the modified date of the encrypted file.
* Size of file - The **decrypted** file size in bytes
* Hash of file - The hash of the **decrypted** file, which can be 
    blank especially for large files
* Hash algorithm

The rational for using the decrypted file attributes is that an ecrypted
file is unlikely to be able to be modified without knowing encryption keys.
Checking the decrypted fille attributes is a better check.

The reason for this approach is it allows a generic tool to be deployed to
decrypt and check the validity of the received / fetched file without
needing to understand the contents.  That is you can perform load quality
pipeline processing.
