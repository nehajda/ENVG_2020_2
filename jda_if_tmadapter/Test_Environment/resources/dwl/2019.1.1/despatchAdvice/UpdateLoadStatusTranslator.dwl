/**
 * ==========================================================================
 *                      Copyright 2020, Blue Yonder Group, Inc.
 *                                All Rights Reserved
 *
 *                   THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF
 *                              Blue Yonder Group, Inc.
 *
 *
 *               The copyright notice above does not evidence any actual
 *                    or intended publication of such source code.
 *
 *  ==========================================================================
 */

%dw 2.0
import modules::TMAUtilsModule as tmUtils
output application/xml skipNullOn="everywhere", encoding = "utf-8"
---
EVENT : {
	EVENT_DATA : 
			UpdateLoadStatus :(payload..despatchAdviceMessage.*despatchAdvice filter($.despatchAdviceTransportInformation.routeID != null  and $.despatchAdviceTransportInformation.routeID != "" and $.documentActionCode != "DELETE" and $.*despatchAdviceLogisticUnit.*despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.*transactionalReference[?($.transactionalReferenceTypeCode == "SRN")].entityIdentification[0] != null) map (currentEntity, index) ->
		using (loadDocument = (payload.EVENT.ENTITY_DATA.*Entity.Load filter ($.SystemLoadID == currentEntity.despatchAdviceTransportInformation.routeID))[0],
		inputArrivalDateTime = if(currentEntity.despatchAdviceTransportInformation.routeID == loadDocument.SystemLoadID) currentEntity.despatchInformation.loadingDateTime else null,
		shippingLocationCode = if(currentEntity.despatchAdviceTransportInformation.routeID == loadDocument.SystemLoadID)  currentEntity.shipFrom.additionalPartyIdentification else null,
		shippingLocationInformationDocument = (payload.EVENT.ENTITY_DATA.*Entity.*ShippingLocation filter ($.ShippingLocationCode == shippingLocationCode))[0],
		locationOffset = shippingLocationInformationDocument.BusinessHours.TimeZoneOffset,
		inputDepartureDateTime = (if(currentEntity.despatchAdviceTransportInformation.routeID == loadDocument.SystemLoadID) currentEntity.despatchInformation.actualShipDateTime else null),
		 mbolValue = (if(currentEntity.despatchAdviceTransportInformation.routeID == loadDocument.SystemLoadID and currentEntity.extension.jdaDespatchAdviceExtension.load.logisticServiceRequirementCode == "2") currentEntity.extension.jdaDespatchAdviceExtension.load.billOfLadingNumber.entityIdentification
		 	else if(currentEntity.despatchAdviceTransportInformation.routeID == loadDocument.SystemLoadID and currentEntity.extension.jdaDespatchAdviceExtension.load.logisticServiceRequirementCode == "3") currentEntity.despatchAdviceTransportInformation.billOfLadingNumber.entityIdentification
		 	else null
		 ),
		
						trailerLicenseNumber = if(currentEntity.documentActionCode != "DELETE") 
				 								currentEntity.avpList.*eComStringAttributeValuePairList[?($.@attributeName == "trailerLicenseNumber")]
				 							 else {},
						 tractorLicenseNumber = if(currentEntity.documentActionCode != "DELETE") 
							currentEntity.avpList.*eComStringAttributeValuePairList[?($.@attributeName == "truckLicenseNumber")]
						 	else {},
						 driverLicenseNumber =  if(currentEntity.documentActionCode != "DELETE") 
							currentEntity[0].avpList.*eComStringAttributeValuePairList[?($.@attributeName == "driverLicenseNumber")]
						 	else {},
						 tractorNum = if(currentEntity.documentActionCode != "DELETE") 
						 						currentEntity.despatchAdviceTransportInformation.transportMeansID
						 				   else null,
	 				     trailerNum = if(currentEntity.documentActionCode != "DELETE") 
	 				     					currentEntity.extension.jdaDespatchAdviceExtension.load.transportEquipment.individualAssetIdentification.*additionalIndividualAssetIdentification[?($.@additionalIndividualAssetIdentificationTypeCode == "OWNER_ASSIGNED")]
	 				     					else null
				) 
					 { 
				 		LoadStatusUpdateData : {
				 			SystemLoadID : loadDocument.SystemLoadID ,
							(if((loadDocument.*ReferenceNumberStructure filter ($.ReferenceNumberTypeCode == 'MB'))[0].ReferenceNumber == null and mbolValue != null) MasterBillOfLadingNumber : mbolValue else null),
                        	IDsAreReferenceNumbersFlag : false,
                        	TractorNumber : tractorNum,
                        	TrailerNumber : trailerNum,
							StopArrivalDepartureData: {
                        			(payload.EVENT.EVENT_DATA.despatchAdviceMessage.*despatchAdvice filter($.*despatchAdviceLogisticUnit.*despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.*transactionalReference[?($.transactionalReferenceTypeCode == "SRN")].entityIdentification[0] != null) map (currentDA, index) -> {
	//(payload.EVENT.ENTITY_DATA.*Entity.*Shipment filter (currentDA.despatchAdviceIdentification.entityIdentification == $.ShipmentNumber) map (currentShip, index) -> {
	(payload.EVENT.ENTITY_DATA.*Entity.*Shipment filter (((currentDA.*despatchAdviceLogisticUnit filter ($.levelIdentification == '4')).despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.*transactionalReference.entityIdentification) contains $.ShipmentNumber) map (currentShip, index) -> {
		(payload.EVENT.ENTITY_DATA.*Entity.Load.*Stop filter (currentShip.ShipFromLocationCode == $.ShippingLocationCode) map (currentLoad,index) -> {
			(currentLoad.*PickShipmentLegID filter ($ == currentShip.ShipmentLeg.SystemShipmentLegID) map () -> {
				StopSequenceNumber : currentLoad.StopSequenceNumber
				
			})
		})
	})	
	}),
                            		StopTypeEnumVal : "STR_PICKONLY",
                            		(if(inputArrivalDateTime != null) ArrivalDateTime : tmUtils::convertGs1DateToLocation(inputArrivalDateTime,locationOffset) else ArrivalDateTime : tmUtils::convertGs1DateToLocation(inputDepartureDateTime,locationOffset)),
                            		ArrivalEventCode: "DRVRCHKIN_",
                            		DepartureDateTime: tmUtils::convertGs1DateToLocation(inputDepartureDateTime,locationOffset),
                            		DepartureEventCode: "DRVRCHKOUT_"
                        	}
				 		}	
				 	}
			)
}