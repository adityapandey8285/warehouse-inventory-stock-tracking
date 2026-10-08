namespace warehouse.inventory;

using { cuid, managed } from '@sap/cds/common';

type MovementType : String(10) enum {
    RECEIPT;
    ISSUE;
    TRANSFER;
}

@assert.unique: {
    plantCode: [plantCode]
}
entity Plants : cuid, managed {
    plantCode : String(10) not null;
    plantName : String(100) not null;
}

@assert.unique: {
    locationCode: [locationCode]
}
entity StorageLocations : cuid, managed {
    locationCode : String(10) not null;
    locationName : String(100) not null;
    plant : Association to Plants not null;
}

@assert.unique: {
    materialCode: [materialCode]
}
entity Materials : cuid, managed {
    materialCode : String(20) not null;
    materialName : String(100) not null;
    description : String(500);
    unitOfMeasure : String(10) not null;
    unitPrice : Decimal(15,2) not null;
    reorderLevel : Decimal(15,3) not null;
    active : Boolean default true;
}

entity StockMovements : cuid, managed {
    movementType : MovementType not null;
    material : Association to Materials not null;
    quantity : Decimal(15,3) not null;
    movementDate : Timestamp not null;
    reference : String(100) not null;
    storageLocation : Association to StorageLocations;
    sourceLocation : Association to StorageLocations;
    targetLocation : Association to StorageLocations;
}