
using InventoryService as service from '../../srv/inventory-service';

annotate service.StockMovements with @(
    UI.HeaderInfo: {
        TypeName: 'Stock Movement',
        TypeNamePlural: 'Stock Movements',
        Title: {
            $Type: 'UI.DataField',
            Value: reference
        },
        Description: {
            $Type: 'UI.DataField',
            Value: movementType
        }
    },

    UI.SelectionFields: [
        movementType,
        movementDate,
        reference,
        material_ID,
        storageLocation_ID
    ],

    // Hide generic CRUD Create. Use the validated business actions instead.
    UI.CreateHidden: true,

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Label: 'Reference',
            Value: reference
        },
        {
            $Type: 'UI.DataField',
            Label: 'Movement Type',
            Value: movementType,
            Criticality: movementCriticality
        },
        {
            $Type: 'UI.DataField',
            Label: 'Material Code',
            Value: material.materialCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Material',
            Value: material.materialName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Quantity',
            Value: quantity
        },
        {
            $Type: 'UI.DataField',
            Label: 'Unit',
            Value: material.unitOfMeasure
        },
        {
            $Type: 'UI.DataField',
            Label: 'Storage Location',
            Value: storageLocation.locationCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Source',
            Value: sourceLocation.locationCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Destination',
            Value: targetLocation.locationCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Movement Date',
            Value: movementDate
        },
        {
            $Type: 'UI.DataFieldForAction',
            Action: 'InventoryService.receive',
            Label: 'Receive Stock',
            InvocationGrouping: #Isolated
        },
        {
            $Type: 'UI.DataFieldForAction',
            Action: 'InventoryService.issue',
            Label: 'Issue Stock',
            InvocationGrouping: #Isolated
        },
        {
            $Type: 'UI.DataFieldForAction',
            Action: 'InventoryService.transfer',
            Label: 'Transfer Stock',
            InvocationGrouping: #Isolated
        }
    ],

    UI.Facets: [
        {
            $Type: 'UI.ReferenceFacet',
            ID: 'MovementDetails',
            Label: 'Movement Details',
            Target: '@UI.FieldGroup#MovementDetails'
        }
    ],

    UI.FieldGroup #MovementDetails: {
        $Type: 'UI.FieldGroupType',
        Data: [
            {
                $Type: 'UI.DataField',
                Label: 'Reference',
                Value: reference
            },
            {
                $Type: 'UI.DataField',
                Label: 'Movement Type',
                Value: movementType,
                Criticality: movementCriticality
            },
            {
                $Type: 'UI.DataField',
                Label: 'Quantity',
                Value: quantity
            },
            {
                $Type: 'UI.DataField',
                Label: 'Movement Date',
                Value: movementDate
            },
            {
                $Type: 'UI.DataField',
                Label: 'Created At',
                Value: createdAt
            }
        ]
    }
);

annotate service.StockMovements with {
    material @Common.ValueList: {
        $Type: 'Common.ValueListType',
        CollectionPath: 'Materials',
        Parameters: [
            {
                $Type: 'Common.ValueListParameterInOut',
                LocalDataProperty: material_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'materialCode'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'materialName'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'unitOfMeasure'
            }
        ]
    };

    storageLocation @Common.ValueList: {
        $Type: 'Common.ValueListType',
        CollectionPath: 'StorageLocations',
        Parameters: [
            {
                $Type: 'Common.ValueListParameterInOut',
                LocalDataProperty: storageLocation_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'locationCode'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'locationName'
            }
        ]
    };

    sourceLocation @Common.ValueList: {
        $Type: 'Common.ValueListType',
        CollectionPath: 'StorageLocations',
        Parameters: [
            {
                $Type: 'Common.ValueListParameterInOut',
                LocalDataProperty: sourceLocation_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'locationCode'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'locationName'
            }
        ]
    };

    targetLocation @Common.ValueList: {
        $Type: 'Common.ValueListType',
        CollectionPath: 'StorageLocations',
        Parameters: [
            {
                $Type: 'Common.ValueListParameterInOut',
                LocalDataProperty: targetLocation_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'locationCode'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'locationName'
            }
        ]
    }
};

annotate service.Materials with @(
    UI.HeaderInfo: {
        TypeName: 'Material',
        TypeNamePlural: 'Materials',
        Title: {
            $Type: 'UI.DataField',
            Value: materialCode
        },
        Description: {
            $Type: 'UI.DataField',
            Value: materialName
        }
    },

    UI.SelectionFields: [
        materialCode,
        materialName,
        active
    ],

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Label: 'Material Code',
            Value: materialCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Material Name',
            Value: materialName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Unit',
            Value: unitOfMeasure
        },
        {
            $Type: 'UI.DataField',
            Label: 'Unit Price',
            Value: unitPrice
        },
        {
            $Type: 'UI.DataField',
            Label: 'Reorder Level',
            Value: reorderLevel
        },
        {
            $Type: 'UI.DataField',
            Label: 'Active',
            Value: active
        }
    ]
);

annotate service.Plants with @(
    UI.HeaderInfo: {
        TypeName: 'Plant',
        TypeNamePlural: 'Plants',
        Title: {
            $Type: 'UI.DataField',
            Value: plantCode
        },
        Description: {
            $Type: 'UI.DataField',
            Value: plantName
        }
    },

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Label: 'Plant Code',
            Value: plantCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Plant Name',
            Value: plantName
        }
    ]
);

annotate service.StorageLocations with @(
    UI.HeaderInfo: {
        TypeName: 'Storage Location',
        TypeNamePlural: 'Storage Locations',
        Title: {
            $Type: 'UI.DataField',
            Value: locationCode
        },
        Description: {
            $Type: 'UI.DataField',
            Value: locationName
        }
    },

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Label: 'Location Code',
            Value: locationCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Location Name',
            Value: locationName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Plant',
            Value: plant.plantCode
        }
    ]
);

annotate service.StockLevels with @(
    UI.HeaderInfo: {
        TypeName: 'Stock Level',
        TypeNamePlural: 'Stock Levels',
        Title: {
            $Type: 'UI.DataField',
            Value: materialCode
        },
        Description: {
            $Type: 'UI.DataField',
            Value: materialName
        }
    },

    UI.SelectionFields: [
        materialCode,
        materialName,
        storageLocationCode,
        stockStatus
    ],

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Label: 'Material Code',
            Value: materialCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Material Name',
            Value: materialName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Storage Location',
            Value: storageLocationCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Current Stock',
            Value: currentStock,
            Criticality: criticality
        },
        {
            $Type: 'UI.DataField',
            Label: 'Reorder Level',
            Value: reorderLevel
        },
        {
            $Type: 'UI.DataField',
            Label: 'Stock Status',
            Value: stockStatus,
            Criticality: criticality
        }
    ]
);