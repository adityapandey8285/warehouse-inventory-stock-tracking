using {
    CV_CURRENT_STOCK,
    CV_LOW_STOCK_MATERIALS,
    CV_SLOW_MOVING_MATERIALS
} from '../db/analytics';

@path: '/analytics'
@requires: 'authenticated-user'
service AnalyticsService {

    @readonly
    entity CurrentStock
        as projection on CV_CURRENT_STOCK;

    @readonly
    @requires: [
        'WarehouseSupervisor',
        'PlantManager'
    ]
    entity LowStockMaterials
        as projection on CV_LOW_STOCK_MATERIALS;

    @readonly
    @requires: 'PlantManager'
    entity SlowMovingMaterials (
        IP_DAYS : Integer
    )
        as select from CV_SLOW_MOVING_MATERIALS (
            IP_DAYS : :IP_DAYS
        ) {
            *
        };
}