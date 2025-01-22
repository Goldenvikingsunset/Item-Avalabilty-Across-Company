# Cross-Company Data Management Extension

This extension enables cross-company data visibility and management in Business Central, focusing on inventory availability, sales history, and customer balances across multiple companies.

## Features

### 1. Multi-Company Item Availability
- Real-time inventory levels across all companies
- Drill-down capability to detailed location-specific stock levels
- Integrated with sales documents for immediate availability checks

```mermaid
flowchart TB
    A[Sales Document] --> B[Multi-Company Availability FactBox]
    B --> C{Check Inventory}
    C -->|Current Company| D[Show Current Stock]
    C -->|Other Companies| E[Show Other Companies Stock]
    E --> F[Drill Down]
    F --> G[Detailed Location View]
```

### 2. Cross-Company Sales History
- Consolidated view of sales across all companies
- Historical transaction analysis
- Location-based sales tracking

```mermaid
flowchart LR
    A[Sales History Query] --> B[Filter Parameters]
    B --> C[Cross-Company Data Collection]
    C --> D[Combined Results]
    D --> E[Analysis View]
    E --> F[Export/Report]
```

### 3. Cross-Company Customer Balances
- Unified customer balance overview
- Multi-company credit limit monitoring
- Overdue payment tracking

```mermaid
flowchart TB
    A[Customer Card] --> B[Cross-Company Balance FactBox]
    B --> C{Get Data}
    C --> D[Total Balance]
    C --> E[Due Amount]
    C --> F[Credit Limit]
    D & E & F --> G[Display Indicators]
    G --> H[Drill Down Details]
```

### 4. Combined Posted Sales Invoices
- Centralized view of all posted sales invoices
- Multi-company filtering capabilities
- Direct navigation to source documents

```mermaid
flowchart LR
    A[Invoice Page] --> B[Filter Options]
    B --> C[Company Filter]
    B --> D[Date Filter]
    B --> E[Customer Filter]
    B --> F[Location Filter]
    C & D & E & F --> G[Load Data]
    G --> H[Display Results]
    H --> I[Navigate to Source]
```

## Technical Architecture

```mermaid
graph TB
    A[UI Layer] --> B[Pages]
    B --> C[Tables]
    B --> D[Queries]
    C --> E[Data Layer]
    D --> E
    E --> F[Company A]
    E --> G[Company B]
    E --> H[Company N]
```

## Installation

1. Import the extension to your Business Central environment
2. Verify permissions for cross-company access
3. Configure company access settings

## Usage

### Required Permissions
- SUPER or equivalent for cross-company operations
- Read permissions on source companies
- Write permissions for temporary tables

### Configuration
- Set up company access rights
- Configure location mappings if needed
- Set default filters as required

## Limitations

- Performance may vary based on number of companies
- Real-time data sync limitations
- Company-specific customizations may affect data consistency

## Support

For technical support or feature requests, please create an issue in the repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
