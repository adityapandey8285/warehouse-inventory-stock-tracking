using { warehouse.inventory as db } from '../db/schema';

@path: '/inventory'
service InventoryService {
    entity Plants as projection on db.Plants;
    entity StorageLocations as projection on db.StorageLocations;
    entity Materials as projection on db.Materials;

    @readonly
    entity StockMovements as projection on db.StockMovements;

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