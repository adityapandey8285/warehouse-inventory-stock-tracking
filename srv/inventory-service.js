import cds from '@sap/cds';

async function getStock(materialId, storageLocationId) {
    const movements = await SELECT.from('warehouse.inventory.StockMovements')
        .columns(
            'movementType',
            'quantity',
            'storageLocation_ID',
            'sourceLocation_ID',
            'targetLocation_ID'
        )
        .where({
            material_ID: materialId
        });

    return movements.reduce((stock, movement) => {
        const quantity = Number(movement.quantity);

        if (
            movement.movementType === 'RECEIPT' &&
            movement.storageLocation_ID === storageLocationId
        ) {
            return stock + quantity;
        }

        if (
            movement.movementType === 'ISSUE' &&
            movement.storageLocation_ID === storageLocationId
        ) {
            return stock - quantity;
        }

        if (
            movement.movementType === 'TRANSFER' &&
            movement.sourceLocation_ID === storageLocationId
        ) {
            return stock - quantity;
        }

        if (
            movement.movementType === 'TRANSFER' &&
            movement.targetLocation_ID === storageLocationId
        ) {
            return stock + quantity;
        }

        return stock;
    }, 0);
}

export default cds.service.impl(function () {
    this.before(['UPDATE', 'DELETE'], 'StockMovements', req => {
        req.reject(
            400,
            'Stock movements cannot be edited or deleted. Create a new movement for corrections.'
        );
    });

    this.on('getStock', async req => {
        const { materialId, storageLocationId } = req.data;

        if (!materialId || !storageLocationId) {
            return req.reject(
                400,
                'Material and storage location are required.'
            );
        }

        const material = await SELECT.one
            .from('warehouse.inventory.Materials')
            .where({
                ID: materialId
            });

        if (!material) {
            return req.reject(404, 'Material not found.');
        }

        const location = await SELECT.one
            .from('warehouse.inventory.StorageLocations')
            .where({
                ID: storageLocationId
            });

        if (!location) {
            return req.reject(404, 'Storage location not found.');
        }

        return await getStock(materialId, storageLocationId);
    });

    this.on('receive', async req => {
        const {
            materialId,
            storageLocationId,
            quantity,
            movementDate,
            reference
        } = req.data;

        if (!quantity || quantity <= 0) {
            return req.reject(400, 'Quantity must be greater than zero.');
        }

        const material = await SELECT.one
            .from('warehouse.inventory.Materials')
            .where({
                ID: materialId
            });

        if (!material) {
            return req.reject(404, 'Material not found.');
        }

        const location = await SELECT.one
            .from('warehouse.inventory.StorageLocations')
            .where({
                ID: storageLocationId
            });

        if (!location) {
            return req.reject(404, 'Storage location not found.');
        }

        return INSERT.into('warehouse.inventory.StockMovements').entries({
            movementType: 'RECEIPT',
            material_ID: materialId,
            quantity,
            movementDate,
            reference,
            storageLocation_ID: storageLocationId
        });
    });

    this.on('issue', async req => {
        const {
            materialId,
            storageLocationId,
            quantity,
            movementDate,
            reference
        } = req.data;

        if (!quantity || quantity <= 0) {
            return req.reject(400, 'Quantity must be greater than zero.');
        }

        const material = await SELECT.one
            .from('warehouse.inventory.Materials')
            .where({
                ID: materialId
            });

        if (!material) {
            return req.reject(404, 'Material not found.');
        }

        const location = await SELECT.one
            .from('warehouse.inventory.StorageLocations')
            .where({
                ID: storageLocationId
            });

        if (!location) {
            return req.reject(404, 'Storage location not found.');
        }

        const availableStock = await getStock(
            materialId,
            storageLocationId
        );

        if (quantity > availableStock) {
            return req.reject(
                400,
                `Insufficient stock. Available stock: ${availableStock}.`
            );
        }

        return INSERT.into('warehouse.inventory.StockMovements').entries({
            movementType: 'ISSUE',
            material_ID: materialId,
            quantity,
            movementDate,
            reference,
            storageLocation_ID: storageLocationId
        });
    });

    this.on('transfer', async req => {
        const {
            materialId,
            sourceLocationId,
            targetLocationId,
            quantity,
            movementDate,
            reference
        } = req.data;

        if (!quantity || quantity <= 0) {
            return req.reject(400, 'Quantity must be greater than zero.');
        }

        if (sourceLocationId === targetLocationId) {
            return req.reject(
                400,
                'Source and target storage locations must be different.'
            );
        }

        const material = await SELECT.one
            .from('warehouse.inventory.Materials')
            .where({
                ID: materialId
            });

        if (!material) {
            return req.reject(404, 'Material not found.');
        }

        const sourceLocation = await SELECT.one
            .from('warehouse.inventory.StorageLocations')
            .where({
                ID: sourceLocationId
            });

        if (!sourceLocation) {
            return req.reject(404, 'Source storage location not found.');
        }

        const targetLocation = await SELECT.one
            .from('warehouse.inventory.StorageLocations')
            .where({
                ID: targetLocationId
            });

        if (!targetLocation) {
            return req.reject(404, 'Target storage location not found.');
        }

        const availableStock = await getStock(
            materialId,
            sourceLocationId
        );

        if (quantity > availableStock) {
            return req.reject(
                400,
                `Insufficient stock at source location. Available stock: ${availableStock}.`
            );
        }

        return INSERT.into('warehouse.inventory.StockMovements').entries({
            movementType: 'TRANSFER',
            material_ID: materialId,
            quantity,
            movementDate,
            reference,
            sourceLocation_ID: sourceLocationId,
            targetLocation_ID: targetLocationId
        });
    });
});