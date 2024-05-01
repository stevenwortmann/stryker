CREATE TABLE Manufacturers (
    ManufacturerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(100),
    ContactInfo VARCHAR(100),
    IsPublic BIT, -- 0 for Private, 1 for Public
    FinancialHealthRating CHAR(1), -- A, B, C, D, or F rating
    AnnualRevenue DECIMAL(18,2),
    RevenueGrowthRate FLOAT, -- Percentage growth rate of revenue year over year
    EBITDA DECIMAL(18,2), -- Earnings Before Interest, Taxes, Depreciation, and Amortization
    NetIncome DECIMAL(18,2),
    DebtToEquityRatio FLOAT,
    CurrentRatio FLOAT, -- Current assets divided by current liabilities
    QuickRatio FLOAT, -- (Current assets - Inventories) / Current liabilities
    CashReserves DECIMAL(18,2),
    CreditRating VARCHAR(10), -- External credit ratings (e.g., AAA, BBB)
    LastFinancialReview DATE
);

CREATE TABLE PartsInventoryMaster (
    PartID INT IDENTITY(1,1) PRIMARY KEY,
    PartType VARCHAR(50),
    PartModel VARCHAR(50),
    ManufacturerID INT,
    Specifications NVARCHAR(MAX),
    PartCategory VARCHAR(50),
    CriticalLevel VARCHAR(20), -- Non-Critical, Critical, Mission-Critical
    StockLevel INT,
    ReorderThreshold INT,
    UnitCost DECIMAL(10,2),
    LeadTimeDays INT,
    LastOrdered DATE,
    LastReceived DATE,
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE ProcurementContracts (
    ContractID INT IDENTITY(1,1) PRIMARY KEY,
    MicrocontrollerID INT,
    ManufacturerID INT,
    ContractDate DATE,
    Quantity INT,
    PricePerUnit DECIMAL(10, 2),
    DeliveryTerms VARCHAR(255),
    ContractDurationMonths INT,
    PriceVolatilityRisk VARCHAR(50), -- Low, Medium, High
    LastDeliveryPerformance DATE,
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE PartsManufacturersXRef (
    XRefID INT IDENTITY(1,1) PRIMARY KEY,
    PartID INT,
    ManufacturerID INT,
    OnHandQuantity INT,
    NextFinishProductionDate DATE,
    NextProductionQuantity INT,
    BasePrice DECIMAL(10,2),
    PriceForExpeditedDelivery DECIMAL(10,2),
    ExpeditedDeliveryTimeDays INT,
    StandardDeliveryTimeDays INT,
    ProcurementContractID INT NULL, -- Nullable Foreign Key to ProcurementContracts
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID),
    FOREIGN KEY (ProcurementContractID) REFERENCES ProcurementContracts(ContractID)
);

CREATE TABLE QualityCertifications (
    CertificationID INT IDENTITY(1,1) PRIMARY KEY,
    PartID INT,
    CertificationLevel VARCHAR(50),
    ValidUntil DATE,
    IssuingAuthority VARCHAR(100)
);

CREATE TABLE Microcontroller (
    MicrocontrollerID INT IDENTITY(1,1) PRIMARY KEY,
    ModelNumber VARCHAR(50) NOT NULL,
    ManufacturerID INT,
    ClockSpeedMHz FLOAT,
    CoreCount INT,
    MemoryType VARCHAR(30),
    MemorySizeMB INT,
    OperatingTemperatureMinC FLOAT,
    OperatingTemperatureMaxC FLOAT,
    SupplyVoltageMinV FLOAT,
    SupplyVoltageMaxV FLOAT,
    CertificationID INT,
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID),
    FOREIGN KEY (CertificationID) REFERENCES QualityCertifications(CertificationID)
);
