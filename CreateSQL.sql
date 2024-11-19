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


### SQL REPORTS!!!
#Inactive Employee-Client Contacts
SELECT 
    ecc.EmployeeClientId AS Employee_Client_ID,
    ecc.EmployeeId_FK AS Employee_ID,
    ecc.ClientId_FK AS Client_ID,
    c.LegalName AS Client_Legal_Name,
    ecc.ActiveDate AS Start_Date,
    ecc.ExpDate AS End_Date
FROM 
    EmployeeClientContact ecc
JOIN 
    Client c ON ecc.ClientId_FK = c.ClientId
JOIN 
    Employee e ON ecc.EmployeeId_FK = e.EmployeeId
WHERE 
    CURDATE() BETWEEN ecc.ActiveDate AND ecc.ExpDate
ORDER BY 
    ecc.ExpDate ASC;


# Clients by WorkType
SELECT 
    c.ClientId AS Client_ID,
    c.LegalName AS Legal_Name,
    c.FriendlyName AS Friendly_Name,
    r.RoleId AS Role_ID,
    wt.WorkTypeName AS Work_Type
FROM 
    Client c
JOIN 
    Role r ON c.RoleId_FK = r.RoleId
JOIN 
    WorkType wt ON r.RoleTypeId_FK = wt.WorkTypeId
ORDER BY 
    c.LegalName;
    
#Payments by Payment Type

SELECT 
    pt.PaymentType AS Payment_Type,
    p.PaymentId AS Payment_ID,
    p.PaymentName AS Payment_Name,
    p.PaymentDate AS Payment_Date
FROM 
    Payment p
JOIN 
    PaymentType pt ON p.PaymentTypeId_FK = pt.PaymentTypeID
ORDER BY 
    pt.PaymentType, p.PaymentDate DESC;

#Payments Linked to Employees

SELECT 
    ep.EmployeePaymentId AS Employee_Payment_ID,
    p.PaymentName AS Payment_Name,
    p.PaymentDate AS Payment_Date
FROM 
    EmployeePayment ep
JOIN 
    Payment p ON ep.PaymentId_FK = p.PaymentId
JOIN 
    Employee e ON ep.PaymentId_FK = p.PaymentId
ORDER BY 
    p.PaymentDate DESC;

# Stored Procedures
# SP-1 Get Client Payment Summary

DELIMITER $$

CREATE PROCEDURE GetClientPaymentSummary(IN startDate DATE, IN endDate DATE)
BEGIN
    SELECT 
        c.ClientId,
        c.LegalName AS ClientLegalName,
        c.FriendlyName AS ClientFriendlyName,
        pt.PaymentType AS PaymentMethod,
        COUNT(p.PaymentId) AS TotalPayments,
        SUM(CAST(p.PaymentName AS DECIMAL(10, 2))) AS TotalPaymentAmount
    FROM Client c
    JOIN EmployeeClientContact ecc ON c.ClientId = ecc.ClientId_FK
    JOIN EmployeePayment ep ON ecc.EmployeeClientId = ep.TimeSheetId_FK
    JOIN Payment p ON ep.PaymentId_FK = p.PaymentId
    JOIN PaymentType pt ON p.PaymentTypeId_FK = pt.PaymentTypeID
    WHERE p.PaymentDate BETWEEN startDate AND endDate
    GROUP BY c.ClientId, pt.PaymentType
    ORDER BY TotalPaymentAmount DESC;
END $$

DELIMITER ;

CALL GetClientPaymentSummary('2024-01-01', '2024-12-31');

# SP-2 Get Active Employee Assignments by Client

DELIMITER $$

CREATE PROCEDURE GetActiveEmployeeAssignmentsByClient()
BEGIN
    SELECT 
        ecc.EmployeeClientId,
        ecc.EmployeeId_FK AS EmployeeId,
        c.ClientId,
        c.LegalName AS ClientLegalName,
        r.RoleTypeId_FK AS RoleType,
        ecc.ActiveDate,
        ecc.ExpDate
    FROM EmployeeClientContact ecc
    JOIN Client c ON ecc.ClientId_FK = c.ClientId
    JOIN Role r ON c.RoleId_FK = r.RoleId
    WHERE ecc.ExpDate > CURDATE() OR ecc.ExpDate IS NULL
    ORDER BY c.ClientId, ecc.ActiveDate;
END $$

DELIMITER ;

CALL GetActiveEmployeeAssignmentsByClient();

#SP-3 Calculate Payment Summary for Employees

DELIMITER $$

CREATE PROCEDURE CalculateEmployeePaymentSummary()
BEGIN
    SELECT 
        ecc.EmployeeId_FK AS EmployeeId,
        pt.PaymentType AS PaymentMethod,
        COUNT(p.PaymentId) AS TotalPayments,
        SUM(CAST(p.PaymentName AS DECIMAL(10, 2))) AS TotalPaymentAmount
    FROM EmployeeClientContact ecc
    JOIN EmployeePayment ep ON ecc.EmployeeClientId = ep.TimeSheetId_FK
    JOIN Payment p ON ep.PaymentId_FK = p.PaymentId
    JOIN PaymentType pt ON p.PaymentTypeId_FK = pt.PaymentTypeID
    GROUP BY ecc.EmployeeId_FK, pt.PaymentType
    ORDER BY TotalPaymentAmount DESC;
END $$

DELIMITER ;

CALL CalculateEmployeePaymentSummary();
