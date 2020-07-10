/**
 * ==========================================================================
 *                      Copyright 2020, Blue Yonder Group, Inc.
 *                                All Rights Reserved
 *
 *                   THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF
 *                              BLUE YONDER GROUP, INC.
 *
 *
 *               The copyright notice above does not evidence any actual
 *                    or intended publication of such source code.
 *
 *  ==========================================================================
 */
%dw 2.0
output application/xml
ns sh http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader
ns despatch_advice urn:gs1:ecom:despatch_advice:xsd:3
---
{(
	despatch_advice#despatchAdviceMessage @("xmlns:sh":"http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"
	   ,"xsi:schemaLocation":"urn:gs1:ecom:despatch_advice:xsd:3 ../Schemas/gs1/ecom/DespatchAdvice.xsd",
	   "xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance"):
	{
		 sh#StandardBusinessDocumentHeader:
		{
				sh#HeaderVersion: payload..StandardBusinessDocumentHeader.HeaderVersion,
				sh#Sender: payload..StandardBusinessDocumentHeader.Sender,
				(payload..StandardBusinessDocumentHeader.*Receiver map ( receiver , indexOfReceiver ) -> {
					  sh#Receiver: {
							 sh#Identifier @(Authority: "ENTERPRISE"): receiver.Identifier
					  }
				}),
				sh#DocumentIdentification: payload..StandardBusinessDocumentHeader.DocumentIdentification,
				sh#BusinessScope: {
					  sh#Scope: {
							 sh#Type: payload..StandardBusinessDocumentHeader.BusinessScope.Scope.'Type',
                             sh#InstanceIdentifier: vars.msMessageVersion,
							 sh#Identifier: payload..StandardBusinessDocumentHeader.BusinessScope.Scope.Identifier
					  }
				}
		},
        
		({
		(payload.despatchAdviceMessage.*despatchAdvice map(currentDA, index)
		 -> using (totLogisticUnit = currentDA.*despatchAdviceLogisticUnit filter ((item, index) -> (item.levelIdentification == '4')),
		 totTransactionalSrn = totLogisticUnit.*despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.*transactionalReference,
		 totTmsShipment =totTransactionalSrn distinctBy ((value, index) -> {"unique": value.entityIdentification})
		 )
		 {(
			if(totTmsShipment == null){
			 despatchAdvice:{
                 creationDateTime: currentDA.creationDateTime,
                 documentStatusCode: currentDA.documentStatusCode,
                 documentActionCode: currentDA.documentActionCode,
                 avpList:{
						eComStringAttributeValuePairList @(attributeName: "orderReferenceType", qualifierCodeList: "TransportReferenceTypeCode"):"TO",
						eComStringAttributeValuePairList @(attributeName: "customerReference"):totLogisticUnit.despatchAdviceLineItem.customerReference.entityIdentification[0]
						},
				despatchAdviceIdentification:currentDA.despatchAdviceIdentification,
				receiver: currentDA.receiver,
				shipper: currentDA.shipper,
				buyer: currentDA.buyer,
				seller: currentDA.seller,
				shipTo: currentDA.shipTo,
				shipFrom: currentDA.shipFrom,
				carrier: currentDA.carrier,
				despatchInformation: currentDA.despatchInformation,
			despatchAdviceTransportInformation:
			{
			 routeID:currentDA.despatchAdviceTransportInformation.routeID,
			 shipmentIdentification:currentDA.despatchAdviceTransportInformation.shipmentIdentification,
			 carrierTrackAndTraceInformation:currentDA.despatchAdviceTransportInformation.carrierTrackAndTraceInformation,
			 },
			 ( currentDA.*despatchAdviceLogisticUnit filter ($.levelIdentification == '2' ) map(currentDespatchAdviceLogisticUnit, indexOfespatchAdviceLogisticUnit) ->
			 using (
						currentSubLPNUnit = currentDA.*despatchAdviceLogisticUnit[?(($.levelIdentification == '3') and $.avpList.eComStringAttributeValuePairList == currentDespatchAdviceLogisticUnit.logisticUnitIdentification.additionalLogisticUnitIdentification)],
						currentSubLPN = currentSubLPNUnit.logisticUnitIdentification.additionalLogisticUnitIdentification[0],
						detailLpn = currentDA.*despatchAdviceLogisticUnit[?(($.levelIdentification == '4') and ($.avpList.eComStringAttributeValuePairList == currentSubLPN))]
					)
			 {( if(detailLpn != null and sizeOf(detailLpn) > 0)
				{   despatchAdviceLogisticUnit:currentDespatchAdviceLogisticUnit,
					despatchAdviceLogisticUnit:currentSubLPNUnit,
					({
					( detailLpn map(dtlLpn,idx) ->{
						despatchAdviceLogisticUnit:{
							levelIdentification: dtlLpn.levelIdentification,
						parentLevelIdentification: dtlLpn.parentLevelIdentification,
								logisticUnitIdentification: dtlLpn.logisticUnitIdentification,
								avpList: dtlLpn.avpList,
								 despatchAdviceLineItem: 
								using ( currentDALineItemExtension = dtlLpn.despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension)
								{
									lineItemNumber: dtlLpn.despatchAdviceLineItem.lineItemNumber,
									despatchedQuantity: dtlLpn.despatchAdviceLineItem.despatchedQuantity,
									extension: {
										"jda_despatch_advice_line_item_extension:jdaDespatchAdviceLineItemExtension" 
										@("xmlns:jda_despatch_advice_line_item_extension":"jda_despatch_advice_line_item_extension:xsd:3",
										"xmlns:ext_xsi":"http://www.w3.org/2001/XMLSchema-instance",
										"ext_xsi:schemaLocation":"urn:jda:ecom:jda_despatch_advice_line_item_extension:xsd:3 ../Schemas/jda/ecom/JdaDespatchAdviceLineItemExtension.xsd"):
										{
											subLineIdentifier: currentDALineItemExtension.subLineIdentifier,
											isCustomsBondRequired: currentDALineItemExtension.isCustomsBondRequired,
											isDutyProcessingRequired: currentDALineItemExtension.isDutyProcessingRequired,
											isInventoryOnHold: currentDALineItemExtension.isInventoryOnHold,
											fifoDate: currentDALineItemExtension.fifoDate,
											logisticUnitConfigurationName: currentDALineItemExtension.logisticUnitConfigurationName,
											inventoryStatusCode: currentDALineItemExtension.inventoryStatusCode,
											(catchQuantity @(measurementUnitCode: currentDALineItemExtension.catchQuantity.@measurementUnitCode): currentDALineItemExtension.catchQuantity) if (currentDALineItemExtension.catchQuantity != null),
											itemOwner: currentDALineItemExtension.itemOwner,
											supplierIdentifier: currentDALineItemExtension.supplierIdentifier
										}
									},
									transactionalTradeItem: dtlLpn.despatchAdviceLineItem.transactionalTradeItem,
									customerReference: dtlLpn.despatchAdviceLineItem.customerReference,
									avpList: dtlLpn.despatchAdviceLineItem.avpList
								}
							}
						})
					})
				} else null)}
				)}
		 }else{(
				( totTmsShipment.*entityIdentification map(currTmShipment,idx)->{
					 despatchAdvice:
					 {
								creationDateTime: currentDA.creationDateTime,  
								documentStatusCode: currentDA.documentStatusCode,
								documentActionCode: currentDA.documentActionCode,
								avpList: {
								eComStringAttributeValuePairList @(attributeName: "orderReferenceType", qualifierCodeList: "TransportReferenceTypeCode"):"TO",
								eComStringAttributeValuePairList @(attributeName: "customerReference"):totLogisticUnit[?($.*despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.transactionalReference.entityIdentification[0] ==currTmShipment )][0].despatchAdviceLineItem.customerReference.entityIdentification
                                },
								despatchAdviceIdentification:{
                                    entityIdentification:currTmShipment
                                },
								receiver: currentDA.receiver,
								shipper: currentDA.shipper,
								buyer: currentDA.buyer,
								seller: currentDA.seller,
								shipTo: currentDA.shipTo,
								shipFrom: currentDA.shipFrom,
								carrier: currentDA.carrier,
								despatchInformation: currentDA.despatchInformation,
								despatchAdviceTransportInformation:
								{
								 routeID:currentDA.despatchAdviceTransportInformation.routeID,
								 shipmentIdentification:
									{
										 gsin:currentDA.despatchAdviceTransportInformation.shipmentIdentification.gsin,
										 additionalShipmentIdentification @(additionalShipmentIdentificationTypeCode: "SHIPPER_ASSIGNED"):currTmShipment,
									},
								carrierTrackAndTraceInformation:currentDA.despatchAdviceTransportInformation.carrierTrackAndTraceInformation
									
								},
						 ( currentDA.*despatchAdviceLogisticUnit filter ($.levelIdentification == '2' ) map(currentDespatchAdviceLogisticUnit, indexOfespatchAdviceLogisticUnit) ->
						 using (
									currentSubLPNUnit = currentDA.*despatchAdviceLogisticUnit[?(($.levelIdentification == '3') and $.avpList.eComStringAttributeValuePairList == currentDespatchAdviceLogisticUnit.logisticUnitIdentification.additionalLogisticUnitIdentification)],
									currentSubLPN = currentSubLPNUnit.logisticUnitIdentification.additionalLogisticUnitIdentification[0],
									detailLpn = currentDA.*despatchAdviceLogisticUnit[?(($.levelIdentification == '4') and ($.avpList.eComStringAttributeValuePairList == currentSubLPN) and ($.despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.transactionalReference.entityIdentification == currTmShipment))]
								)
						 {( if(detailLpn != null and sizeOf(detailLpn) > 0)
							{   despatchAdviceLogisticUnit:currentDespatchAdviceLogisticUnit,
								despatchAdviceLogisticUnit:currentSubLPNUnit,
								({
								( detailLpn map(dtlLpn,idx) ->{
                                    despatchAdviceLogisticUnit:{
                                        levelIdentification: dtlLpn.levelIdentification,
                                    parentLevelIdentification: dtlLpn.parentLevelIdentification,
	             							logisticUnitIdentification: dtlLpn.logisticUnitIdentification,
	             							avpList: dtlLpn.avpList,
                                             despatchAdviceLineItem: 
	             							using ( currentDALineItemExtension = dtlLpn.despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension)
	             							{
	             								lineItemNumber: dtlLpn.despatchAdviceLineItem.lineItemNumber,
	             								despatchedQuantity: dtlLpn.despatchAdviceLineItem.despatchedQuantity,
	             								extension: {
	             									"jda_despatch_advice_line_item_extension:jdaDespatchAdviceLineItemExtension" 
	             									@("xmlns:jda_despatch_advice_line_item_extension":"jda_despatch_advice_line_item_extension:xsd:3",
             										"xmlns:ext_xsi":"http://www.w3.org/2001/XMLSchema-instance",
	             									"ext_xsi:schemaLocation":"urn:jda:ecom:jda_despatch_advice_line_item_extension:xsd:3 ../Schemas/jda/ecom/JdaDespatchAdviceLineItemExtension.xsd"):
	             									{
	             										subLineIdentifier: currentDALineItemExtension.subLineIdentifier,
	             										isCustomsBondRequired: currentDALineItemExtension.isCustomsBondRequired,
	             										isDutyProcessingRequired: currentDALineItemExtension.isDutyProcessingRequired,
	             										isInventoryOnHold: currentDALineItemExtension.isInventoryOnHold,
	             										fifoDate: currentDALineItemExtension.fifoDate,
	             										logisticUnitConfigurationName: currentDALineItemExtension.logisticUnitConfigurationName,
	             										inventoryStatusCode: currentDALineItemExtension.inventoryStatusCode,
	             										(catchQuantity @(measurementUnitCode: currentDALineItemExtension.catchQuantity.@measurementUnitCode): currentDALineItemExtension.catchQuantity) if (currentDALineItemExtension.catchQuantity != null),
	             										itemOwner: currentDALineItemExtension.itemOwner,
	             										supplierIdentifier: currentDALineItemExtension.supplierIdentifier
	             									}
	             								},
	             								transactionalTradeItem: dtlLpn.despatchAdviceLineItem.transactionalTradeItem,
	             								customerReference: dtlLpn.despatchAdviceLineItem.customerReference,
	             								avpList: dtlLpn.despatchAdviceLineItem.avpList
	             							}
										}
									})
								})
							} else null)}
						)}
					})
				)}
			)}
		)}
	)}
)}
