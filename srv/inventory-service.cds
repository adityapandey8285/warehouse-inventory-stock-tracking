
using { warehouse.inventory as db } from '../db/schema';

@path: '/inventory'
service InventoryService {

    entity Plants as projection on db.Plants;

    entity StorageLocations as projection on db.StorageLocations;

    entity Materials as projection on db.Materials;

    @readonly
entity StockLevels {
    key material_ID        : UUID;
    key storageLocation_ID : UUID;

    materialCode           : String(40);
    materialName           : String(100);
    storageLocationCode    : String(40);

    currentStock           : Decimal(15,3);
    reorderLevel           : Decimal(15,3);

    stockStatus            : String(20);
    criticality            : Integer;
}

    @readonly
    entity StockMovements as projection on db.StockMovements {
        *,
        virtual movementCriticality : Integer
    };

    @requires: 'Clerk'
    action receive(
        materialId : UUID,
        storageLocationId : UUID,
        quantity : Decimal(15,3),
        movementDate : Timestamp,
        reference : String(100)
    ) returns StockMovements;

    @requires: 'Clerk'
    action issue(
        materialId : UUID,
        storageLocationId : UUID,
        quantity : Decimal(15,3),
        movementDate : Timestamp,
        reference : String(100)
    ) returns StockMovements;

    @requires: 'Clerk'
    action transfer(
        materialId : UUID,
        sourceLocationId : UUID,
        targetLocationId : UUID,
        quantity : Decimal(15,3),
        movementDate : Timestamp,
        reference : String(100)
    ) returns StockMovements;

    action getStock(
        materialId : UUID,
        storageLocationId : UUID
    ) returns Decimal(15,3);
}
