
namespace warehouse.inventory;

using { cuid, managed } from '@sap/cds/common';

entity Plants : cuid, managed {
    plantCode : String(20) not null;
    plantName : String(100) not null;
}

entity StorageLocations : cuid, managed {
    locationCode : String(20) not null;
    locationName : String(100) not null;

    plant : Association to Plants not null;
}

entity Materials : cuid, managed {
    materialCode : String(30) not null;
    materialName : String(100) not null;
    description : String(500);
    unitOfMeasure : String(10) not null;
    unitPrice : Decimal(15,2) default 0;
    reorderLevel : Decimal(15,3) default 0;
    active : Boolean default true;
}

entity StockMovements : cuid, managed {
    movementType : String(10) not null;

    material : Association to Materials not null;

    quantity : Decimal(15,3) not null;
    movementDate : Timestamp not null;
    reference : String(100);

    storageLocation : Association to StorageLocations;
    sourceLocation : Association to StorageLocations;
    targetLocation : Association to StorageLocations;
}
