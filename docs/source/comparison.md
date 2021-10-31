# Comparison of martiLQ document definition

The use of metadata definitions is not unique and examples
exist in many different situations.  Some are standard and open
while others are closed.

Some open standards are EXIF data for pictures, SQL DDL defintions
for databases, the XMP definition and web header responses before the 
web content.

The **martiLQ** document definition is intended to cover the situation
where data files are being transferred and reconciliation is required.

The **martiLQ** document definition is modelled on 
the [CKAN API metadata](https://docs.ckan.org/en/2.9/api/index.html)
which has been adapted to included additional elements relevant to when
you are exchanging data files.  This includes the reconciliation elements
such as number of records and file hash.

As the definition is based on the CKAN API, there are tools to import
a CKAN source into a **martiLQ** document definition and then process the data
through the pipeline as you would for any other data file that had a
**martiLQ** document definition.

## Benefit of CKAN and martiLQ

The CKAN is excellent at defining the data source details but it lacks information
for load quality.  If you have CKAN deployed in your organisation and wish
exhange or process the data referenced in CKAN, then there are synergies between
CKAN and marti.

Samples exist on CKAN integration.

## Magda and martiLQ

Another source of data is [Magda](https://magda.io/) which has API metadata
definitions.  Magda is more about data federation and as such provides
functionality on finding data sources and describing the contents.

The Magda software is able to generate APIs and data content.  This does not 
address the needs of data processing pipeline when reconciliation is required.

If you have Magda data sources then synergies exist between Magda and martiLQ.
