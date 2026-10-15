# Warehouse Inventory and Stock Tracking

## Project Overview

The Warehouse Inventory and Stock Tracking application provides a centralized solution for recording warehouse stock movements and monitoring inventory across plants and storage locations.

The application supports goods receipts, goods issues, and stock transfers. It also provides analytical reports for current stock, stock value, low-stock materials, and slow-moving materials.

The solution is developed using SAP Business Technology Platform, SAP Cloud Application Programming Model, SAP HANA Cloud, and SAP HANA Calculation Views.

---

## Business Problem

Warehouse stock receipts, goods issues, and transfers are often maintained manually, making it difficult to determine:

- How much stock is currently available
- Where the stock is stored
- Which materials are below their reorder level
- Which materials have not moved for a long period
- What the current stock value is for each material
- Whether an issue or transfer would result in negative stock

This application addresses these challenges by maintaining all stock movements in a structured system and generating real-time inventory reports.

---

## Business Objectives

The main objectives of the application are:

- Record all warehouse stock movements in one system
- Maintain plant, storage-location, and material master data
- Prevent invalid stock transactions
- Prevent negative stock during goods issues and transfers
- Calculate current stock by material and storage location
- Calculate the total inventory value
- Identify materials below their reorder level
- Calculate shortage quantities
- Identify slow-moving materials
- Identify materials that have never been issued
- Provide secure, role-based access to inventory reports

---

## Main Users

### Warehouse Clerk

The Warehouse Clerk records day-to-day warehouse transactions.

Responsibilities include:

- Recording goods receipts
- Recording goods issues
- Recording stock transfers
- Selecting the relevant material and storage location
- Entering movement quantities and reference information
- Ensuring that transaction information is accurate

### Warehouse Supervisor

The Warehouse Supervisor monitors stock availability and operational inventory requirements.

Responsibilities include:

- Viewing current stock by plant
- Viewing current stock by storage location
- Identifying materials below reorder level
- Reviewing shortage quantities
- Monitoring inventory availability

### Plant Manager

The Plant Manager reviews inventory value and material movement trends.

Responsibilities include:

- Reviewing stock value by plant
- Identifying slow-moving materials
- Identifying materials that have never been issued
- Monitoring inactive inventory
- Supporting inventory-planning decisions

### Inventory Viewer

The Inventory Viewer has read-only access to inventory analytics reports.

### Inventory Manager

The Inventory Manager can review analytics reports and perform authorized inventory-management activities.

---

## Technology Stack

The application uses the following technologies:

- SAP Business Technology Platform
- SAP Cloud Application Programming Model
- SAP HANA Cloud
- SAP HANA Calculation Views
- SAP Business Application Studio
- SAP Authorization and Trust Management Service
- XSUAA
- SAP Application Router
- Cloud Foundry
- Core Data Services
- Node.js
- JavaScript

---

## Main Application Components

### Database Layer

The database layer contains:

- Plant master data
- Storage-location master data
- Material master data
- Stock-movement transactions
- SAP HANA Calculation Views
- Analytical proxy definitions

### Service Layer

The service layer contains:

- Transaction services
- Inventory business validations
- Stock-movement processing logic
- Analytics services
- Read-only analytical reports
- Authorization restrictions

### Security Layer

The security layer contains:

- User authentication through XSUAA
- Application roles
- Role templates
- Role collections
- Analytics-report authorization
- Application Router authentication

### Analytics Layer

The analytics layer contains three Calculation Views:

1. Current Stock
2. Low-Stock Materials
3. Slow-Moving Materials

---

## Data Model

### Plants

The Plants entity stores plant master information.

Important information includes:

- Plant ID
- Plant code
- Plant name
- Creation details
- Modification details

Each plant can contain multiple storage locations.

### Storage Locations

The Storage Locations entity stores warehouse location information.

Important information includes:

- Storage-location ID
- Location code
- Location name
- Assigned plant
- Creation details
- Modification details

Each storage location belongs to one plant.

### Materials

The Materials entity stores material master information.

Important information includes:

- Material ID
- Material code
- Material name
- Material description
- Unit of measure
- Unit price
- Reorder level
- Active status
- Creation details
- Modification details

The unit price is used to calculate stock value.

The reorder level is used to identify low-stock materials.

### Stock Movements

The Stock Movements entity stores all inventory transactions.

The supported movement types are:

- Receipt
- Issue
- Transfer

Important information includes:

- Movement ID
- Movement type
- Material
- Quantity
- Movement date
- Reference
- Storage location
- Source location
- Target location
- Creation details
- Modification details

---

## Stock Movement Types

### Goods Receipt

A goods receipt increases the available stock in a storage location.

The user provides:

- Material
- Storage location
- Quantity
- Movement date
- Reference information

After the receipt is recorded, current stock for the selected material and location increases.

### Goods Issue

A goods issue decreases the available stock in a storage location.

The user provides:

- Material
- Storage location
- Quantity
- Movement date
- Reference information

Before recording an issue, the application verifies that sufficient stock is available.

If the requested quantity is greater than the available stock, the transaction is rejected.

### Stock Transfer

A stock transfer moves a material from one storage location to another.

The user provides:

- Material
- Source location
- Target location
- Quantity
- Movement date
- Reference information

A transfer produces two inventory effects:

- Stock is reduced at the source location
- Stock is increased at the target location

The total stock quantity for the material remains unchanged across both locations.

---

## Business Validations

### Quantity Validation

- Quantity must be greater than zero.
- Zero or negative quantities are not accepted.

### Goods Receipt Validation

- Material is mandatory.
- Storage location is mandatory.
- Quantity is mandatory.
- Movement date is mandatory.

### Goods Issue Validation

- Material is mandatory.
- Storage location is mandatory.
- Quantity is mandatory.
- Movement date is mandatory.
- Available stock is checked before recording the issue.
- An issue must not result in negative stock.

### Transfer Validation

- Material is mandatory.
- Source location is mandatory.
- Target location is mandatory.
- Quantity is mandatory.
- Movement date is mandatory.
- Source and target locations must be different.
- Sufficient stock must exist at the source location.
- A transfer must not result in negative source stock.
- Transfer-out and transfer-in effects must be processed together.

### Stock-Movement Integrity

Stock movements represent auditable business transactions.

After a movement is successfully recorded:

- Unauthorized changes are not allowed.
- Unauthorized deletion is not allowed.
- Any correction process must be controlled and auditable.

---

## Current Stock Calculation

Current stock is calculated using all movement records for a material and storage location.

The calculation considers:

- Goods receipts as positive quantities
- Goods issues as negative quantities
- Transfers out as negative quantities
- Transfers in as positive quantities

The current stock represents the net quantity available for a material at a particular storage location.

---

## Stock Value Calculation

Stock value is calculated using:

- Current stock quantity
- Material unit price

Stock value can be analyzed by:

- Plant
- Storage location
- Material

This information helps warehouse supervisors and plant managers understand the financial value of available inventory.

---

# SAP HANA Calculation Views

## CV_CURRENT_STOCK

### Purpose

The Current Stock Calculation View calculates available stock for every material and storage location.

It combines:

- Goods receipts
- Goods issues
- Transfer-out movements
- Transfer-in movements
- Material information
- Storage-location information
- Plant information

### Main Information Provided

The report displays:

- Plant code
- Plant name
- Storage-location code
- Storage-location name
- Material code
- Material name
- Unit of measure
- Current stock
- Unit price
- Reorder level
- Stock value

### Business Calculation

Current stock is calculated by adding receipt and transfer-in quantities and subtracting issue and transfer-out quantities.

Stock value is calculated by multiplying current stock by material unit price.

### Main Benefits

The view allows users to:

- Check stock by plant
- Check stock by storage location
- Check stock by material
- Review current inventory value
- Identify negative or unexpected stock results
- Support goods-issue and transfer validations

---

## CV_LOW_STOCK_MATERIALS

### Purpose

The Low-Stock Materials Calculation View identifies materials where current stock is below the configured reorder level.

### Business Condition

A material is considered low stock when its current stock is less than its reorder level.

### Shortage Quantity

The view calculates the shortage quantity for every low-stock material.

The shortage quantity represents how much stock is required to reach the configured reorder level.

### Main Information Provided

The report displays:

- Plant code
- Plant name
- Storage-location code
- Storage-location name
- Material code
- Material name
- Unit of measure
- Current stock
- Reorder level
- Shortage quantity
- Unit price
- Stock value

### Main Benefits

The view allows warehouse supervisors to:

- Identify materials requiring replenishment
- Prioritize procurement activities
- Prioritize stock-transfer activities
- Review shortages by plant
- Review shortages by storage location
- Reduce the risk of stock unavailability

---

## CV_SLOW_MOVING_MATERIALS

### Purpose

The Slow-Moving Materials Calculation View identifies materials with available stock that have not had a goods issue for a specified number of days.

### Inactivity Period

The report can be evaluated for different inactivity periods, such as:

- 30 days
- 60 days
- 90 days

### Business Conditions

A material is considered slow-moving when:

- Current stock is greater than zero
- The last issue date is older than the selected inactivity period

Materials that have never had a goods issue can also be included.

### Main Information Provided

The report displays:

- Plant code
- Plant name
- Storage-location code
- Storage-location name
- Material code
- Material name
- Unit of measure
- Current stock
- Unit price
- Stock value
- Last issue date
- Number of days since the last issue
- Movement status

### Movement Status

The report classifies materials as:

- Previously Issued
- Never Issued

### Main Benefits

The view allows plant managers to:

- Identify inactive inventory
- Identify materials that have never been consumed
- Review capital tied up in unused stock
- Support stock-reduction decisions
- Support material-transfer planning
- Support disposal planning

---

## Calculation View Dependencies

The Current Stock Calculation View is the base analytical view.

The Low-Stock Materials report depends on the Current Stock view.

The Slow-Moving Materials report combines:

- Current stock information
- Goods-issue history
- Latest issue dates
- User-selected inactivity days

The recommended deployment order is:

1. Current Stock
2. Low-Stock Materials
3. Slow-Moving Materials

---

## CAP Analytics Integration

The Calculation Views are integrated with the CAP application using analytical proxy entities.

The proxy entities represent Calculation Views that already exist in SAP HANA.

The proxy definitions must match the corresponding Calculation View exactly, including:

- Runtime object name
- Column names
- Column capitalization
- Underscores
- Data types
- Decimal precision
- Decimal scale
- Input parameters

A mismatch can cause database-deployer or runtime failures.

---

## Analytics Service

The analytics service exposes the inventory reports through the CAP application.

The following reports are available:

- Current Stock
- Low-Stock Materials
- Slow-Moving Materials

All analytics reports are read-only.

Users are not allowed to create, update, or delete records through the analytics service.

---

## Authorization Roles

### InventoryViewer

The InventoryViewer role provides read-only access to:

- Current Stock report
- Low-Stock Materials report
- Slow-Moving Materials report

This role is suitable for:

- Warehouse supervisors
- Plant managers
- Reporting users
- Audit users

### InventoryManager

The InventoryManager role provides:

- Access to inventory analytics reports
- Access to permitted inventory-management operations

This role is suitable for:

- Inventory managers
- Warehouse administrators
- Authorized operational users

---

## Authentication and Role Assignment

Authentication is handled through XSUAA.

The application roles must be:

1. Defined in the application security configuration
2. Included in the deployed authorization service
3. Added to SAP BTP role collections
4. Assigned to the appropriate users

After a new role collection is assigned, the user must sign out and sign in again. This ensures that the newly assigned role is included in the authentication token.

---

## Application Router

The Application Router acts as the authenticated entry point to the deployed application.

The Application Router is responsible for:

- Redirecting users to the login page
- Authenticating users
- Forwarding requests to the backend service
- Forwarding the authentication token
- Protecting application routes

The direct backend service may return an Unauthorized response when opened directly in a browser because the browser request does not contain a valid authentication token.

For browser-based testing, the application should be accessed through the Application Router.

---

# Testing Scenarios

## Goods Receipt Testing

### Test Objective

Verify that a goods receipt increases available stock.

### Testing Steps

1. Select a material.
2. Select a storage location.
3. Enter a valid quantity.
4. Enter a movement date.
5. Save the receipt.
6. Open the Current Stock report.
7. Verify that stock increased by the receipt quantity.

### Expected Result

The selected material and storage location should display the increased stock quantity.

---

## Goods Issue Testing

### Test Objective

Verify that a goods issue decreases available stock without allowing negative stock.

### Testing Steps

1. Select a material with available stock.
2. Select the storage location.
3. Enter an issue quantity lower than or equal to available stock.
4. Enter a movement date.
5. Save the issue.
6. Open the Current Stock report.
7. Verify that stock decreased by the issue quantity.

### Negative Test

Enter an issue quantity greater than the available stock.

### Expected Result

The application should reject the transaction and display an appropriate validation message.

---

## Stock Transfer Testing

### Test Objective

Verify that a transfer reduces stock at the source location and increases stock at the target location.

### Testing Steps

1. Select a material.
2. Select the source location.
3. Select a different target location.
4. Enter a valid transfer quantity.
5. Enter a movement date.
6. Save the transfer.
7. Open the Current Stock report.
8. Check the source location.
9. Check the target location.

### Expected Result

- Source stock decreases by the transfer quantity.
- Target stock increases by the same quantity.
- Total stock across both locations remains unchanged.

### Negative Tests

Verify that the application rejects:

- A transfer with the same source and target location
- A transfer quantity greater than the source stock
- A transfer with a zero quantity
- A transfer with a negative quantity
- A transfer without a source location
- A transfer without a target location

---

## Current Stock Report Testing

### Test Objective

Verify that stock is calculated correctly from all movement types.

### Verification Steps

For one selected material and location, manually calculate:

- Total receipts
- Total issues
- Total transfers out
- Total transfers in

Compare the manually calculated result with the Current Stock report.

### Expected Result

The report value should match the manual stock calculation.

Also verify:

- Plant information is correct.
- Storage-location information is correct.
- Material information is correct.
- Unit price is correct.
- Reorder level is correct.
- Stock value is correct.

---

## Low-Stock Materials Report Testing

### Test Objective

Verify that only materials below their reorder level are displayed.

### Testing Steps

1. Select a material.
2. Verify its reorder level.
3. Create movements that result in stock below the reorder level.
4. Open the Low-Stock Materials report.
5. Verify that the material is displayed.
6. Verify the shortage quantity.

### Expected Result

The material should appear only when its current stock is below its reorder level.

The shortage quantity should equal the difference between the reorder level and current stock.

### Negative Test

Create sufficient stock to make current stock equal to or greater than the reorder level.

The material should no longer appear in the Low-Stock Materials report.

---

## Slow-Moving Materials Report Testing

### Test Objective

Verify that the report identifies materials with no recent issue movement.

### Testing Periods

Test the report using:

- 30 days
- 60 days
- 90 days

### Expected Result

The report should display materials that:

- Have current stock greater than zero
- Have not had an issue within the selected period
- Have never had an issue

The report should correctly display:

- Last issue date
- Days since the last issue
- Movement status

---

## Authorization Testing

### Inventory Viewer Test

1. Assign the InventoryViewer role.
2. Sign out and sign in again.
3. Open the analytics reports.
4. Verify that report data can be viewed.
5. Verify that analytical records cannot be created, modified, or deleted.

### Inventory Manager Test

1. Assign the InventoryManager role.
2. Sign out and sign in again.
3. Open the analytics reports.
4. Verify access to permitted inventory-management features.

### Unauthorized User Test

1. Use a user without the InventoryViewer or InventoryManager role.
2. Attempt to access the analytics reports.

### Expected Result

The user should not receive access to protected analytics reports.

---

# Deployment Overview

The application is deployed to the SAP BTP Cloud Foundry environment.

The deployment contains:

- CAP service application
- Database deployer
- HDI container
- XSUAA service
- Application Router
- Destination configuration
- SAP HANA Calculation Views

The recommended deployment sequence is:

1. Verify the CDS models.
2. Verify Calculation View column mappings.
3. Build the production artifacts.
4. Build the multitarget application archive.
5. Deploy the application.
6. Verify database deployment.
7. Verify service application status.
8. Verify Application Router status.
9. Assign role collections.
10. Test the application with the appropriate users.

---

# Troubleshooting

## Unauthorized Response

### Possible Cause

The direct backend service was opened without a valid authentication token.

### Resolution

- Access the application through the Application Router.
- Verify that XSUAA is bound to the backend service.
- Verify that XSUAA is bound to the Application Router.
- Verify that authentication-token forwarding is enabled.
- Sign out and sign in again.

---

## Forbidden Response

### Possible Cause

The user is authenticated but does not have the required application role.

### Resolution

- Verify that the required role exists.
- Add the role to a SAP BTP role collection.
- Assign the role collection to the user.
- Sign out and sign in again.
- Retest the application through the Application Router.

---

## Page or Resource Not Found

### Possible Cause

The Application Router route or service path is incorrect.

### Resolution

- Verify the analytics service path.
- Verify the deployed Application Router configuration.
- Verify that requests are forwarded to the backend service.
- Verify that the analytics service was included in the production build.
- Verify that the requested report exists in the service metadata.

---

## Database Deployer Failure

### Common Causes

- Calculation View column-name mismatch
- Incorrect Calculation View runtime name
- Missing output column
- Incorrect column data type
- Incorrect decimal precision or scale
- Missing Calculation View dependency
- Invalid input parameter mapping
- Incorrect Calculation View source reference
- Missing design-time configuration

### Resolution

For every Calculation View:

1. Open the deployed object in SAP HANA Database Explorer.
2. Check the exact runtime object name.
3. Check every output column.
4. Compare the output with the CAP proxy entity.
5. Verify column capitalization and underscores.
6. Verify data types.
7. Verify decimal precision and scale.
8. Verify input parameters.
9. Add and deploy one analytical proxy at a time to isolate the issue.

---

## Calculation View Returns No Data

### Possible Causes

- No stock-movement data is available.
- Movement-type values do not match the Calculation View filters.
- Material ID is not mapped through all nodes.
- Location ID is not mapped through all nodes.
- Union mappings are incomplete.
- Join conditions use incorrect columns.
- Filters exclude all records.
- Source and target locations are missing.
- The final Aggregation does not expose required columns.
- The Semantics node does not expose required columns.

### Resolution

Verify:

- Receipt values match the configured receipt movement type.
- Issue values match the configured issue movement type.
- Transfer values match the configured transfer movement type.
- Union output includes material, location, and signed quantity.
- Current stock is correctly aggregated by material and location.
- Material, location, and plant joins are correct.
- All required fields are mapped to the final output.

---

## Incorrect Current Stock

### Possible Causes

- Issue quantity is treated as positive.
- Transfer-out quantity is treated as positive.
- Transfer-in quantity is treated as negative.
- A transfer is represented only once.
- Receipt or issue records use the wrong location field.
- Duplicate movement records exist.
- Union mappings are incorrect.

### Resolution

Verify that:

- Receipts increase stock.
- Issues decrease stock.
- Transfers reduce source stock.
- Transfers increase target stock.
- Current stock is grouped by material and location.
- The underlying stock movements are not duplicated.

---

## Incorrect Low-Stock Results

### Possible Causes

- Reorder level is aggregated incorrectly.
- Current stock is aggregated incorrectly.
- The low-stock condition is reversed.
- Shortage quantity is calculated incorrectly.
- Material master data contains an incorrect reorder level.

### Resolution

Verify that:

- Current stock is less than reorder level.
- Reorder level uses an appropriate aggregation behavior.
- Shortage quantity is reorder level minus current stock.
- Material reorder-level data is correct.

---

## Incorrect Slow-Moving Results

### Possible Causes

- The report is not restricted to issue movements.
- The latest issue date is not calculated correctly.
- The join excludes materials that have never been issued.
- The inactivity period is not passed correctly.
- Materials with zero stock are included.
- The date calculation uses an incorrect data type.

### Resolution

Verify that:

- Only issue movements are considered.
- The last issue date uses the most recent issue date.
- Current Stock is the main source in the left outer join.
- Never-issued materials are retained.
- Current stock is greater than zero.
- The selected number of days is applied correctly.
- Date and timestamp types match the Calculation View output.

---

# Future Enhancements

The following features can be added in future releases:

- SAP Fiori elements applications for all reports
- Plant-wise inventory dashboards
- Storage-location stock charts
- Stock-value trend analysis
- Low-stock alert notifications
- Email notifications
- Workflow-based approval for stock corrections
- Inventory aging buckets
- Configurable slow-moving thresholds
- Material value-help dialogs
- Plant and storage-location filters
- Automated unit tests
- Automated integration tests
- Automated deployment pipelines
- Audit reports
- Inventory reconciliation reports
- Analytical report export options

---

# Project Outcome

The Warehouse Inventory and Stock Tracking application provides a structured and secure method for managing warehouse inventory.

The application supports:

- Goods receipt processing
- Goods issue processing
- Stock transfers
- Negative-stock prevention
- Current-stock calculation
- Stock-value calculation
- Low-stock identification
- Shortage-quantity calculation
- Slow-moving material identification
- Never-issued material identification
- Role-based report access
- SAP HANA-based analytical reporting
- SAP BTP Cloud Foundry deployment

The three main Calculation Views are:

- CV_CURRENT_STOCK
- CV_LOW_STOCK_MATERIALS
- CV_SLOW_MOVING_MATERIALS

Together, SAP CAP, SAP HANA Cloud, SAP HANA Calculation Views, XSUAA, and the SAP Application Router provide a scalable warehouse inventory and reporting solution.

# Author

- Aditya Pandey