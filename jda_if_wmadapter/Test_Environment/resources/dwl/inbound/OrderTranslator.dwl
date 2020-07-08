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
ns order urn:gs1:ecom:order:xsd:3
fun contact(contact)= contact: (contact map (currentContact, index) -> {
	
	((shipAttentionName: currentContact.personName) if (currentContact.contactTypeCode == 'MGR')),
	((shipAttentionPhoneNumber: currentContact.*communicationChannel.communicationValue) if (currentContact.contactTypeCode == 'MGR' and currentContact.communicationChannel.communicationChannelCode == 'TELEPHONE' )),
	
	((firstName: (currentContact.personName splitBy ' ')[0]) if (currentContact.contactTypeCode == 'NT')),
	((lastName: (currentContact.personName splitBy ' ')[1]) if (currentContact.contactTypeCode == 'NT')),
	((faxnum: currentContact.*communicationChannel[?($.communicationChannelCode == "TELEFAX")][0].communicationValue) if (currentContact.contactTypeCode == 'NT')),
	((webAddress: currentContact.*communicationChannel[?($.communicationChannelCode == "WEBSITE")][0].communicationValue) if (currentContact.contactTypeCode == 'NT')),
	((pageNumber: currentContact.*communicationChannel[?($.communicationChannelCode == "PAGER")][0].communicationValue) if (currentContact.contactTypeCode == 'NT')),
	((phnum: currentContact.*communicationChannel[?($.communicationChannelCode == "TELEPHONE")][0].communicationValue) if (currentContact.contactTypeCode == 'NT')),
	((email: currentContact.*communicationChannel[?($.communicationChannelCode == "EMAIL")][0].communicationValue) if (currentContact.contactTypeCode == 'NT')),
	
	((attentionName: currentContact.personName)  if (currentContact.contactTypeCode == 'PM')),
	((attentionTelephone: currentContact.*communicationChannel[?($.communicationChannelCode == "TELEPHONE")][0].communicationValue) if (currentContact.contactTypeCode == 'PM')),
	
	((faxNumber: currentContact.*communicationChannel[?($.communicationChannelCode == "TELEFAX")][0].communicationValue) if (currentContact.contactTypeCode == 'SD')),
	((telephoneNumber: currentContact.*communicationChannel[?($.communicationChannelCode == "TELEPHONE")][0].communicationValue) if (currentContact.contactTypeCode == 'SD')),
	((emailAddress: currentContact.*communicationChannel[?($.communicationChannelCode == "EMAIL")][0].communicationValue) if (currentContact.contactTypeCode == 'SD')),
	((shipWebAddress: currentContact.*communicationChannel[?($.communicationChannelCode == "WEBSITE")][0].communicationValue) if (currentContact.contactTypeCode == 'SD')),
	
	((shipContactName: currentContact.personName)  if (currentContact.contactTypeCode == 'WH')),
	((jobTitle: currentContact.jobTitle)  if (currentContact.contactTypeCode == 'WH')),
	((shipContactTelephone: currentContact.*communicationChannel[?($.communicationChannelCode == "TELEPHONE")][0].communicationValue) if (currentContact.contactTypeCode == 'WH')),
	
	((personName: currentContact.personName)  if (currentContact.contactTypeCode == 'OC')),
	((contactTitle: currentContact.jobTitle)  if (currentContact.contactTypeCode == 'OC')),
	((contactPhoneNumber: currentContact.*communicationChannel[?($.communicationChannelCode == "TELEPHONE")][0].communicationValue) if (currentContact.contactTypeCode == 'OC')),
	
	
}) reduce ((value,accumulator) -> accumulator ++ value) 

fun seller(seller)=({
	seller:{
		additionalPartyIdentification: { 
			value : seller.additionalPartyIdentification
		}
	}
		
})

fun buyer(buyer)=({
	buyer: {
		additionalPartyIdentification: {
        	value: buyer.additionalPartyIdentification
       	}
    }
})

---
{
       
       order#orderMessage @("xmlns:sh":"http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"
       ,"xsi:schemaLocation":"urn:gs1:ecom:order:xsd:3 ../Schemas/gs1/ecom/Order.xsd",
       "xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance"):
       {
             sh#StandardBusinessDocumentHeader: payload.orderMessage.StandardBusinessDocumentHeader,
             (payload.orderMessage.*order map(currentOrder, indexOfOrder) -> 
             	using(orderExtension=currentOrder.extension.jdaOrderExtension,orderavplist = currentOrder.*avpList.*eComStringAttributeValuePairList)
             	{
             	order: {
             		creationDateTime: currentOrder.creationDateTime,  
             		documentStatusCode: currentOrder.documentStatusCode,
             		documentActionCode: currentOrder.documentActionCode,
             		lastUpdateDateTime: currentOrder.lastUpdateDateTime,
             		extension:{
             			jdaOrderExtension: {
             				createTransportOrder: orderExtension.createTransportOrder,
             				orderSubType: orderExtension.orderSubType,
             				orderStatus: orderExtension.orderStatus,
             				routeVia: {
             					addressIdentifier: orderExtension.routeVia.addressIdentifier,
             					addressType: orderExtension.routeVia.addressType,
             					isTemporaryAddress: orderExtension.routeVia.isTemporaryAddress,
             					areGeographicalCoordinatesOverridden: orderExtension.routeVia.areGeographicalCoordinatesOverridden,
             					isResidentialAddress: orderExtension.routeVia.isResidentialAddress,
             					addressDistrict: orderExtension.routeVia.addressDistrict,
             					addressRegion: orderExtension.routeVia.addressRegion,
             					honorific: orderExtension.routeVia.honorific,
             					rtcust: orderExtension.routeVia.additionalPartyIdentification,
             					(if (orderExtension.routeVia.*contact != null )contact(orderExtension.routeVia.*contact) else null),
             					rtAddress: orderExtension.routeVia.address,
             					rtAdditionalPartyIdentification: {
             						rtAdditionalPartyIdentificationTypeCode: orderExtension.routeVia.additionalPartyIdentification.@additionalPartyIdentificationTypeCode,
             						rtValue: orderExtension.routeVia.additionalPartyIdentification
             					}
             					
             				},
             				broker: {
             					addressIdentifier: orderExtension.broker.addressIdentifier,
             					brAdditionalPartyIdentification: {
             						brAdditionalPartyIdentificationTypeCode: orderExtension.broker.additionalPartyIdentification.@additionalPartyIdentificationTypeCode,
             						brValue: orderExtension.broker.additionalPartyIdentification
             					}
             				},
             				shipTo: orderExtension.shipTo,
             				billTo: orderExtension.billTo,
             				purchaseOrder: orderExtension.purchaseOrder,
             				purchaseOrderType: orderExtension.purchaseOrderType,
             				returnMaterialsAuthorizationNumber: orderExtension.returnMaterialsAuthorizationNumber,
             				customsDutyCustomer: orderExtension.customsDutyCustomer,
             				dutyPaymentAccount: orderExtension.dutyPaymentAccount,
             				dutyPaymentResponsibleParty: orderExtension.dutyPaymentResponsibleParty,
             				customsOrderType: orderExtension.customsOrderType,
             				exciseDutyCustomer: orderExtension.exciseDutyCustomer,
             				cashOnDeliveryType: orderExtension.cashOnDeliveryType,
             				cashOnDeliveryPaymentType: orderExtension.cashOnDeliveryPaymentType,
             				customerDepartmentIdentifier: orderExtension.customerDepartmentIdentifier,
             				customerDestinationIdentifier: orderExtension.customerDestinationIdentifier,
             				combineOrdersBy: orderExtension.combineOrdersBy,
             				defaultOrderLineChangeReason: orderExtension.defaultOrderLineChangeReason,
             				plannedOrderSequence: orderExtension.plannedOrderSequence,
             				orderConsolidationGroup: orderExtension.orderConsolidationGroup,
             				transportPaymentMethodTypeCode: orderExtension.transportPaymentMethodTypeCode,
             				(orderExtension.*orderNote map(currentOrderNote, indexOfOrderNote) -> {
								orderNote: {
									lineNumber: currentOrderNote.lineNumber,
									text: currentOrderNote.text,
									'type': currentOrderNote.'type',
									ordnum: currentOrder.orderIdentification.entityIdentification ,
									wh_id: currentOrder.orderLogisticalInformation.shipFrom.additionalPartyIdentification,
									client_id: currentOrder.seller.additionalPartyIdentification 
								}
							}),
             				demandChannel: orderExtension.demandChannel,
             				isCarrierChangeEnabled: orderExtension.isCarrierChangeEnabled,
             				isReleaseRemainingLinesEnabled: orderExtension.isReleaseRemainingLinesEnabled,
             				isOrderWaveable: orderExtension.isOrderWaveable,
             				isConsigneeBilled: orderExtension.isConsigneeBilled,
             				isSignatureRequired: orderExtension.isSignatureRequired,
             				isFreightBilled: orderExtension.isFreightBilled,
             				isCustomsClearanceExpedited: orderExtension.isCustomsClearanceExpedited,
             				groupOrderIdentification: orderExtension.groupOrderIdentification,
             				laneGroupIdentification: orderExtension.laneGroupIdentification,
             				routeTemplate: orderExtension.routeTemplate,
             				shipmentServiceLevelCode: orderExtension.shipmentServiceLevelCode,
             				isDirectShipment: orderExtension.isDirectShipment,
             				isUrgentShipment: orderExtension.isUrgentShipment,
             				shipmentConsolidationClass: orderExtension.shipmentConsolidationClass,
             				mitccCode: orderExtension.mitccCode,
             				mitccSequence: orderExtension.mitccSequence,
             				bookingMitccCode: orderExtension.bookingMitccCode,
             				incotermsBuyerSellerRelationship: orderExtension.incotermsBuyerSellerRelationship,
             				incotermsShippingLocation: orderExtension.incotermsShippingLocation,
             				incotermsShippingLocationType: orderExtension.incotermsShippingLocationType,
             				isApRatingDeferred: orderExtension.isApRatingDeferred,
             				isArRatingDeferred: orderExtension.isArRatingDeferred,
             				isShippingOriginProfileRefreshed: orderExtension.isShippingOriginProfileRefreshed,
             				isShippingDestinationProfileRefreshed: orderExtension.isShippingDestinationProfileRefreshed,
             				itemFamilyGroup: orderExtension.itemFamilyGroup,
             				allowChangeAfterShipmentAssignment: orderExtension.allowChangeAfterShipmentAssignment,
             				declaredValueForCustoms @(currencyCode: orderExtension.declaredValueForCustoms.@currencyCode): orderExtension.declaredValueForCustoms,
             				totalLoadingLength @(measurementUnitCode: orderExtension.totalLoadingLength.@measurementUnitCode): orderExtension.totalLoadingLength,
             				transportEquipment: orderExtension.transportEquipment,
             				shipmentThroughPoint: orderExtension.shipmentThroughPoint,
             				orderServiceId: orderExtension.defaultServiceDefinition.identifier,
             				orderServiceReqFlg: orderExtension.defaultServiceDefinition.isServiceRequired,
             				orderServiceRateId: orderExtension.defaultServiceDefinition.rateIdentifier,
             				orderDefIdentifier: orderExtension.defaultServiceDefinition.defaultServiceIdentifier,
             				orderRateServiceName: orderExtension.defaultServiceDefinition.ratingService,
             				serviceConditionIdentifier: orderExtension.serviceConditionIdentifier,
             				carrierServiceType: orderExtension.carrierServiceType,
             				requiresTransportPlanning: orderExtension.requiresTransportPlanning,
             				profitCenterType: orderExtension.profitCenterType,
             				shipmentEntryTypeIdentifier: orderExtension.shipmentEntryTypeIdentifier,
             				shipmentEntryVersionIdentifier: orderExtension.shipmentEntryVersionIdentifier,
             				planIdentifier: orderExtension.planIdentifier,
             				freightRate @(currencyCode: orderExtension.freightRate.@currencyCode): orderExtension.freightRate,
             				chargeOverride: orderExtension.chargeOverride,
             				tmCustomerCode: orderExtension.tmCustomerCode,
             				holdShipment: orderExtension.holdShipment,
             				shipFrom: orderExtension.shipFrom,
             				tmReferenceNumber: orderExtension.tmReferenceNumber,
             				description: orderExtension.description
             			}
             		},
             		avpList: {
             			(currentOrder.avpList.*eComStringAttributeValuePairList map(currentAVP, indexOfAVP) -> 
             				{
             				
             					(currentAVP.@attributeName) : currentAVP
             				})
             		},
             		orderIdentification: { 
             			entityIdentification: currentOrder.orderIdentification.entityIdentification,
             			contentOwner: {
             				gln: currentOrder.orderIdentification.contentOwner.gln,
             				additionalPartyIdentification @(additionalPartyIdentificationTypeCode: "UNKNOWN"):currentOrder.orderIdentification.contentOwner.additionalPartyIdentification,
             			},
             		},
             		orderTypeCode: currentOrder.orderTypeCode,
             		totalMonetaryAmountIncludingTaxes @(currencyCode: currentOrder.totalMonetaryAmountIncludingTaxes.@currencyCode):currentOrder.totalMonetaryAmountIncludingTaxes,
             		(buyer(currentOrder.buyer)),
             		(seller(currentOrder.seller)),
             		billTo: {
             			btcust: currentOrder.billTo.additionalPartyIdentification,
             			(if (currentOrder.billTo.*contact != null )contact(currentOrder.billTo.*contact) else null),
             			btAddress: currentOrder.billTo.address,
             			btAdditionalPartyIdentification: {
             				btAdditionalPartyIdentificationTypeCode: currentOrder.billTo.additionalPartyIdentification.@additionalPartyIdentificationTypeCode,
             				btValue: currentOrder.billTo.additionalPartyIdentification
             			}
             		},
             		orderLogisticalInformation:{
             			shipFrom: {
             				sfcust: currentOrder.orderLogisticalInformation.shipFrom.additionalPartyIdentification,
             				(if (currentOrder.orderLogisticalInformation.shipFrom.*contact != null ) contact(currentOrder.orderLogisticalInformation.shipFrom.*contact) else null),
             				sfAddress: currentOrder.orderLogisticalInformation.shipFrom.address,
             				sfAdditionalPartyIdentification: {
             					sfAdditionalPartyIdentificationTypeCode: currentOrder.orderLogisticalInformation.shipFrom.additionalPartyIdentification.@additionalPartyIdentificationTypeCode,
             					sfValue: currentOrder.orderLogisticalInformation.shipFrom.additionalPartyIdentification
             				}
             			},
             			shipTo: {
             				stcust: currentOrder.orderLogisticalInformation.shipTo.additionalPartyIdentification ,
             				(if (currentOrder.orderLogisticalInformation.shipTo.*contact != null ) contact(currentOrder.orderLogisticalInformation.shipTo.*contact) else null),
             				stAddress: currentOrder.orderLogisticalInformation.shipTo.address,
             				stAdditionalPartyIdentification: {
             					stAdditionalPartyIdentificationTypeCode: currentOrder.orderLogisticalInformation.shipTo.additionalPartyIdentification.@additionalPartyIdentificationTypeCode,
             					stValue: currentOrder.orderLogisticalInformation.shipTo.additionalPartyIdentification
             				}
             			},
             			orderLogisticalDateInformation: currentOrder.orderLogisticalInformation.orderLogisticalDateInformation,
             			shipmentTransportationInformation: currentOrder.orderLogisticalInformation.shipmentTransportationInformation,
             		},
             		deliveryTerms: currentOrder.deliveryTerms,
             		(currentOrder.*orderLineItem map(currentOrderLineItem, indexOfOrderLine) -> 
             			using (extensionOrderLineItem = orderExtension.*orderLineItem[?($.lineItemNumber == currentOrderLineItem.lineItemNumber)][0],
						check =(currentOrderLineItem.avpList.*eComStringAttributeValuePairList.@attributeName default []) contains "orderLinePriority")
             			{
             			
             			orderLineItem: {
             				lineItemNumber: currentOrderLineItem.lineItemNumber,
	             			requestedQuantity: currentOrderLineItem.requestedQuantity,
	             			lineItemActionCode: currentOrderLineItem.lineItemActionCode,
	             			monetaryAmountIncludingTaxes @(currencyCode: currentOrderLineItem.monetaryAmountIncludingTaxes.@currencyCode): currentOrderLineItem.monetaryAmountIncludingTaxes,
	             			transactionalTradeItem: currentOrderLineItem.transactionalTradeItem,
	             			orderLineItemDetail: {
	             				requestedQuantity : currentOrderLineItem.orderLineItemDetail.requestedQuantity,
	             				orderLogisticalInformation: {
	             					orderLogisticalDateInformation: {
	             						(if(currentOrderLineItem.orderLineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateRange != null )
	             						{
	             							requestedDeliveryDateRange: currentOrderLineItem.orderLineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateRange
	             						}
	             						else {
	             							requestedDeliveryDateRange: currentOrder.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateRange
	             						}),
	             						(if(currentOrderLineItem.orderLineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange != null )
	             						{
	             							requestedShipDateRange: currentOrderLineItem.orderLineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange
	             						}
	             						else {
	             							requestedShipDateRange: currentOrder.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange
	             						}),
	             					}
	             				}
	             			},
	             			avpList: 
                 if(check == true) 
                 (currentOrderLineItem.avpList mapObject {
                      (if ($.@attributeName == "orderLinePriority" and $ == null ) 
                                  (($.@attributeName):(orderavplist filter ($.@attributeName == "orderPriority"))[0]) 
                                  else  ($.@attributeName):$)
                 }) 
                 else 
                 ((currentOrderLineItem.avpList mapObject {
                     ($.@attributeName):$}) ++ 
                     ("orderLinePriority":(orderavplist filter ($.@attributeName == "orderPriority"))[0])) default {},
		             		subLineIdentifier: extensionOrderLineItem.subLineIdentifier,
	             			lotNumber: extensionOrderLineItem.lotNumber,
	             			overAllocationAmount: extensionOrderLineItem.overAllocationAmount,
	             			isOrderLineAllocatable: extensionOrderLineItem.isOrderLineAllocatable,
	             			isStandardCaseRequired: extensionOrderLineItem.isStandardCaseRequired,
	             			isBackOrderEnabled: extensionOrderLineItem.isBackOrderEnabled,
	             			alternateItemIdentifier: extensionOrderLineItem.alternateItemIdentifier.additionalTradeItemIdentification,
	             			reservationQuantity: extensionOrderLineItem.reservationQuantity,
	             			itemStatus: extensionOrderLineItem.itemStatus,
	             			isCaseSplittingAllowed: extensionOrderLineItem.isCaseSplittingAllowed,
	             			inventoryStatusProgression: extensionOrderLineItem.inventoryStatusProgression,
	             			requiresFreshnessProcessing: extensionOrderLineItem.requiresFreshnessProcessing,
	             			isOverShipAllowed: extensionOrderLineItem.isOverShipAllowed,
	             			inventorySelectionMethod: extensionOrderLineItem.inventorySelectionMethod,
	             			handlingAssetType: extensionOrderLineItem.handlingAssetType,
	             			allocationSearchPath: extensionOrderLineItem.allocationSearchPath,
	             			minimumShelfLife: extensionOrderLineItem.minimumShelfLife,
	             			timeMeasurementUnitCode: extensionOrderLineItem.minimumShelfLife.@timeMeasurementUnitCode,
	             			ownerOfTradeItem: extensionOrderLineItem.ownerOfTradeItem.additionalPartyIdentification,
	             			overAllocationCode: extensionOrderLineItem.overAllocationAmount.@overAllocationCode,
	             			manAddPartyCode: extensionOrderLineItem.manufacturerOfTradeItem.additionalPartyIdentification,
	             			pickGroup1: extensionOrderLineItem.*pickGroup[?($.@pickGroupNumber=='1')][0],
	             			pickGroup2: extensionOrderLineItem.*pickGroup[?($.@pickGroupNumber=='2')][0],
	             			pickGroup3: extensionOrderLineItem.*pickGroup[?($.@pickGroupNumber=='3')][0],
	             			pickGroup4: extensionOrderLineItem.*pickGroup[?($.@pickGroupNumber=='4')][0],
	             			supIdAddPartyCode: extensionOrderLineItem.supplierIdentifier.additionalPartyIdentification,
	             			absCode: extensionOrderLineItem.absoluteInventoryRotationWindow.@timeMeasurementUnitCode,
	             			absWindow: extensionOrderLineItem.absoluteInventoryRotationWindow,
	             			requiredRevisionLevel: extensionOrderLineItem.requiredRevisionLevel,
	             			marriedCode: extensionOrderLineItem.marriedCode,
	             			isPickQuantityRoundedUp: extensionOrderLineItem.isPickQuantityRoundedUp,
	             			carrierGroup: extensionOrderLineItem.carrierGroup,
	             			customerAccountIdentifier: extensionOrderLineItem.customerAccountIdentifier,
	             			customerProjectIdentifier: extensionOrderLineItem.customerProjectIdentifier,
	             			customerDepartmentIdentifier: extensionOrderLineItem.customerDepartmentIdentifier,
	             			unitsPerPack: extensionOrderLineItem.unitsPerPack,
	             			unitsPerPallet: extensionOrderLineItem.unitsPerPallet,
	             			unitsPerCase: extensionOrderLineItem.unitsPerCase,
	             			reservationPriority: extensionOrderLineItem.reservationPriority,
	             			destinationZone: extensionOrderLineItem.destinationZone,
	             			destinationSubLocation: extensionOrderLineItem.destinationSubLocation,
	             			itemConfigurationType: extensionOrderLineItem.itemConfigurationType,
	             			isItemAssembleToOrder: extensionOrderLineItem.isItemAssembleToOrder,
	             			logisticUnitConfigurationName: extensionOrderLineItem.logisticUnitConfigurationName,
	             			transportPaymentMethodTypeCode: extensionOrderLineItem.transportPaymentMethodTypeCode,
	             			allocationRuleName: extensionOrderLineItem.allocationRuleName,
	             			changeReasonComment: extensionOrderLineItem.changeReasonComment,
	             			isBlockingSlotLine: extensionOrderLineItem.isBlockingSlotLine,
	             			invoiceInvnum: extensionOrderLineItem.distribution.invoice.entityIdentification,
	             			invoiceInvlin: extensionOrderLineItem.distribution.invoice.lineItemNumber,
	             			disOrginalId: extensionOrderLineItem.distribution.originalDistributionIdentifier.entityIdentification,
	             			disSourceWarehouse: extensionOrderLineItem.distribution.sourceWarehouseIdentifier.address.name,
	             			disIdentifier: extensionOrderLineItem.distribution.identifier.entityIdentification,
	             			disSupIdAddPartyCode: extensionOrderLineItem.distribution.supplierIdentifier.additionalPartyIdentification,
	             			disSrcAddPartyCode: extensionOrderLineItem.distribution.sourceWarehouseIdentifier.additionalPartyIdentification,
	             			salesOrdernum: extensionOrderLineItem.salesOrder.entityIdentification,
	             			salesOrderLine: extensionOrderLineItem.salesOrder.lineItemNumber,
	             			salesCreationDate: extensionOrderLineItem.salesOrder.creationDateTime,
	             			olServiceConditionIdentifier: extensionOrderLineItem.serviceConditionIdentifier,
	             			olServiceIdentifier: extensionOrderLineItem.defaultServiceDefinition.identifier,
	             			olServiceRequired: extensionOrderLineItem.defaultServiceDefinition.isServiceRequired,
	             			olServiceRateIdentifier: extensionOrderLineItem.defaultServiceDefinition.rateIdentifier,
	             			olDefIdentifier: extensionOrderLineItem.defaultServiceDefinition.defaultServiceIdentifier,
	             			olRateServiceName: extensionOrderLineItem.defaultServiceDefinition.ratingService,
	             			waveSet: extensionOrderLineItem.waveSet,
	             			totalPlanCube: extensionOrderLineItem.totalCubeToPlan,
	             			totalPlanWeight: extensionOrderLineItem.totalWeightToPlan,
	             			totalPlanCaseQty: extensionOrderLineItem.totalCasesToPlan,
	             			totalPlanPalQty: extensionOrderLineItem.totalPalletsToPlan,
	             			isSaturdayDeliveryAllowed: extensionOrderLineItem.isSaturdayDeliveryAllowed,
							(if(currentOrderLineItem.avpList.*eComStringAttributeValuePairList[?($.@attributeName == 'returnReasonCode')][0] != null) returnReasonCode: currentOrderLineItem.avpList.*eComStringAttributeValuePairList[?($.@attributeName == 'returnReasonCode')][0] else null),
							(extensionOrderLineItem.*orderLineNote map(currentOrderLineNote, indexOfOrderLineNote) -> {
								orderLineNote: {
									lineNumber: currentOrderLineNote.lineNumber,
									text: currentOrderLineNote.text,
									'type': currentOrderLineNote.'type',
									ordnum: currentOrder.orderIdentification.entityIdentification ,
									wh_id: currentOrder.orderLogisticalInformation.shipFrom.additionalPartyIdentification,
									client_id: currentOrder.seller.additionalPartyIdentification 
								}
							}),
							allocationRule: extensionOrderLineItem.allocationRule,
							exportImport: extensionOrderLineItem.exportImport,
							distribution: {
								sourceOfDistribution: extensionOrderLineItem.distribution.sourceOfDistribution,
								promotionCode: extensionOrderLineItem.distribution.promotionCode,
								invoice: extensionOrderLineItem.distribution.invoice,
								inboundShipmentIdentifier: extensionOrderLineItem.distribution.inboundShipmentIdentifier,
								allowAllocateFromStorage: extensionOrderLineItem.distribution.allowAllocateFromStorage,
								originalDistributionIdentifier: extensionOrderLineItem.distribution.originalDistributionIdentifier,
								distributionType: extensionOrderLineItem.distribution.distributionType,
								invsln_identifier: extensionOrderLineItem.distribution.subLineIdentifier,
								supnum_distro: extensionOrderLineItem.distribution.supplierIdentifier.additionalPartyIdentification
							}
             			}
             		})
             	}
             })
       }
}