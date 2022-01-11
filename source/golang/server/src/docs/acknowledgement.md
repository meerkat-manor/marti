# Acknowledgment

Once the **martiLQ** document is received by a consumer then communicating the receipt, processing,
success or failure completes the feedback loop and builds an extra layer of assurance for the organization.

The acknowledgement workflow provides the necessary feedback.  If an acknowledgement is required as part of the 
consumption design then the following is approach is recommended.

1. The publisher provides callback details.  For extra security the callback  details should be signed.
2. The consumer will acknowledge the receipt of the **martiLQ** document by sending back the same
   document to the publisher with some values changed.
3. Change the root consumer and state (not resource) from ``active`` to ``receipt`` and modify the ``stateModified`` timestamp.
4. Change the ``consumer`` data value to only be your identifier and not others, so that the publisher
   can identify the consumer and associate it with success or failure.  This change to consumer value
   applies to all subsequent acknowledgement messages. 
5. Send the changed **martiLQ** document back using the callback details
6. On fetching each resource the resource state is changed from ``active`` to ``received`` and modify the ``stateModified`` timestamp.  
   If any resource cannot be retrieved the state is changed from ``active`` to ``missing`` and ``stateModified`` timestamp is udpated.
7. The consumer can elect to send back the **martiLQ** document to the publisher on each fetch or at the completion
   of all fetches.  The recommendation is to send at the end of all fetches because if there are issues then
   having all the failures for analysis should assist in determining the extent of the failure.
8. Once all resources are fetched (or failed), the root state is changed from ``receipt`` to ``received`` and update the ``stateModified`` 
   timestamp if no errors occurred in retrieving the resources. If a single or many errors occurred, then the root state is
   changed from ``receipt`` to ``missing`` and the ``stateModified`` timestamp is updated.  The updated document is sent back 
   to the publisher using the callback details.
9. The next stage is to validate and process the resources defined in the **martiLQ** document.  This follows
   a similar process to fetching the resources.
10. On processing each resource the resource state is changed from ``received`` to ``processed`` and modify the ``stateModified`` timestamp.  
   If any resource cannot be processed the state is changed from ``received`` to ``error`` and update the ``stateModified`` timestamp.  Once 
   again this can be acknowledged back to the publisher.
11. Once all resources are processed (or failed), the root state is changed from ``received`` to ``processed`` and the ``stateModified`` timestamp
   updated if no errors occurred in processing the resources. If a single or many errors occurred, then the root state is
   changed from ``received`` to ``error`` and the ``stateModified`` timestamp modified.  The updated document is sent back to the publisher using 
   the callback details.

This completes the acknowledgment workflow for the **martiLQ** document.  The level of acknowledgement feedback
you wish to implement as a consumer is your decision.  Any publisher providing callback details for acknowledgement can also
choose their behavior on actions and recording any acknowledgments received.

In the above acknowledgement process, you **must not** change the identifiers in the **martiLQ** document and you **should not**
change other data except the ``consumer`` and ``state`` and ``stateModified``.

If you are the publisher and expect acknowledgment then there is an extra scenario you need to cater for.  The scenario is
that you do not receive any acknowledgement back from the expected consumer(s) within the agreed time frame.  In this situation
the publisher will need to know each consumer and their service level agreements.

## Callback

The callback method can take any form.  The normal expectation is that the same method used to communicate the **martiLQ** 
document is used for the callback for example:

* If the **martiLQ** document is originally sent by Kafka queue then the callback should use a Kafka queue separate topic
* If the **martiLQ** document is originally sent by REST API then the callback is a publisher REST API end point
* If the **martiLQ** document is originally sent by email then the callback uses a reply address for the callback

While the above is the expected convention, you can mix and match.  For example:

* If the **martiLQ** document is originally sent by REST API then the callback can be an email address.  This 
  situation could be acceptable if the publisher does not have the ability to accept REST API call backs.

## Compressed file handling

When the **martiLQ** document is defining a parent compressed file, e.g. ZIP or 7Z, then the resources are expected
to be in the compressed file.  These resources can still be checked for existence and that they can be extracted.  The
state of the resource is still changed to reflect the processing.

If the file cannot be extracted either because it has not been included or there is a decompression error, then the
same acknowledgement process of using the state is used.
