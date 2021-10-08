# Why use marti

**marti** is a framework for providing a degree of auditability and reconciliation of
documents transferred between systems in an organisation and externally.  It does not intend
define the format or content of the document.  It defines controls that can be used to:

1. verify source
2. identify unauthorized alterations (tampering)
3. reconcile agreed metrics, such as the number of records
4. ensure sequential processing
5. describe metadata including format, extract time
6. link to further information

You would use **marti** if any of the controls are a requirement for you.

## Documents

Documents in this context are digital storage objects such as operating system files,
cloud storage objects or blobs.  The document content has structure and contains multiple
records.

The **marti** framework is not intended to be used for single record transfers such as 
in single web transactions.  It is for providing controls when moving large amounts of
data as one event.  This data are commonly referred to as batch extracts and performed 
at scheduled times such as end of day.

## Security

The framework does not replace your security, inflight encryption or encryption at rest.

You are encouraged to use TLS or SSH to connect devices and transfer documents.  Storage 
encryption and access controls for your documents is also relevant as part of the bigger 
picture.

See also:
1. [Who would use the framework](who.md)
2. [When to use the framework](when.md)
