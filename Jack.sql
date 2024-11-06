
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

CREATE TABLE Project (
ProjectId INT NOT NULL AUTO_INCREMENT,
WorkId_FK INT NOT NULL,
ContractId_FK INT NOT NULL,
PRIMARY KEY(ProjectId),
FOREIGN KEY(ContractId_FK) REFERENCES Contract(ContractId),
FOREIGN KEY(WorkId_FK) REFERENCES Work(WorkId),
);


CREATE TABLE MetricType (
MetricTypeId INT NOT NULL AUTO_INCREMENT,
MetricType VARCHAR(100),
MetTypeActiveDate DATE,
MetTypeExpDate DATE,
PRIMARY KEY(MetricTypeId)
);

CREATE TABLE MetricValue (
MetricValueId INT NOT NULL AUTO_INCREMENT,
MetricValue VARCHAR(100),
PRIMARY KEY(MetricValueId)
);

CREATE TABLE MetricQuestion (
MetricQuestionId INT NOT NULL AUTO_INCREMENT,
MetricQuestion VARCHAR(100),
PRIMARY KEY(MetricQuestionId)
);

CREATE TABLE Metric (
MetricId INT NOT NULL AUTO_INCREMENT,
MetricDesc VARCHAR(100),
WorkId INT NOT NULL,
MetricTypeId_FK INT NOT NULL,
PRIMARY KEY(MetricID),
FOREIGN KEY(WorkId_FK) REFERENCES Work(WorkId),
FOREIGN KEY(MetricTypeId_FK) REFERENCES MetricType(MetricTypeId)
);

CREATE TABLE MetricAnswer (
MetricAnswerId INT NOT NULL AUTO_INCREMENT,
MetricAnswer VARCHAR(100),
MetAnsRecordedDate DATE,
MetricId_FK INT NOT NULL,
MetricQuestionId_FK INT NOT NULL,
MetricValueId_FK INT NOT NULL,
PRIMARY KEY(MetricAnswerId),
FOREIGN KEY(MetricId_FK) REFERENCES Metric(MetricId),
FOREIGN KEY(MetricQuestionId_FK) REFERENCES MetricQuestion(MetricQuestionId),
FOREIGN KEY(MetricValueId_FK) REFERENCES MetricValue(MetricValueId)
);

CREATE TABLE Contract (
ContractId INT NOT NULL AUTO_INCREMENT,
WorkId_FK INT NOT NULL,
Primary Key(ContractId),
FOREIGN KEY(WorkId_FK) REFERENCES Work(WorkId)
);

