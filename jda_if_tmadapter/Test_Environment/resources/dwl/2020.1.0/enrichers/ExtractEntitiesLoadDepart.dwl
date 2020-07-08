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
output application/xml encoding = "utf-8"
---
EVENT : ({
		(Enrichment : {
			EntityTypes : {
				EntityType : 'LoadType',
				EntityType : 'ShippingLocationType',
				EntityType @(allowEmptyResponse : true) : 'ShipmentType'
			},
			Entities : {				
			(payload.EVENT.EVENT_DATA.despatchAdviceMessage.*despatchAdvice filter($.*despatchAdviceLogisticUnit.*despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.*transactionalReference[?($.transactionalReferenceTypeCode == "SRN")].entityIdentification[0] != null)  map ( currentEntity , indexOfcurrentEntity ) -> 
				using(loadId=currentEntity.despatchAdviceTransportInformation.routeID) {
				Entity : {
					EntityType : 'LoadType',
					EntityId : loadId,
					SystemLoadId: loadId,
					AvailableInCache : 'false',
					AdditionalFilters : ''
				},
				((currentEntity.*despatchAdviceLogisticUnit filter ($.levelIdentification == '4' or $.levelIdentification =='9')) map (currentLineItem,indexOfCurrentLineItem) -> {
					Entity : {
					EntityType : 'ShipmentType',
					EntityId : {
						(if (vars.isTransportOrderEnabled == 'false') ({ (OrderReferenceID : currentLineItem.despatchAdviceLineItem.customerReference.entityIdentification)}) else null),
						ShipmentNumber : (currentLineItem.despatchAdviceLineItem.extension.jdaDespatchAdviceLineItemExtension.*transactionalReference filter ($.transactionalReferenceTypeCode == 'SRN')).entityIdentification
					},
					SystemLoadId: loadId,
					AvailableInCache : 'false',
					AdditionalFilters : ''
					},
				}),				
				Entity : {
					EntityType : 'ShippingLocationType',
					EntityId : currentEntity.shipFrom.additionalPartyIdentification,
					AvailableInCache : 'false',
					AdditionalFilters : ''
				},
				Entity : {
					EntityType : 'ShippingLocationType',
					EntityId : currentEntity.shipTo.additionalPartyIdentification,
					AvailableInCache : 'false',
					AdditionalFilters : ''
				}
				})
				
			}
		})	
	}) ++ payload.EVENT