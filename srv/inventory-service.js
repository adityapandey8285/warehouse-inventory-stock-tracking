import cds from '@sap/cds';

export default cds.service.impl(async function () {
    const {
        Materials,
        StorageLocations,
        StockMovements
    } = cds.entities('warehouse.inventory');

    const { SELECT, INSERT } = cds.ql;

    function criticalityFor(type) {
        switch (type) {
            case 'ISSUE':
                return 1; // Red
            case 'RECEIPT':
                return 3; // Green
            case 'TRANSFER':
                return 5; // Blue
            default:
                return 0;
        }
    }

    function validateQuantity(req, quantity) {
        const amount = Number(quantity);

        if (!Number.isFinite(amount) || amount <= 0) {
            return req.reject(
                400,
                'Quantity must be greater than zero.'
            );
        }

        return amount;
    }

    function parseMovementDate(req, value) {
        const date = value ? new Date(value) : new Date();

        if (Number.isNaN(date.getTime())) {
            return req.reject(400, 'Movement date is invalid.');
        }

        return date;
    }

    async function requireMaterial(tx, req, materialId) {
        if (!materialId) {
            return req.reject(400, 'Material is required.');
        }

        const material = await tx.run(
            SELECT.one.from(Materials).where({ ID: materialId })
        );

        if (!material) {
            return req.reject(404, 'Material not found.');
        }

        if (material.active === false) {
            return req.reject(400, 'This material is inactive.');
        }

        return material;
    }

    async function requireLocation(tx, req, locationId) {
        if (!locationId) {
            return req.reject(400, 'Storage location is required.');
        }

        const location = await tx.run(
            SELECT.one.from(StorageLocations).where({ ID: locationId })
        );

        if (!location) {
            return req.reject(404, 'Storage location not found.');
        }

        return location;
    }

    // Calculate stock for one material at one storage location.
    async function currentStock(tx, materialId, locationId) {
        const movements = await tx.run(
            SELECT.from(StockMovements).where({
                material_ID: materialId
            })
        );

        let stock = 0;

        for (const movement of movements) {
            const qty = Number(movement.quantity || 0);

            if (
                movement.movementType === 'RECEIPT' &&
                movement.storageLocation_ID === locationId
            ) {
                stock += qty;
            }

            if (
                movement.movementType === 'ISSUE' &&
                movement.storageLocation_ID === locationId
            ) {
                stock -= qty;
            }

            if (
                movement.movementType === 'TRANSFER' &&
                movement.sourceLocation_ID === locationId
            ) {
                stock -= qty;
            }

            if (
                movement.movementType === 'TRANSFER' &&
                movement.targetLocation_ID === locationId
            ) {
                stock += qty;
            }
        }

        return stock;
    }

    async function createMovement(tx, data) {
        const ID = cds.utils.uuid();

        const movement = {
            ID,
            movementType: data.movementType,
            material_ID: data.materialId,
            quantity: data.quantity,
            movementDate: data.movementDate,
            reference: data.reference || null,
            storageLocation_ID: data.storageLocationId || null,
            sourceLocation_ID: data.sourceLocationId || null,
            targetLocation_ID: data.targetLocationId || null
        };

        await tx.run(
            INSERT.into(StockMovements).entries(movement)
        );

        return {
            ...movement,
            movementCriticality: criticalityFor(data.movementType)
        };
    }

    // Color movement types in the existing Stock Movements table.
    this.after('READ', 'StockMovements', rows => {
        const list = Array.isArray(rows) ? rows : [rows];

        for (const row of list) {
            if (row) {
                row.movementCriticality =
                    criticalityFor(row.movementType);
            }
        }
    });

    // Movement history cannot be edited or deleted.
    this.before(['UPDATE', 'DELETE'], 'StockMovements', req => {
        return req.reject(
            405,
            'Stock movements cannot be changed or deleted. ' +
            'Record a new movement instead.'
        );
    });

    // RECEIVE STOCK
    this.on('receive', async req => {
        const tx = cds.tx(req);
        const {
            materialId,
            storageLocationId,
            quantity,
            movementDate,
            reference
        } = req.data;

        const amount = validateQuantity(req, quantity);

        await requireMaterial(tx, req, materialId);
        await requireLocation(tx, req, storageLocationId);

        return createMovement(tx, {
            movementType: 'RECEIPT',
            materialId,
            storageLocationId,
            quantity: amount,
            movementDate: parseMovementDate(req, movementDate),
            reference
        });
    });

    // ISSUE STOCK
    this.on('issue', async req => {
        const tx = cds.tx(req);
        const {
            materialId,
            storageLocationId,
            quantity,
            movementDate,
            reference
        } = req.data;

        const amount = validateQuantity(req, quantity);

        await requireMaterial(tx, req, materialId);
        await requireLocation(tx, req, storageLocationId);

        const available = await currentStock(
            tx,
            materialId,
            storageLocationId
        );

        if (amount > available) {
            return req.reject(
                400,
                `Insufficient stock. Available: ${available}; ` +
                `requested: ${amount}.`
            );
        }

        return createMovement(tx, {
            movementType: 'ISSUE',
            materialId,
            storageLocationId,
            quantity: amount,
            movementDate: parseMovementDate(req, movementDate),
            reference
        });
    });

    // TRANSFER STOCK
    this.on('transfer', async req => {
        const tx = cds.tx(req);
        const {
            materialId,
            sourceLocationId,
            targetLocationId,
            quantity,
            movementDate,
            reference
        } = req.data;

        const amount = validateQuantity(req, quantity);

        await requireMaterial(tx, req, materialId);
        await requireLocation(tx, req, sourceLocationId);
        await requireLocation(tx, req, targetLocationId);

        if (sourceLocationId === targetLocationId) {
            return req.reject(
                400,
                'Source and target locations must be different.'
            );
        }

        const available = await currentStock(
            tx,
            materialId,
            sourceLocationId
        );

        if (amount > available) {
            return req.reject(
                400,
                `Insufficient source stock. Available: ${available}; ` +
                `requested: ${amount}.`
            );
        }

        // A single record represents the entire transfer.
        return createMovement(tx, {
            movementType: 'TRANSFER',
            materialId,
            sourceLocationId,
            targetLocationId,
            quantity: amount,
            movementDate: parseMovementDate(req, movementDate),
            reference
        });
    });

    // GET STOCK FOR ONE MATERIAL AND LOCATION
    this.on('getStock', async req => {
        const tx = cds.tx(req);
        const { materialId, storageLocationId } = req.data;

        await requireMaterial(tx, req, materialId);
        await requireLocation(tx, req, storageLocationId);

        return currentStock(tx, materialId, storageLocationId);
    });

    // CALCULATED STOCK LEVELS
    this.on('READ', 'StockLevels', async req => {
        const tx = cds.tx(req);

        const [materials, locations, movements] = await Promise.all([
            tx.run(SELECT.from(Materials)),
            tx.run(SELECT.from(StorageLocations)),
            tx.run(SELECT.from(StockMovements))
        ]);

        const stockMap = new Map();

        // Initialize each material/location combination at zero.
        for (const material of materials) {
            for (const location of locations) {
                const key = `${material.ID}:${location.ID}`;

                stockMap.set(key, {
                    material_ID: material.ID,
                    storageLocation_ID: location.ID,
                    materialCode: material.materialCode,
                    materialName: material.materialName,
                    storageLocationCode: location.locationCode,
                    currentStock: 0,
                    reorderLevel: Number(material.reorderLevel || 0)
                });
            }
        }

        // Receipts add stock; issues subtract stock.
        // Transfers subtract from source and add to destination.
        for (const movement of movements) {
            const qty = Number(movement.quantity || 0);

            if (movement.movementType === 'RECEIPT') {
                const key =
                    `${movement.material_ID}:` +
                    `${movement.storageLocation_ID}`;

                const row = stockMap.get(key);
                if (row) row.currentStock += qty;
            }

            if (movement.movementType === 'ISSUE') {
                const key =
                    `${movement.material_ID}:` +
                    `${movement.storageLocation_ID}`;

                const row = stockMap.get(key);
                if (row) row.currentStock -= qty;
            }

            if (movement.movementType === 'TRANSFER') {
                const sourceKey =
                    `${movement.material_ID}:` +
                    `${movement.sourceLocation_ID}`;

                const targetKey =
                    `${movement.material_ID}:` +
                    `${movement.targetLocation_ID}`;

                const source = stockMap.get(sourceKey);
                const target = stockMap.get(targetKey);

                if (source) source.currentStock -= qty;
                if (target) target.currentStock += qty;
            }
        }

        // Criticality is based on actual stock versus reorder level.
        const rows = Array.from(stockMap.values()).map(row => {
            const stock = Number(row.currentStock.toFixed(3));
            const reorder = row.reorderLevel;

            let stockStatus;
            let criticality;

            if (stock <= 0) {
                stockStatus = 'Out of Stock';
                criticality = 1; // Red
            } else if (stock < reorder) {
                stockStatus = 'Low Stock';
                criticality = 2; // Yellow/orange
            } else {
                stockStatus = 'Sufficient';
                criticality = 3; // Green
            }

            return {
                ...row,
                currentStock: stock,
                stockStatus,
                criticality
            };
        });

        return rows;
    });
});