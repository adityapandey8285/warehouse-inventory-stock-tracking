sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"warehouse/inventory/ui/inventoryui/test/integration/pages/StockMovementsList.gen",
	"warehouse/inventory/ui/inventoryui/test/integration/pages/StockMovementsObjectPage.gen"
], function (JourneyRunner, StockMovementsListGenerated, StockMovementsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('warehouse/inventory/ui/inventoryui') + '/test/flp.html#app-preview',
        pages: {
			onTheStockMovementsListGenerated: StockMovementsListGenerated,
			onTheStockMovementsObjectPageGenerated: StockMovementsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

