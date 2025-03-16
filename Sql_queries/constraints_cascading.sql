
----------------Add Check Constraints


-- Patients Table: Ensure gender is either 'Male', 'Female', or 'Other'
ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_Gender
CHECK (gender IN ('Male', 'Female', 'Other'));

-- Billing Table: Ensure payment_status is either 'Paid', 'Unpaid', or 'Partial'
ALTER TABLE Billing
ADD CONSTRAINT CHK_Billing_PaymentStatus
CHECK (payment_status IN ('Paid', 'Unpaid', 'Partial'));

-- Rooms Table: Ensure current_occupancy does not exceed capacity
ALTER TABLE Rooms
ADD CONSTRAINT CHK_Rooms_Occupancy
CHECK (current_occupancy <= capacity);

-- Rooms Table: Ensure is_available is either 0 (false) or 1 (true)
ALTER TABLE Rooms
ADD CONSTRAINT CHK_Rooms_IsAvailable
CHECK (is_available IN (0, 1));
-- Patients Table





-------------Implement Cascading Updates and Deletes


-- Billing Table: Cascade updates and deletes from Patients Table
ALTER TABLE Billing
DROP CONSTRAINT FK__Billing__patient__403A8C7D; -- Drop existing constraint first

ALTER TABLE Billing
ADD CONSTRAINT FK_Billing_Patients
FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Insurance Table: Cascade updates and deletes from Patients Table
ALTER TABLE Insurance
DROP CONSTRAINT FK__Insurance__patie__4316F928; -- Drop existing constraint first

ALTER TABLE Insurance
ADD CONSTRAINT FK_Insurance_Patients
FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Rooms Table: Cascade updates and deletes from Patients Table
ALTER TABLE Rooms
DROP CONSTRAINT FK_Rooms_Patients; -- Drop existing constraint first

ALTER TABLE Rooms
ADD CONSTRAINT FK_Rooms_Patients
FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

