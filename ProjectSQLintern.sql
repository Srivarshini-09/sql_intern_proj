-- PROJECT : Hospital management system

CREATE DATABASE IF NOT EXISTS hospitalDB;
USE hospitalDB;

-- Create Table

CREATE TABLE patients(
PatientID INT auto_increment PRIMARY KEY,
Name VARCHAR(100),
Age INT,
Gender VARCHAR(10),
Phone VARCHAR(15),
Status VARCHAR(20),
CreatedAt DATETIME DEFAULT NOW()
);

CREATE TABLE Doctors(
DoctorID INT auto_increment PRIMARY KEY,
Name VARCHAR(20),
Speciality VARCHAR(100),
Phone VARCHAR(15),
Department VARCHAR(100)
);

CREATE TABLE Appointments(
AppointmentID INT auto_increment PRIMARY KEY,
PatientID INT,
DoctorID INT,
AppointmentDate DATE,
Status VARCHAR(20) DEFAULT 'Scheduled',
FOREIGN KEY (PatientID) REFERENCES patients(PatientID),
FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

CREATE TABLE Visits(
VisitID INT auto_increment PRIMARY KEY,
AppointmentID INT,
Diagnosis TEXT,
VisitDate DATETIME DEFAULT NOW(),
FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
); 

CREATE TABLE Bills(
BillID INT auto_increment PRIMARY KEY,
VisitID INT,
Amount  DECIMAL(10,2),
IsPaid BOOLEAN DEFAULT FALSE,
FOREIGN KEY (VisitID) REFERENCES Visits(VisitID)
);

CREATE TABLE payments(
BillID INT,
PaymentDate DATE, 
PaidAmount INT
);

-- Insert values into created tables

INSERT INTO patients(Name,Age,Gender,Phone,Status)
VALUES('Rahul',34,'male','9875264601','Admitted'),
('Priya',28,'female','9765270974','Admitted'),
('Aman',45,'male','9683619203','Discharged'),
('Sneha',30,'female','9573981250','Admitted'),
('Vikram',52,'male','9438760981','Discharged'),
('Diya',22,'female','9338760981','Discharged');

INSERT INTO Doctors (Name, Speciality, Phone, Department) 
VALUES('Dr. Arjun Rao', 'Cardiologist', '9123451234', 'Cardiology'),
('Dr. Meera Nair', 'Neurologist', '9345678123', 'Neurology'),
('Dr. Karthik Iyer', 'Dermatologist', '9456123789', 'Dermatology'),
('Dr. Shalini S', 'General Physician', '9876123400', 'General'),
('Dr. Vivek M', 'Orthopedic', '9098765432', 'Orthopedics');

INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status) 
VALUES(1, 1, '2025-07-20', 'Scheduled'),
(2, 2, '2025-07-18', 'Completed'),
(3, 4, '2025-07-10', 'Completed'),
(4, 3, '2025-07-21', 'Scheduled'),
(5, 5, '2025-07-15', 'Completed');

INSERT INTO Visits (AppointmentID, Diagnosis) 
VALUES(6, 'Migraine - prescribed medication and rest'),
(8, 'Routine health check - all normal'),
(10, 'Fracture - leg cast applied');

INSERT INTO Bills (VisitID, Amount, IsPaid) 
VALUES(4, 3500.00, TRUE),
(5, 2000.00, TRUE),
(6, 8000.00, FALSE);

INSERT INTO Payments (BillID, PaymentDate, PaidAmount) 
VALUES(1, '2025-07-11', 3500.00),
(2, '2025-07-12', 2000.00);

-- Queries for appointments and payments

-- showing all upcoming appointments
SELECT A.AppointmentID, P.Name AS Patient, D.Name AS Doctor, A.AppointmentDate
FROM Appointments A
JOIN Patients P ON A.PatientID = P.PatientID
JOIN Doctors D ON A.DoctorID = D.DoctorID
WHERE A.AppointmentDate >= CURDATE();     -- filters the result to include only where the appointment date is today or in future

-- showing unpaid bills
SELECT B.BillID, P.Name, B.Amount
FROM Bills B
JOIN Visits V ON B.VisitID = V.VisitID
JOIN Appointments A ON V.AppointmentID = A.AppointmentID
JOIN Patients P ON A.PatientID = P.PatientID
WHERE B.IsPaid = FALSE;     -- filter to show only unpaid bills

-- stored procedures for billing calculations

DELIMITER //
CREATE PROCEDURE CalculateBill(IN Appointment_ID INT)
BEGIN
DECLARE billAmount DECIMAL(10,2);
SET billAmount = 5000;
INSERT into Bills(VisitID,Amount) VALUES 
((SELECT VisitID FROM Visits WHERE Appointment_ID = AppointmentID),billAmount
);
END //
DELIMITER ;

CALL CalculateBill(7);

-- Adding triggers for discharge and status update

DELIMITER //
CREATE trigger AutoDischarge
AFTER UPDATE on Bills
FOR each row            -- trigger runs once for every row when row updates
BEGIN
IF NEW.IsPaid = TRUE THEN    -- checks if ispaid column is updated
UPDATE Patients SET Status = 'Discharged'       -- if bill is paid it updates the status to discharged
where PatientID = (
SELECT A.PatientID FROM Appointments A JOIN Visits V ON
A.AppointmentID = V.AppointmentID WHERE V.VisitID = NEW.VisitID);
END IF;
END //
DELIMITER ;	

select * from bills ;