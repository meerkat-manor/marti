# Who is likely to use martiLQ

You are likely to find the **martiLQ** framework relevant if you:

1. Have many document exchanges, such as End of Day batches
2. Need to verify or reconcile the documents

## Data exchanges

If you are creating or receiving many documents or files on a regular basis
then you probably have some framework defined.  The framework may be as simple as:

1. The files are placed in given folders that have significance, such as the source or topic
2. File names have a naming standard, such as subject domain and date of extract

Simple framework such as the above have limitations, such as:

* File names becoming long and need special parsing, with associated testing
* Risk of overwriting 
* New folders need to be created for new sources
* Require constant polling, if passive
* Lower automation prospects and alignment to DataSecOps
* Poor fit to web applications (they tend to be designed for FTP and LAN)

## Framework Sidecar files

The **martiLQ** framework addresses the issues and limitations by using sidecar
or shadow files. The [concept of sidecar files](https://en.wikipedia.org/wiki/Sidecar_file) is 
not new and are commonly found associated to media file processing.

Sidecar files can also be implemented as ``forks`` and built into the operating system, such as 
in Mac OS X HFS.  The Microsoft NTFS supports Alternate Data Streams to achieve a similar outcome.
Unfortunately this information is not transferrable to other systems. 

The proposition is to define a format for the sidecar file and provide common library tools that
can be be used on multiple platforms when exchanging documents / files.  Multiple documents can be 
defined in a single **martiLQ** definition which adds to efficiency and productivity if used 
for End of Day or similar batches - or even single file transfers.
