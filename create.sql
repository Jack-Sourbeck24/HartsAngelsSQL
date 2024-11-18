-- Table for WorkType
CREATE TABLE WorkType (
    WorkTypeId INT PRIMARY KEY,
    WorkTypeName VARCHAR(20)
);

-- Table for PaymentType
CREATE TABLE PaymentType (
    PaymentTypeID INT PRIMARY KEY,
    PaymentType VARCHAR(100)
);

-- Table for Role
CREATE TABLE Role (
    RoleId INT PRIMARY KEY,
    PersonId_FK INT,
    RoleTypeId_FK INT,
    FOREIGN KEY (PersonId_FK) REFERENCES Person(PersonId), 
    FOREIGN KEY (RoleTypeId_FK) REFERENCES RoleType(RoleTypeId)
);

-- Table for Client
CREATE TABLE Client (
    ClientId INT PRIMARY KEY,
    CompanyId_FK INT,
    RoleId_FK INT,
    LegalName VARCHAR(50),
    FriendlyName VARCHAR(50),
    FOREIGN KEY (RoleId_FK) REFERENCES Role(RoleId),
    FOREIGN KEY (CompanyId_FK) REFERENCES Company(CompanyId)
);

-- Table for EmployeeClientContact
CREATE TABLE EmployeeClientContact (
    EmployeeClientId INT PRIMARY KEY,
    EmployeeId_FK INT,
    ClientId_FK INT,
    ActiveDate DATE,
    ExpDate DATE,
    FOREIGN KEY (EmployeeId_FK) REFERENCES Employee(EmployeeId), 
    FOREIGN KEY (ClientId_FK) REFERENCES Client(ClientId)
);

-- Table for Payment
CREATE TABLE Payment (
    PaymentId INT PRIMARY KEY,
    PaymentTypeId_FK INT,
    PaymentName VARCHAR(100),
    PaymentDate DATE,
    FOREIGN KEY (PaymentTypeId_FK) REFERENCES PaymentType(PaymentTypeID)
);

-- Table for EmployeePayment
CREATE TABLE EmployeePayment (
    EmployeePaymentId INT PRIMARY KEY,
    PaymentId_FK INT,
    TimeSheetId_FK INT,
    FOREIGN KEY (PaymentId_FK) REFERENCES Payment(PaymentId),
    FOREIGN KEY (TimeSheetId_FK) REFERENCES TimeSheet(TimeSheetId)
);


