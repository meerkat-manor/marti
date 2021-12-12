# Load Quality

The **martiLQ** document allows for the inclusion of load quality 
metrics.  The load quality metrics is intended to be
able to be applied universally with common tools.  Not 
all needs are covered with the base definition but can be extended.

The load quality metrics are in the majority defined in the [attributes](attributes.md)
list attached to each resource.  Therefore each resource can have different
load quality metrics.

## Defined load quality metrics

* Sequential batch number - This is a decimal number defined at the **martiLQ** document
   header and applies to all resources.  The integer portion is for new batches and the fraction
   part can be used for issues with the same data extract.  such as requiring resend because
   a resource was missing.

* Number of records in the document - This is the number of data primary records not the 
   count of end of lines and is agreed between parties.  XML record counts could be based 
   on the number of primary segments under root.  JSON records can be counted in a similar way.
   The headers or trailing records are not counted

## Addresses deficiencies 

The **martiLQ** objective is to address deficiencies with alternative 
data load quality approaches such as:

 * magic formats in file names
 * identifying the number of files
 * knowing when all files are ready
 * separate documentation that is unlinked
 * securing the data
 * adding footers to the data, requiring custom file handlers

## Extending load quality metrics

**martLQ** document is open to extension so that extra
load metrics appropriate to the situation can be included.

### Extension ideas

The following extensions for load quality can easily be included:

  * Mandatory data in column
  * Uniqueness of data values 
  * Data values are within defined tolerances
  * Check for data exclusions

And all this information is included in the **martiLQ** document
allowing for self describing load quality.
