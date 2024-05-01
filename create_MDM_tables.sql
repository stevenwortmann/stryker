/* ==================================================================================================================
   MASTER DATA MANAGEMENT SYSTEM FOR VEHICLE RESOURCE TRACKING
   Author: Steve Wortmann
   
   This MDM system categorizes and manages specific part models, module types, and manufacturers, extending
   its utility across different vehicles and assets. It integrates details such as quality certifications,
   procurement contracts, and cross-references between parts and manufacturers, ensuring a thorough
   tracking and management capability.
   This system supports comprehensive resource management by allowing maintaining personnel, end users,
   and logistics coordinators to track inventory statuses, operational readiness, and maintenance needs.
   It is designed to be flexible and adaptable, supporting a variety of vehicles and operational scenarios.
   ================================================================================================================== */


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

CREATE TABLE ModuleInventoryMaster ( -- Modules/gizmos that make up the whole platform.
    ModuleID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleType VARCHAR(50), -- Type of the module, e.g., 'ECM', 'APA', 'Hydraulic Ramp'
    ModuleModel VARCHAR(50), -- Model number or identifier of the module
    ManufacturerID INT, -- Reference to the manufacturer in the Manufacturers table
    Description NVARCHAR(MAX), -- Detailed description of the module's functions and specifications
    InstallationEnvironment VARCHAR(100), -- Description of the typical installation environment (e.g., interior, exterior, engine compartment)
    OperationalStatus VARCHAR(50), -- Current operational status, e.g., 'Active', 'Inactive', 'Under Review'
    CriticalLevel VARCHAR(20), -- Classification of operational criticality, e.g., 'Non-Critical', 'Critical', 'Mission-Critical'
    InventoryCount INT, -- Current stock level in inventory
    ReorderThreshold INT, -- Stock level that triggers a reorder
    UnitCost DECIMAL(10,2), -- Current cost per unit of the module
    LeadTimeDays INT, -- Lead time in days from order to delivery
    LastOrdered DATE, -- Date when the module was last ordered
    LastReceived DATE, -- Date when the module was last received in inventory
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE PartsInventoryMaster ( -- Parts/pieces that make up the separate modules/components.
    PartID INT IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for each part
    ModuleID INT, -- Reference to the module that this part is used in
    PartType VARCHAR(50), -- General classification of the part (e.g., 'Electrical', 'Mechanical')
    PartModel VARCHAR(50), -- Specific model number or identifier of the part
    ManufacturerID INT, -- Reference to the manufacturer in the Manufacturers table
    Specifications NVARCHAR(MAX), -- Detailed technical specifications and features of the part
    PartCategory VARCHAR(50), -- Category of the part (e.g., 'Engine', 'Suspension', 'Body')
    CriticalLevel VARCHAR(20), -- Classification of operational criticality, e.g., 'Non-Critical', 'Critical', 'Mission-Critical'
    StockLevel INT, -- Current stock level in inventory
    ReorderThreshold INT, -- Stock level that triggers a reorder to maintain sufficient inventory
    UnitCost DECIMAL(10,2), -- Current cost per unit of the part, important for financial planning
    LeadTimeDays INT, -- Estimated number of days from order placement to delivery
    LastOrdered DATE, -- Date when the part was last ordered, helps in tracking order cycles
    LastReceived DATE, -- Date when the part was last received, useful for monitoring supply chain efficiency
    FOREIGN KEY (ModuleID) REFERENCES ModuleInventoryMaster(ModuleID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE ProcurementContracts (
    ContractID INT IDENTITY(1,1) PRIMARY KEY,
    ManufacturerID INT,
    ModuleID INT,
    PartID INT,
    ContractDate DATE,
    Quantity INT,
    PricePerUnit DECIMAL(10, 2),
    DeliveryTerms VARCHAR(255),
    ContractDurationMonths INT,
    PriceVolatilityRisk INT, -- Scale of 1 to 100
    LastDeliveryPerformance DATE,
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
    FOREIGN KEY (ModuleID) REFERENCES ModuleInventoryMaster(ModuleID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
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
    IssuingAuthority VARCHAR(100),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID)
);


/* ==================================================================================================================
   DIMENSIONAL TABLES FOR VEHICLE MODULES MANAGEMENT
   This section includes tables that manage details about entire modules within vehicles, which can include assemblies
   that may be unique to the Stryker M1126 APC, or shared with other vehicle models. These modules may be in various
   stages such as storage, active deployment, or identified for maintenance and upgrade.
   The tables facilitate comprehensive management of module lifecycle statuses, supporting operational readiness
   and maintenance scheduling.
   (Section utilized by maintenance teams and logistics coordinators)
   ================================================================================================================== */


CREATE TABLE M1126_Mod_ECM ( -- Engine Control Module (ECM): Manages engine performance to ensure efficient fuel consumption and emissions control.
    ECMID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleID INT,
    ModelNumber VARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX), -- Detailed description of the module's function and characteristics
    ManufacturerID INT, -- Reference to the manufacturer in the Manufacturers table
    SoftwareVersion VARCHAR(50), -- Version of the software currently installed on the ECM
    HardwareVersion VARCHAR(50), -- Hardware version of the ECM, which might affect compatibility with certain vehicle systems
    InstallDate DATE, -- Date when the ECM was installed on the vehicle
    LastMaintenanceDate DATE, -- Most recent date when the ECM was maintained or checked
    OperationalStatus VARCHAR(50), -- Current operational status of the ECM, e.g., 'Active', 'Maintenance Required', 'Inactive'
    VehicleID INT, -- Link to a table that records which vehicle the ECM is installed in, if this data needs to be tracked
    FOREIGN KEY (ModuleID) REFERENCES ModuleInventoryMaster(ModuleID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Mod_APA ( -- Armored Panel Assemblies (APA): Modular ceramic composite panels used for enhancing ballistic protection.
    APAID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleID INT,
    ModelNumber VARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX), -- Detailed description of the panel's characteristics and ballistic protection capabilities
    ManufacturerID INT, -- Reference to the manufacturer in the Manufacturers table
    MaterialType VARCHAR(50), -- Type of ceramic composite or other material used
    Dimensions VARCHAR(50), -- Dimensions of the panel, which could affect fit and coverage
    Weight FLOAT, -- Weight of the panel, important for assessing load and vehicle performance
    InstallDate DATE, -- Date when the panel was installed on the vehicle
    LastInspectionDate DATE, -- Most recent date when the panel was inspected for integrity and performance
    ConditionStatus VARCHAR(50), -- Current condition of the panel, e.g., 'Good', 'Damaged', 'Needs Replacement'
    VehicleID INT, -- Link to a table that records which vehicle the APA is installed in, if this data needs to be tracked
    FOREIGN KEY (ModuleID) REFERENCES ModuleInventoryMaster(ModuleID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Mod_HydraulicRamp (
    RampID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleID INT,
    ModelNumber VARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX), -- Detailed description of the hydraulic ramp's function and capabilities
    ManufacturerID INT,
    FluidType VARCHAR(50), -- Type of hydraulic fluid used
    SystemPressure FLOAT, -- Operating pressure of the hydraulic system
    InstallDate DATE,
    LastMaintenanceDate DATE,
    OperationalStatus VARCHAR(50), -- Current operational status, e.g., 'Active', 'Maintenance Required', 'Inactive'
    VehicleID INT,
    FOREIGN KEY (ModuleID) REFERENCES ModuleInventoryMaster(ModuleID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Mod_DriveSprocket (
    SprocketID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleID INT,
    ModelNumber VARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX), -- Detailed description of the drive sprocket's role in vehicle propulsion
    ManufacturerID INT,
    MaterialType VARCHAR(50), -- Material used in manufacturing the sprocket
    TeethCount INT, -- Number of teeth on the sprocket
    InstallDate DATE,
    LastMaintenanceDate DATE,
    WearStatus VARCHAR(50), -- Current condition based on wear, e.g., 'Good', 'Worn', 'Replace Soon'
    VehicleID INT,
    FOREIGN KEY (ModuleID) REFERENCES ModuleInventoryMaster(ModuleID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Mod_CTISController (
    CTISControllerID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleID INT,
    ModelNumber VARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX), -- Detailed description of the CTIS Controller's functionalities
    ManufacturerID INT,
    SoftwareVersion VARCHAR(50), -- Software version installed on the controller
    HardwareVersion VARCHAR(50), -- Physical model version of the controller
    InstallDate DATE,
    LastUpdateDate DATE, -- Date of the last software or hardware update
    OperationalStatus VARCHAR(50), -- e.g., 'Active', 'Update Required', 'Inactive'
    VehicleID INT,
    FOREIGN KEY (ModuleID) REFERENCES ModuleInventoryMaster(ModuleID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

/* ==================================================================================================================
   DIMENSIONAL TABLES FOR VEHICLE PARTS MANAGEMENT
   This section includes tables that manage details about individual parts which are either
   in storage inventory, currently deployed and in use, or have been identified as degraded and need to be replaced.
   These tables are designed to facilitate the tracking and management of part lifecycle statuses.
   (Section utilized by maintaining personnel/end users)
   ================================================================================================================== */

/* =====================================================================================
   SUBSECTION: PARTS FOR THE ENGINE CONTROL MODULE (ECM)
   ===================================================================================== */

CREATE TABLE M1126_Part_ECM_Microcontroller ( -- Microcontroller: The brain of the ECM, executes the control software that manages key engine functions.
    MicrocontrollerID INT IDENTITY(1,1) PRIMARY KEY
    ModelNumber VARCHAR(50) NOT NULL,
    ManufacturerID INT,
    PartID INT,
    ClockSpeedMHz FLOAT,
    CoreCount INT,
    MemoryType VARCHAR(30),
    MemorySizeMB INT,
    OperatingTemperatureMinC FLOAT,
    OperatingTemperatureMaxC FLOAT,
    SupplyVoltageMinV FLOAT,
    SupplyVoltageMaxV FLOAT,
    CertificationID INT,
    ECMID INT,
    FOREIGN KEY (ECMID) REFERENCES M1126_ECM(ECMID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Part_ECM_PowerTransistors ( -- Power Transistors: Vital for controlling high-power engine operations, such as activating the fuel injectors and ignition system.
    TransistorID INT IDENTITY(1,1) PRIMARY KEY,
    PartID INT,
    ManufacturerID INT,
    ModelNumber VARCHAR(50),
    MaxCurrentAmps FLOAT,
    MaxVoltageVolts FLOAT,
    PackageType VARCHAR(50),
    OperatingTemperatureRange VARCHAR(50),
    CertificationID INT,
    ECMID INT,
    FOREIGN KEY (ECMID) REFERENCES M1126_Mod_ECM(ECMID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Part_ECM_CANBusInterfaces ( -- CAN (Controller Area Network) Bus Interface: Enables communication between the ECM and other critical vehicle systems.
    CANInterfaceID INT IDENTITY(1,1) PRIMARY KEY,
    PartID INT,
    ManufacturerID INT,
    ModelNumber VARCHAR(50),
    ProtocolVersion VARCHAR(30),
    CommunicationSpeed FLOAT,
    NumberOfChannels INT,
    PhysicalLayer VARCHAR(50),
    CertificationID INT,
    ECMID INT,
    FOREIGN KEY (ECMID) REFERENCES M1126_Mod_ECM(ECMID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Part_ECM_VoltageRegulators ( -- Voltage Regulator: Ensures that the ECM receives a stable power supply despite variations in the vehicle’s electrical system.
    RegulatorID INT IDENTITY(1,1) PRIMARY KEY,
    PartID INT,
    ManufacturerID INT,
    ModelNumber VARCHAR(50),
    InputVoltageRange VARCHAR(50),
    OutputVoltage FLOAT,
    OutputCurrent FLOAT,
    RegulationAccuracy FLOAT,
    EfficiencyPercentage FLOAT,
    CertificationID INT,
    ECMID INT,
    FOREIGN KEY (ECMID) REFERENCES M1126_Mod_ECM(ECMID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

CREATE TABLE M1126_Part_ECM_ADCs ( -- Analog-to-Digital Converters (ADCs): Accurately converts the analog signals from various engine sensors into digital data that the microcontroller can interpret.
    ADCID INT IDENTITY(1,1) PRIMARY KEY,
    PartID INT,
    ManufacturerID INT,
    ModelNumber VARCHAR(50),
    ResolutionBits INT,
    SamplingRate FLOAT,
    InputChannels INT,
    InputRange VARCHAR(50),
    DataInterface VARCHAR(50),
    CertificationID INT,
    ECMID INT,
    FOREIGN KEY (ECMID) REFERENCES M1126_Mod_ECM(ECMID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
);

/* =====================================================================================
   SUBSECTION: PARTS FOR THE Armored Panel Assemblies (APA)
   ===================================================================================== */

CREATE TABLE M1126_Part_APA_CeramicPlates ( -- Ceramic Plates: Key component in armor, absorbs and dissipates kinetic energy from impacts.
    CeramicPlateID INT IDENTITY(1,1) PRIMARY KEY,
    ModelNumber VARCHAR(50) NOT NULL,
    ManufacturerID INT,
    PartID INT,
    MaterialType VARCHAR(50), -- Type of ceramic material, e.g., Silicon Carbide, Boron Carbide
    ThicknessMM FLOAT, -- Thickness of the ceramic plate in millimeters
    DensityKGm3 FLOAT, -- Density of the ceramic material in kg/m^3, affects weight and protection level
    Hardness VARCHAR(50), -- Hardness of the material, important for resistance to penetration
    AbrasionResistance VARCHAR(50), -- Measure of material's ability to withstand surface wear
    ImpactResistance VARCHAR(50), -- Ability to absorb impact without cracking
    APAID INT, -- Reference to the specific APA module these plates are used in
    FOREIGN KEY (APAID) REFERENCES M1126_Mod_APA(APAID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID)
);

CREATE TABLE M1126_Part_APA_CompositeBacking ( -- Composite Backing: Sits behind ceramic plates and absorbs fragments and shock waves after initial impact.
    BackingID INT IDENTITY(1,1) PRIMARY KEY,
    ModelNumber VARCHAR(50) NOT NULL,
    ManufacturerID INT,
    PartID INT,
    MaterialType VARCHAR(50), -- e.g., Kevlar, UHMWPE
    ThicknessMM FLOAT,
    DensityKGm3 FLOAT,
    TensileStrength VARCHAR(50),
    ImpactResistance VARCHAR(50),
    APAID INT,
    FOREIGN KEY (APAID) REFERENCES M1126_APA(APAID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID)
);

CREATE TABLE M1126_Part_APA_SpallLiner ( -- Spall Liner: Located inside the vehicle, behind the armored panels, absorbs shrapnel or spall from inside vehicle.
    SpallLinerID INT IDENTITY(1,1) PRIMARY KEY,
    ModelNumber VARCHAR(50) NOT NULL,
    ManufacturerID INT,
    PartID INT,
    MaterialType VARCHAR(50), -- Material type, e.g., Aramid fabric
    ThicknessMM FLOAT,
    AreaCoverage VARCHAR(50), -- e.g., 'Full Coverage', 'Partial Coverage'
    AbrasionResistance VARCHAR(50),
    ShockAbsorptionLevel VARCHAR(50),
    APAID INT,
    FOREIGN KEY (APAID) REFERENCES M1126_APA(APAID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID)
);

CREATE TABLE M1126_Part_APA_StructuralFrame ( -- Structural Frame: Ensures the positioning and structural integrity of ceramic plates and composite backing.
    FrameID INT IDENTITY(1,1) PRIMARY KEY,
    ModelNumber VARCHAR(50) NOT NULL,
    ManufacturerID INT,
    PartID INT,
    MaterialType VARCHAR(50), -- Material type, e.g., Steel, Aluminum Alloy
    StructuralIntegrity VARCHAR(50), -- Descriptive rating of the frame's ability to handle loads and resist deformation
    CorrosionResistance VARCHAR(50), -- Indicates the frame's ability to resist environmental wear, crucial for longevity
    WeightKG FLOAT,
    APAID INT,
    FOREIGN KEY (APAID) REFERENCES M1126_APA(APAID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID)
);

CREATE TABLE M1126_Part_APA_ShockAbsorptionMaterial ( -- Shock Absorption and Vibration Damping Materials: Reduces shock and vibration, enhancing the comfort and extending the service life.
    MaterialID INT IDENTITY(1,1) PRIMARY KEY,
    ModelNumber VARCHAR(50) NOT NULL,
    ManufacturerID INT,
    PartID INT,
    MaterialType VARCHAR(50), --  e.g., Rubber, Specialized Foam, important for its damping properties
    VibrationDampingRating VARCHAR(50), -- Qualitative rating of the material's capability to damp vibrations
    EnergyAbsorptionRating VARCHAR(50), -- Qualitative rating of the material's ability to absorb energy from impacts
    ThicknessMM FLOAT, -- Thickness of the material, which affects its ability to absorb shock and damp vibrations
    APAID INT,
    FOREIGN KEY (APAID) REFERENCES M1126_APA(APAID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID),
    FOREIGN KEY (PartID) REFERENCES PartsInventoryMaster(PartID)
);
