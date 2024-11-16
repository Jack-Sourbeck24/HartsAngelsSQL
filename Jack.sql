
CREATE TABLE Entity(
EntityId INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(EntityId)
);

CREATE TABLE Work (
WorkId INT NOT NULL  AUTO_INCREMENT,
WorkName VARCHAR(100),
WorkStartDate DATE,
WorkEndDate DATE,
EntityId_FK INT NOT NULL,
WorkTypeId_FK INT NOT NULL,
PRIMARY KEY(WorkId),
FOREIGN KEY(EntityId_FK) REFERENCES Entity(EntityId),
FOREIGN KEY(WorkTypeId_FK) REFERENCES WorkType(WorkTypeId)
);
CREATE INDEX IDX_WORK_WORK_NAME ON Work(WorkName);
CREATE INDEX IDX_WORK_EntityId_FK ON Work(EntityId_FK);

CREATE TABLE Contract (
ContractId INT NOT NULL AUTO_INCREMENT,
WorkId_FK INT NOT NULL,
Primary Key(ContractId),
FOREIGN KEY(WorkId_FK) REFERENCES Work(WorkId)
);
Create INDEX IDX_CONTRACT_WORKId_FK ON Contract(Work_Id_FK);

CREATE TABLE Project (
ProjectId INT NOT NULL AUTO_INCREMENT,
WorkId_FK INT NOT NULL,
ContractId_FK INT NOT NULL,
PRIMARY KEY(ProjectId),
FOREIGN KEY(ContractId_FK) REFERENCES Contract(ContractId),
FOREIGN KEY(WorkId_FK) REFERENCES Work(WorkId),
);
CREATE INDEX IDX_PROJECT_WorkId_FK ON Project(WorkID_FK);
CREATE INDEX IDX_PROJECT_ContractId_FK ON PROJECT(ContractId_FK);



CREATE TABLE MetricType (
MetricTypeId INT NOT NULL AUTO_INCREMENT,
MetricType VARCHAR(100),
MetricTypeActiveDate DATE,
MetTypeExpDate DATE,
PRIMARY KEY(MetricTypeId)
);
CREATE INDEX IDX_METRICTYPE_MetricType ON MetricType(MetricType);

CREATE TABLE MetricValue (
MetricValueId INT NOT NULL AUTO_INCREMENT,
MetricValue VARCHAR(100),
PRIMARY KEY(MetricValueId)
);
CREATE INDEX IDX_METRICVALUE_MetricValue ON MetricValue(MetricValue);

CREATE TABLE MetricQuestion (
MetricQuestionId INT NOT NULL AUTO_INCREMENT,
MetricQuestion VARCHAR(100),
PRIMARY KEY(MetricQuestionId)
);
CREATE INDEX IDX_METRICQUESTION_MetricQuestion ON MetricQuestion(MetricQuestion);

CREATE TABLE Metric (
MetricId INT NOT NULL AUTO_INCREMENT,
MetricDesc VARCHAR(100),
WorkId_FK INT NOT NULL,
MetricTypeId_FK INT NOT NULL,
PRIMARY KEY(MetricID),
FOREIGN KEY(WorkId_FK) REFERENCES Work(WorkId),
FOREIGN KEY(MetricTypeId_FK) REFERENCES MetricType(MetricTypeId)
);
CREATE INDEX IDX_METRIC_WorkId_FK ON Metric(WorkID_FK);
CREATE INDEX IDX_METRIC_MetricTypeId_FK ON Metric(MetricTypeId_FK);

CREATE TABLE MetricAnswer (
MetricAnswerId INT NOT NULL AUTO_INCREMENT,
MetAnsRecordedDate DATE,
MetricId_FK INT NOT NULL,
MetricQuestionId_FK INT NOT NULL,
MetricValueId_FK INT NOT NULL,
PRIMARY KEY(MetricAnswerId),
FOREIGN KEY(MetricId_FK) REFERENCES Metric(MetricId),
FOREIGN KEY(MetricQuestionId_FK) REFERENCES MetricQuestion(MetricQuestionId),
FOREIGN KEY(MetricValueId_FK) REFERENCES MetricValue(MetricValueId)
);
CREATE INDEX IDX_METRICANSWER_MetricId_FK MetricAnswer(MetricId_FK);
CREATE INDEX IDX_METRICANSWER_MetricQuestionId_FK MetricAnswer(MetricQuestionId_FK);
CREATE INDEX IDX_METRICANSWER_MetricAnswer_FK MetricAnswer(MetricValueId_FK);

--Report 1 Metric Report
DECLARE usr_dclr_MetricId INT DEFAULT 24
SELECT 
MetricDesc AS Description,
NULL AS MetricQuestion,
NULL AS MetricValue,
NULL AS MetAnsRecordedDate
FROM 
    Metric 
WHERE 
    MetricId = usr_dclr_MetricId

UNION ALL 
SELECT 
    mq.MetricQuestion,
    Mv.MetricValue,
    ma.MetAnsRecordedDate
FROM 
    Metric m 
    INNER JOIN MetricAnswer ma ON m.MetricId = ma.MetricId_FK 
    INNER JOIN MetricValue mv ON ma.MetricValueId_FK = mv.MetricValueId
    INNER JOIN MetricQuestion mq ON ma.MetricQuestionId_FK = mq.MetricQuestionId
WHERE 
    m.MetricId = MetricId = usr_dclr_MetricId

--Report 2: Project Hirearchy
DECLARE usr_dclr_ContractId DEFAULT 22
SELECT 
    ProjectId
FROM 
    Project p 
WHERE 
    ContractId_FK = usr_dclr_ContractId 

--Reprot 3: Metric's under Work
DECLARE usr_dclr_WorkId DEFAULT = 1
SELECT 
    MetricId
FROM 
    Metric m
WHERE
    WorkId_FK = usr_dclr_WorkId 

--STP 1: Tie Work with contract/project
CREATE PROCEDURE MoveProject(IN ContractId_IN INT, IN ProjectId_IN INT, OUT RowsUpdated_OUT)
BEGIN
Update Project SET ContractId = ContractId_IN WHERE ProjectId = ProjectID_IN;
SET ROWS
END
--STP 2: Modify Q&A for Metric
CREATE PROCEDURE UpdateMetric(IN Question_IN INT, IN Value_IN INT, OUT RowsUpdated_OUT INT)
BEGIN
    IF Question_IN IS NOT NULL AND Value_IN IS NOT NULL THEN 
        Update MetricAnswer SET MetricQuestionId_FK = Question_IN, MetricValueId_FK = Value_IN WHERE ProjectId = ProjectID_IN;
    IF Question_IN IS NOT NULL AND Value_IN IS NULL THEN
        Update MetricAnswer SET MetricQuestionId_FK = Question_IN WHERE ProjectId = ProjectID_IN;
    IF Question_IN IS NULL AND Value_IN IS NOT NULL THEN
        Update MetricAnswer SET MetricValueId_FK = Value_IN WHERE ProjectId = ProjectID_IN;
    IF Question_IN IS NULL AND Value_IN IS NULL THEN
    SET RowsUpdated_OUT = SELECT ROW_COUNT();
    END;
END