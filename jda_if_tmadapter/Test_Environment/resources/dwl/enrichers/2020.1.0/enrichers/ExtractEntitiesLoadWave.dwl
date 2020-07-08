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
var TMShipmentId=(
	payload.EVENT.EVENT_DATA.warehousingOutboundNotificationMessage.warehousingOutboundNotification.warehousingOutboundNotificationShipment.*transactionalReference.entityIdentification
)
---
(EVENT : ({
		(Enrichment : {
			EntityTypes : {
				EntityType: 'LoadType',
				(if (TMShipmentId != null) 
					({ 
						(EntityType : 'ShipmentType')
					}) 
					else null
				)
			},
			Entities : {
				Entity : {
					EntityType: 'LoadType',
					
					EntityId : payload.EVENT.EVENT_DATA.warehousingOutboundNotificationMessage.warehousingOutboundNotification.warehousingOutboundNotificationShipment.shipmentTransportationInformation.routeID,
					SystemLoadId: payload.EVENT.EVENT_DATA..routeID,
					AvailableInCache : 'false',
					AdditionalFilters : {
						GetShipmentDetails : 'true',
					     GetWavedShipments : 'true'
					}
				},	(if(TMShipmentId != null) 
					(
						(TMShipmentId map (currentTMShipmentId, index) ->
						{(
							Entity : {
							EntityType: 'ShipmentType',
							EntityId : currentTMShipmentId,
							SystemLoadId: payload.EVENT.EVENT_DATA..routeID,
							AvailableInCache : 'false',
							AdditionalFilters : ''
					    })}
					 )) 
					else null)
			}
		})	
	}) ++ payload.EVENT)