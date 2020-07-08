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
{
	CISDocument: {
		EntityType: 'ShipmentType',
		Select : {
			Name : 'Id',
			Name : 'SystemShipmentID',
			Name : 'ShipmentNumber',
			Name : 'ShipFromLocationCode',
			Name : 'CustomerCode',
			Name : 'ShipFromAppointmentRequiredFlag',
			Name : 'ShipToLocationTypeEnumVal',
			Name : 'ShipToLocationTypeEnumDescr',
			Name : 'ShipToLocationCode',
			Name : 'ShipToDescription',
			Name : 'PickupFromDateTime',
			Name : 'PickupToDateTime',
			Name : 'DeliveryFromDateTime',
			Name : 'DeliveryToDateTime',
			Name : 'CommodityCode',
			Name : 'DivisionCode',
			Name : 'ShipFromAddress',
			Name : 'LogisticsGroupCode',
			Name : 'ShipmentEntryModeEnumVal',
			Name : 'ShipmentPriority',
			Name : 'FreightTermsEnumVal',
			Name : 'ShipDirectFlag',
			Name : 'ShipmentConsolidationClassCode',
			Name : 'ShipFromLocationTypeEnumVal',
			Name : 'ShipFromLocationTypeEnumVal',
			Name : 'ShipFromAppointmentRequiredFlag',
			Name : 'ShipToAppointmentRequiredFlag',			
			Name : 'ShipToAddress',
			Name : 'CreatedDateTime',
			Name : 'UpdatedDateTime',
			Name : 'InputCurrencyCode',
			Name : 'CurrentShipmentOperationalStatusEnumVal',
			Name : 'CurrentShipmentOperationalStatusEnumDescr',
			Name : 'UnitOfMeasure',
			Name : 'ShippingInformation',
			Name : 'SystemLoadID',
			Name : 'ShipmentEntryTypeCode',
			Name : 'SplitShipmentNumber',
			Name : 'ItineraryTemplateCode',
			Name : 'EquipmentTypeCode',
			Name : 'PreferredAPCarrierCode',
			Name : 'PreferredAPServiceCode',
			Name : 'TractorEquipmentTypeCode',
			Name : 'ARServiceCode',
			Name : 'UrgentFlag',
			Name : 'MergeInTransitConsolidationCode',
			Name : 'MergeInTransitConsolidationNum',
			Name : 'INCOTermsCode',
			Name : 'BuyerSellerEnumVal',
			Name : 'INCOShippingLocationCode',
			Name : 'INCOShippingLocationTypeEnumVal',
			Name : 'DeferAPRatingFlag',
			Name : 'DeferARRatingFlag',
			Name : 'ItemGroupCode',
			Name : 'BookingMergeInTransitConsolidationCode',
			Name : 'HoldFlag',
			Name : 'ProfitCenterCode',
			Name : 'ShipmentEntryVersionCode',
			Name : 'SystemPlanID',
			Name : 'ShipmentDescription',
			Name : 'BillToCustomerCode',
			Name : 'Memo',
			Collection : {
				Name : 'ChargeOverrides'
			},
			Collection : {
				Name : 'ThroughPoint'
			},
			Collection : {
				Name : 'ShipmentLeg',
				Select : {
					Collection : {
						Name : 'Load.Stop',
						Select : {
							Name : 'ShippingLocationCode',
							Collection : {
								Name : 'ReferenceNumberStructure'
							}
						}
					},
					Name : 'SystemShipmentLegID',
					Name : 'SystemLoadID',
					Name : 'ShipmentSequenceNumber',
					Name : 'ShipFromLocationCode',
					Name : 'ShipToLocationCode',
					Name : 'Load.CurrentLoadOperationalStatusEnumVal',
					Name : 'ServiceCode'
				}
			},
			Collection : {
				Name : 'ReferenceNumberStructure'
			},
			Collection : {
				Name : 'Container',
				Select : {
					Name : 'Id',
					Name : 'SystemContainerID',
					Name : 'Quantity',
					Name : 'ItemNumber',
					Name : 'ItemPackageLevelIDCode',
					Name : 'ContentLevelTypeCode',
					Name : 'CarrierPackageType',
					Name : 'Length',
					Name : 'Height',
					Name : 'Width',
					Name : 'ContainerTypeCode',
					Name : 'ContainerShippingInformation',
					Collection : {
						Name : 'ReferenceNumberStructure'
					},
					Collection : {
						Name : 'WeightByFreightClass'
					},
					Collection : {
						Name : 'ShipmentItem'
					},
					(if (vars.isTransportOrderEnabled == 'true' or vars.isTransportOrderEnabled == true )
						({
						Name : 'TransportOrderInfo.SystemTransportOrderID',
						Name : 'TransportOrderInfo.OrderNumberCode',
						Name : 'TransportOrderInfo.OrderLineNumberCode',
						Name : 'TransportOrderInfo.SystemContainerID',
						Name : 'TransportOrderInfo.ShippingInformation',
						Name : 'TransportOrderInfo.ProductNumberCode'
					})
						else null)
				}
			}
		},
		Condition : {
		O : {
		Or : {
		 (payload..*Entity filter ($.EntityType == 'ShipmentType' and $.AvailableInCache == 'false') map (currentEntity, index) -> {
						(if(currentEntity.EntityId is Object and currentEntity.EntityId.OrderReferenceID != null and currentEntity.EntityId.ShipmentNumber != null)
						        		O :( In : {
												O:{
													Name : 'ShipmentNumber'
												},
												O:{
													Value: currentEntity.EntityId.ShipmentNumber
												},
												O:{
													Value: currentEntity.EntityId.OrderReferenceID
												}
											})
											else if((vars.isTransportOrderEnabled == 'true' or vars.isTransportOrderEnabled == true) and currentEntity.EntityId is Object and currentEntity.EntityId.ShipmentNumber != null and currentEntity.EntityId.MergeInTransitConsolidationCode == null)
										O : (
											In : {
												O:{
													Name : 'ShipmentNumber'
												},
												O:{
													Value: currentEntity.EntityId.ShipmentNumber
												}
											}
										)
										
										else {
                                            (if(currentEntity.EntityId is Object and (currentEntity.EntityId.SplitShipmentNumber != null))
                                                O : (
											In : {
												O:{
													Name : 'SplitShipmentNumber'
												},
												O:{
													Value: currentEntity.EntityId.SplitShipmentNumber
												}
											}
										)
                                            else if(currentEntity.EntityId is Object and (currentEntity.EntityId.ShipmentNumber != null and currentEntity.EntityId.MergeInTransitConsolidationCode != null))
                                        	O : {
                                        		Or : {
                                        			        O : {
													In : {
														O:{
															Name : 'ShipmentNumber'
														},
														O:{
															Value: currentEntity.EntityId.ShipmentNumber
														}
													}
										},
										O : {
													In : {
														O:{
															Name : 'MergeInTransitConsolidationCode'
														},
														O:{
															Value: currentEntity.EntityId.MergeInTransitConsolidationCode
														}
													}
										}
                                        		}	
                                        	}
									
										 else if(currentEntity.EntityId is Object and (currentEntity.EntityId.ShipmentNumber != null))
                                                O : (
											In : {
												O:{
													Name : 'ShipmentNumber'
												},
												O:{
													Value: currentEntity.EntityId.ShipmentNumber
												}
											}
										)
                                            else {
                                                (O:{
												Exists : {
												Name : 'ShipmentLeg',
												Condition:{
												O:{
													And:{
														O:{
															Eq:{
																O:{
																	Name : 'ShipmentNumber'
																},
																O:{
																	Value: currentEntity.EntityId
																}
															}
														}
													}
												}
													}
												}
											}),(O:{
													Eq:{
															O:{
																Name : 'ShipmentNumber'
															},
															O:{
																Value: currentEntity.EntityId
															}
													}
												}),
                                            (if(currentEntity.EntityId matches /^[0-9]*$/)
												(O:{
												Exists : {
													Name : 'ShipmentLeg',
													Condition:{
														O:{
															And:{
																O:{
																	Eq:{
																		O:{
																			Name : 'SystemShipmentLegID'
																		},
																		O:{
																			Value: currentEntity.EntityId
																		}
																	}
																}
															}
														}
													}
												}
												}) else null )
                                            })

																		
											
											})
											
		})
		}
		}
		}
		}
		}