CREATE DATABASE HartAnglesDB;
USE HartAnglesDB;

CREATE TABLE WorkType (
    WorkTypeId INT PRIMARY KEY,
    WorkTypeName VARCHAR(20)
);


CREATE TABLE PaymentType (
    PaymentTypeID INT PRIMARY KEY,
    PaymentType VARCHAR(100)
);

CREATE INDEX idx_payment_type ON PaymentType (PaymentType);

CREATE TABLE Role (
    RoleId INT PRIMARY KEY,
    PersonId_FK INT,
    RoleTypeId_FK INT,
    FOREIGN KEY (PersonId_FK) REFERENCES Person(PersonId), 
    FOREIGN KEY (RoleTypeId_FK) REFERENCES RoleType(RoleTypeId)
);

CREATE INDEX idx_role_person ON Role (PersonId_FK);
CREATE INDEX idx_role_type ON Role (RoleTypeId_FK);

CREATE TABLE Client (
    ClientId INT PRIMARY KEY,
    CompanyId_FK INT,
    RoleId_FK INT,
    LegalName VARCHAR(50),
    FriendlyName VARCHAR(50),
    FOREIGN KEY (RoleId_FK) REFERENCES Role(RoleId),
    FOREIGN KEY (CompanyId_FK) REFERENCES Company(CompanyId)
);

CREATE INDEX idx_client_role_company ON Client (RoleId_FK, CompanyId_FK);

CREATE TABLE EmployeeClientContact (
    EmployeeClientId INT PRIMARY KEY,
    EmployeeId_FK INT,
    ClientId_FK INT,
    ActiveDate DATE,
    ExpDate DATE,
    FOREIGN KEY (EmployeeId_FK) REFERENCES Employee(EmployeeId), 
    FOREIGN KEY (ClientId_FK) REFERENCES Client(ClientId)
);

CREATE INDEX idx_ecc_client ON employeeclientcontact (ClientId_FK);
CREATE INDEX idx_ecc_employee ON EmployeeClientContact (EmployeeId_FK);

CREATE TABLE Payment (
    PaymentId INT PRIMARY KEY,
    PaymentTypeId_FK INT,
    PaymentName VARCHAR(100),
    PaymentDate DATE,
    FOREIGN KEY (PaymentTypeId_FK) REFERENCES PaymentType(PaymentTypeID)
);

CREATE INDEX idx_payment_date ON Payment (PaymentDate);

CREATE TABLE EmployeePayment (
    EmployeePaymentId INT PRIMARY KEY,
    PaymentId_FK INT,
    TimeSheetId_FK INT,
    FOREIGN KEY (PaymentId_FK) REFERENCES Payment(PaymentId),
    FOREIGN KEY (TimeSheetId_FK) REFERENCES TimeSheet(TimeSheetId)
);

CREATE INDEX idx_ep_payment ON EmployeePayment (PaymentId_FK);
CREATE INDEX idx_ep_timesheet ON EmployeePayment (TimeSheetId_FK);

CREATE TABLE Person (
	PersonId INT PRIMARY KEY
);

CREATE TABLE RoleType (
	RoleTypeId INT PRIMARY KEY
);

CREATE TABLE Employee (
	EmployeeId INT PRIMARY KEY
);

CREATE TABLE TimeSheet (
	TimeSheetId INT PRIMARY KEY
);

CREATE TABLE Company (
	CompanyId INT PRIMARY KEY
);


