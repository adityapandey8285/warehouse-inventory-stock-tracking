@cds.persistence.exists
@cds.persistence.calcview
entity ![CV_CURRENT_STOCK] {

    key PLANT_ID        : String(36);
    key LOCATION_ID     : String(36);
    key MATERIAL_ID     : String(36);

    PLANTCODE           : String(20);
    PLANTNAME           : String(100);
    LOCATIONCODE        : String(20);
    LOCATIONNAME        : String(100);
    MATERIALCODE        : String(30);
    MATERIALNAME        : String(100);
    UNITOFMEASURE       : String(10);

    CURRENT_STOCK       : Decimal(15,3);
    UNITPRICE           : Decimal(15,2);
    REORDERLEVEL        : Decimal(15,3);
    STOCK_VALUE         : Decimal(20,2);
}


@cds.persistence.exists
@cds.persistence.calcview
entity ![CV_LOW_STOCK_MATERIALS] {

    key PLANT_ID        : String(36);
    key LOCATION_ID     : String(36);
    key MATERIAL_ID     : String(36);

    PLANTCODE           : String(20);
    PLANTNAME           : String(100);
    LOCATIONCODE        : String(20);
    LOCATIONNAME        : String(100);
    MATERIALCODE        : String(30);
    MATERIALNAME        : String(100);
    UNITOFMEASURE       : String(10);

    CURRENT_STOCK       : Decimal(15,3);
    UNITPRICE           : Decimal(15,2);
    REORDERLEVEL        : Decimal(15,3);
    STOCK_VALUE         : Decimal(20,2);
    SHORTAGE_QUANTITY   : Decimal(15,3);
}


@cds.persistence.exists
@cds.persistence.calcview
entity ![CV_SLOW_MOVING_MATERIALS] (
    IP_DAYS : Integer
) {

    key PLANT_ID              : String(36);
    key LOCATION_ID           : String(36);
    key MATERIAL_ID           : String(36);

    PLANTCODE                 : String(20);
    PLANTNAME                 : String(100);
    LOCATIONCODE              : String(20);
    LOCATIONNAME              : String(100);
    MATERIALCODE              : String(30);
    MATERIALNAME              : String(100);
    UNITOFMEASURE             : String(10);

    CURRENT_STOCK             : Decimal(15,3);
    UNITPRICE                 : Decimal(15,2);
    STOCK_VALUE               : Decimal(20,2);
    LAST_ISSUE_DATE           : Date;
    DAYS_SINCE_LAST_ISSUE     : Integer;
    MOVEMENT_STATUS           : String(30);
}