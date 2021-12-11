# Design pattern

## Abstract

**MartiLQ** defines a software pattern (document) for describing data files or documents generated from a source
and intended to be consumed by another system component with self-describing information with 
load assurance metrics.

The consuming system component can be at the same location, a dfifferent geographical location,
the same organisation or another organisation.

The pattern does not define the format that the data file or document must take or how the data is transferred
or accessed.  You choose the data format and transfer method. Once you have made the choice, you can describe
it in the **martiLQ** document.   

Describing the format and transfer can be tooled so that the mundane activity is automated and only
the specific nuance or additional assurance aspects need your attention.  Sample scripts are provided
to demonstrate generating the **martiLQ** document. 

## Name

**martiLQ** documentation standard

## Problem statement

Even though event streaming is a stragetic goal for many organisations, there exists legcay processes and there
will continue to be a need to transfer data flies and other documents from one system to another. 

When a handover of a data file or document occurs, the best practice is to include metrics with the transfer
to assure the recipient of provenance and quality of the data file or document.  This is the metadata associated
with the data file or document.

A document includes unstructered data, letters, pictures, binary objects while data files could be though of
as strutured data that is describes multiple records. 

### Assurance Problem

**How does the recipient know they have received all related files, the provenance, it is immutable and 
assurance on quality?**

Many organisations have used the file name as the carrier of this information but this has limits.

## Efficiency Problem

**How can the assurance be described so that it can be tooled and not rely on manual documentation
and custom tooling?** 

With the drive to DevSecOps or DataOps, any pattern that can be self describing or at least majority
self describing will improve documentation and quality of the process.  This boosts the efficiency 
of building, testing and maintaining the transfer of data files and documents. 

Therefore the objective is to produce a documentation standard that:

1. provides load assurance when transferring data files and documents
2. can be tooled and therefore achieve some level of automation 
3. is extensible to give the publisher and consumer control as to the level of assurance 
   required to match the risk appetite of the organisation

## Context

This pattern is intended to be applied when assurance is required on transferred data files and documents.
The data files or documents are commonly packaged together and the pattern is not intended for
real time event processing nor single record processing.  The pattern can be used on
single data file or document if each is considered independent and standalone. 

Packaging the related data files and documents is part of data integrity especially if 
referential integrity for foreign keys is required or the documents relate all to
the same case such as in workflow.

The assurance includes the following scope and this can be extended to meet changing conditions or 
changes in threats or risk.

### Assurance scope

The individual items below are not mandatory but are provided as part of the standard definition
as they are considered the minimal for best practice

* Provenance
* Immutable
* Data period or timeline
* Sequence or batch
* Status and expiry date
* Link to data file or document
* Format, encoding, compression
* Data record count

There is an acknowledgment processs that is recommended for confirmation on processing.  See 
[acknowldegment](docs/source/acknowledgement.md) for approach details.

## Forces

The qualities that this pattern is addressing...

The file transfer pattern is the original method for separate processes to exchange data.  The file being stored on magnetic tape and either 
loaded back onto the same compute resource (think mainframe) or physicaly couriered to another lcoation or tape drive.  The
reference book [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/patterns/messaging/FileTransferIntegration.html) 
by Hohpe and Woolf recognises this by inculsion of the pattern written by Martin Fowler.

This pattern addresess the issues and concerns that relate to file transfer. Many of these are related the the common 
non functional requirements that architects cover in solution designs.

### Security, robustness, reliability, fault-tolerance

The pattern defines how security and assurance is applied to the data files and documents.  The pattern does 
not define how to setup a reliable infrastructure, but it can be used to detect failures
in the infrastructire.  The fault-tolerance allowance is up to each implementation.

Fault-tolerance and the actionable task can be dialled from 0% tolerance to 100% tolerance on a
case by case basis. 

### Manageability

### Efficiency, performance, throughput, bandwidth requirements, space utilization

### Scalability (incremental growth on-demand)

The pattern scalability is not bound to the size of the data files themselves.  The pattern can 
be scaled to include thousands of data files or documents, though the practically of processing
may be factor in the decision of breaking down to smaller volumes.

### Extensibility, evolvability, maintainability

The **martiLQ** document can be customised and can evolve as the market conidtions change.  Versioning
is built into the definition and consumers can select which attributes are mandatory for
processing. 

### Modularity, independence, re-usability, openness, composability (plug-and-play), portability

### Completeness and correctness

### Ease-of-construction

### Ease-of-use

## Solution



A description, using text and/or graphics, of how to achieve the intended goals and objectives. The description should identify both the solution's static structure and its dynamic behavior - the people and computing actors, and their collaborations. The description may include guidelines for implementing the solution. Variants or specializations of the solution may also be described.

## Resulting Context



The post-conditions after the pattern has been applied. Implementing the solution normally requires trade-offs among competing forces.
This element describes which forces have been resolved and how, and which remain unresolved. It may also indicate other patterns that may be applicable in the new context. (A pattern may be one step in accomplishing some larger goal.) Any such other patterns will be described in detail under Related Patterns.

## Examples

Please refer to the [documentation](docs/source/README.md) and [samples](docs/source/samples/README.md)

## Rationale

An explanation/justification of the pattern as a whole, or of individual components within it, indicating how the pattern actually works, and why - how it resolves the forces to achieve the desired goals and objectives, and why this is "good". The Solution element of a pattern describes the external structure and behavior of the solution: the Rationale provides insight into its internal workings.

## Related Patterns

The relationships between this pattern and others. These may be predecessor patterns, whose resulting contexts correspond to the initial context of this one; or successor patterns, whose initial contexts correspond to the resulting context of this one; or alternative patterns, which describe a different solution to the same problem, but under different forces; or co-dependent patterns, which may/must be applied along with this pattern.

## Known Uses

Known applications of the pattern within existing systems, verifying that the pattern does indeed describe a proven solution to a recurring problem. Known Uses can also serve as Examples.
