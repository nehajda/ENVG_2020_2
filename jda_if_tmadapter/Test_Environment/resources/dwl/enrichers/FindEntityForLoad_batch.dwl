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
output application/xml encoding = 'utf-8'

var productPickRefNum = (
	p('tms.defaults.shipmentStatus.productPicked')
)


var stockAllocatedRefNum = (
	 p('tms.defaults.shipmentStatus.stockAllocated')
)

---
CISDocument
: { 
	EntityType : 'LoadType',
	Select : {
	Name :'Id',
	Name :'SystemLoadID',
	Name :'LoadDescription',
	Name :'TotalVolume',
	Name :'TotalPieces',
	Name :'TotalSkids',
	Name :'CurrentLoadOperationalStatusEnumVal',
	Name :'CurrentLoadOperationalStatusEnumDescr',
	Name :'CreatedDateTime',
	Name :'UpdatedDateTime',
	Name :'EquipmentTypeCode',
	Name :'TrailerNumber',
	Name :'CarrierCode',
	Name :'ServiceCode',
	Name :'NumberOfStops',
	Name :'CommodityCode',
	Name :'TotalNumberOfShipments',
	Name :'TotalTotalPieces',
	Name :'TotalTotalPallets',
	Name :'LengthUnitOfMeasureEnumVal',
	Name :'WeightUnitOfMeasureEnumVal',
	Name :'TotalScaledWeight',
	Name :'SystemTripID',
	Name :'LogisticsGroupCode',
	Name :'LoadStartDateTime',
	Name :'LoadEndDateTime',
	Collection : {
	Name : 'ReferenceNumberStructure'
	 },
	   (if ((payload..Entities.*Entity filter ($.AdditionalFilters.GetShipmentDetails == 'true') default 0) != 0)
	          ({
				Collection : {
				Name : 'ShipmentLeg',
				Select : {
				Name : 'Shipment.SystemShipmentID',
				Name : 'Shipment.ShipmentNumber',
				Name : 'Shipment.ShipFromLocationCode',
				Name : 'Shipment.CustomerCode',
				Name : 'Shipment.ShipFromAppointmentRequiredFlag',
				Name : 'Shipment.ShipToLocationTypeEnumVal',
				Name : 'Shipment.ShipToLocationTypeEnumDescr',
				Name : 'Shipment.ShipToLocationCode',
				Name : 'Shipment.ShipToDescription',
				Name : 'Shipment.PickupFromDateTime',
				Name : 'Shipment.PickupToDateTime',
				Name : 'Shipment.DeliveryFromDateTime',
				Name : 'Shipment.DeliveryToDateTime',
				Name : 'Shipment.CommodityCode',
				Name : 'Shipment.ShipFromAddress',
				Name : 'Shipment.ShipToAddress',
				Name : 'Shipment.CreatedDateTime',
				Name : 'Shipment.UpdatedDateTime',
				Name : 'Shipment.InputCurrencyCode',
				Name : 'Shipment.CurrentShipmentOperationalStatusEnumVal',
				Name : 'Shipment.CurrentShipmentOperationalStatusEnumDescr',
				Name : 'Shipment.UnitOfMeasure',
				Name : 'Shipment.ShippingInformation',
				Name : 'Shipment.SplitShipmentNumber',
				Name : 'Shipment.NumberOfShipmentLegs',
				Collection : {
				Name : 'Shipment.ShipmentLeg',
				Select : {
				Name :'SystemShipmentLegID',
				Name :'ShipmentNumber',
				Name :'SystemLoadID',
				Name :'ShipmentSequenceNumber',
				Name :'ShipFromLocationCode',
				Name :'ShipToLocationCode'
				}
				},
				Name :'SystemShipmentLegID',
				Name :'SystemLoadID',
				Name :'ShipmentSequenceNumber',
				Name :'ShipFromLocationCode',
				Name :'ShipToLocationCode',
				Name :'Skids',
				Collection : {
				Name : 'Shipment.Container',
				Select : {
				Name : 'Id',
				Name : 'SystemContainerID',
				Name : 'Quantity',
				Name : 'ItemNumber',
				Name : 'ContainerShippingInformation.Volume',
				Name : 'ContainerShippingInformation.NominalWeight',
				Name : 'ContainerShippingInformation.Pieces',
				Name : 'ContainerShippingInformation.Skids',
				Collection : {
					Name : 'ReferenceNumberStructure'
				},
				Collection : {
				Name : 'WeightByFreightClass'
				},
				Collection : {
				Name : 'ShipmentItem'
				},
				(if (vars.isTransportOrderEnabled == 'true') ({Name : 'TransportOrderInfo.SystemTransportOrderID',
					Name : 'TransportOrderInfo.OrderNumberCode',
					Name : 'TransportOrderInfo.OrderLineNumberCode',
					Name : 'TransportOrderInfo.OrderConsolidationGroupID',
					Name : 'TransportOrderInfo.ProductNumberCode',
					Name : 'TransportOrderInfo.ShippingInformation'}) else null)
				}
				},
				//(if (vars.isTransportOrderEnabled != 'true') ({Collection : {Name : 'Shipment.ReferenceNumberStructure'}}) else null)
				Collection : {
				Name : 'Shipment.ReferenceNumberStructure',
				Select : {
                    Name :'SystemReferenceNumberID',
                    Name :'ReferenceNumberTypeCode',
                    Name :'ReferenceNumberTypeCodeDescr',
                    Name :'ReferenceNumber'
                }
				},
				},
				(if((payload..Entities.*Entity[?($.AdditionalFilters.GetWavedShipments != null)] default "") != "") 
				
				
				({Condition : {
				O : {
				Or : {
				O : {
				Exists : {
				Name : 'Shipment.ReferenceNumberStructure',
				Condition : {
				O : {
				And : {
				O : {
				Eq : {
				O : {
				Name : 'ReferenceNumberTypeCode'
				},
				O : {
				Value : 'WM_SHIPMENT'
				}
				}
				},
				O : {
				In : {
				O : {
				Name : 'ReferenceNumber'
				},
				O : {
				Value : stockAllocatedRefNum
				},
				O : {
				Value : productPickRefNum
				}
				}
				}
				}
				}
				}
				}
				}
				}
				}
				}}) else null)
				}
			    }) else null),
				
				Collection : {
				Name : 'Stop',
				Select : {
				Collection : {
				Name : 'PickShipmentLegID'
				},
				Collection : {
				Name : 'DropShipmentLegID'
				},
				Collection : {
				Name : 'ReferenceNumberStructure'
				},
				Name : 'Id',
				Name : 'SystemStopID',
				Name : 'StopSequenceNumber',
				Name : 'CountOfShipmentsPickedAtStop',
				Name : 'CountOfShipmentsDroppedAtStop',
				Name : 'ShippingLocationTypeEnumVal',
				Name : 'ShippingLocationTypeEnumDescr',
				Name : 'PickConfirmedFlag',
				Name : 'Address',
				Name : 'ShippingLocationCode',
				Name : 'PrimaryShippingLocationCode',
				Name : 'PrimaryShippingLocationTypeEnumVal',
				Name : 'PrimaryShippingLocationTypeEnumDescr',
				Name : 'WeekendHolidayBreakHours',
				Name : 'WeekendHolidayBreakOrientationEnumVal',
				Name : 'LoadingInstructionExistFlag',
				Name : 'PickedWeight',
				Name : 'PickedVolume',
				Name : 'PickedOrderValue',
				Name : 'PickedDeclaredValue',
				Name : 'PickedNominalWeight',
				Name : 'PickedTareWeight',
				Name : 'PickedPieces',
				Name : 'PickedSkids',
				Name : 'PickedLadenLength',
				Name : 'DroppedWeight',
				Name : 'DroppedVolume',
				Name : 'DroppedOrderValue',
				Name : 'DroppedDeclaredValue',
				Name : 'DroppedNominalWeight',
				Name : 'DroppedTareWeight',
				Name : 'DroppedPieces',
				Name : 'DroppedSkids',
				Name : 'DroppedLadenLength',
				Name : 'DistanceFromPreviousStop',
				Name : 'TransitTimeFromPreviousStop',
				Name : 'WaitingHours',
				Name : 'LoadingHours',
				Name : 'UnloadingHours',
				Name : 'CustomerCode',
				Name : 'CustomerName',
				Name : 'DockScheduleStatusEnumVal',
				Name : 'DockScheduleStatusEnumDescr',
				Name : 'ShippingLocationName',
				Name : 'AppointmentRequiredCounter',
				Name : 'LastComputedArrivalDateTime',
				Name : 'LastComputedDepartureDateTime',
				Name : 'StopStatusEnumVal',
				Name : 'StopStatusEnumDescr',
				Name : 'Appointment',
				Name : 'DeliveryArrivalDateTime'
				}},
				Name:'LoadSequenceNumber',
			    Name:'Trip.SystemTripID',
			    Name:'Trip.NumberOfLoads'
				},
				Condition : {
				O : {
				Or : {
				(payload..Entities.*Entity filter($.EntityType == 'LoadType' and $.AvailableInCache == 'false') map (currentEntity, index) ->
				(O : {
				Eq : {
				O : {
				Name : 'SystemLoadID'
				},
				O : {
				Value : currentEntity.EntityId
				}
				}
				}))
				}
				}
				}
  }
