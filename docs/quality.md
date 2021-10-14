# Quality definition

The **martiLQ** definition allows for the inclusion of a load quality 
definition.  This load quality definition is intended to be
able to be applied universally with common tools.  As such not 
all needs are covered.

## Defined laod quality metrics


* Number of records in the document - This is the number of data primary records not the 
   count of end of lines and is agreed between parties.  XML record counts could be based 
   on the number of primary segments under root.  JSON records can be counted in a similar way.
   The headers or trailling records are not counted


Sequence number - linked to the job producing the document and therefore a daily, weekly and monthly extracts for the 
same document would have different sequence numbers

Discourage us of magic formats for document names such as

XT_PARTY_20210911_SQ00001_N000567891234_V01.DAT

Header and Trailer records are not part of the quality definition except

In fact the trailer record is intended to be replaced by this quality definition

The header, if it exists, is only used where it identifies the column name sequence of the data.

Effective and Process date -----------------

Row count - 
Column count -
Depth count - 

Mandatory - data must be present and cannot be blank or null
Uniqueness - data value must be unique within the document
Data integrity - data exists within defined tolerances 


row count 9999

column count 9999

column_name sum 9999

column_name gt 9999
column_name lt 9999
column_name eq 9999
column_name eq "  "
column_name ne 9999
column_name ne "  "    == Check for value
column_name ge 9999
column_name le "  "
column_name in "  ", " ", " "

column_name is integer
column_name is decimal
column_name is unique

