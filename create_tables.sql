CREATE TABLE Manufacturers (
    ManufacturerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(100),
    ContactInfo VARCHAR(100),
    FinancialHealthRating CHAR(1), -- A, B, C, D, or F rating
    SupplyChainRiskLevel VARCHAR(50), -- Low, Medium, High
    OnHandInventory INT,
    LastFinancialReview DATE
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
    FOREIGN KEY (MicrocontrollerID) REFERENCES Microcontroller(MicrocontrollerID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
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
