
--- Listing all stored procedures
SELECT 
    name AS ProcedureName,
    SCHEMA_NAME(schema_id) AS SchemaName,
    create_date,
    modify_date
FROM sys.procedures
ORDER BY SchemaName, ProcedureName;




---Function to clean and standardize city names in the ERP_Master_Patient table

CREATE OR ALTER FUNCTION dbo.FixQuebecCityName(@city NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @fixedCity NVARCHAR(255) = @city;
    
    -- Fix common encoding issues
    SET @fixedCity = REPLACE(@fixedCity, 'A?A©', 'é');
    SET @fixedCity = REPLACE(@fixedCity, 'A?A?', 'é');
    SET @fixedCity = REPLACE(@fixedCity, 'A?A?', 'è');
    SET @fixedCity = REPLACE(@fixedCity, 'A?a€°', 'É');
    SET @fixedCity = REPLACE(@fixedCity, 'A?A?', 'Î');
    SET @fixedCity = REPLACE(@fixedCity, 'A?A?', 'â');
    SET @fixedCity = REPLACE(@fixedCity, 'A©', 'é');
    SET @fixedCity = REPLACE(@fixedCity, 'A?', 'é');
    SET @fixedCity = REPLACE(@fixedCity, 'A?A?', 'ô');
    SET @fixedCity = REPLACE(@fixedCity, 'A?', 'è');
    SET @fixedCity = REPLACE(@fixedCity, 'A?A?', 'ê');
    SET @fixedCity = REPLACE(@fixedCity, 'sui-', 'sur-');
    SET @fixedCity = REPLACE(@fixedCity, 'Rfyal', 'Royal');
    SET @fixedCity = REPLACE(@fixedCity, 'Mogt-', 'Mont-');
    SET @fixedCity = REPLACE(@fixedCity, 'Jfli', 'Joli');
    SET @fixedCity = REPLACE(@fixedCity, 'Prkiries', 'Prairies');
    SET @fixedCity = REPLACE(@fixedCity, 'Pezrot', 'Perrot');
    SET @fixedCity = REPLACE(@fixedCity, 'Bruso', 'Bruno');
    SET @fixedCity = REPLACE(@fixedCity, 'Saiot-', 'Saint-');
    SET @fixedCity = REPLACE(@fixedCity, 'Saiat-', 'Saint-');
    SET @fixedCity = REPLACE(@fixedCity, 'Saqnte-', 'Sainte-');
    SET @fixedCity = REPLACE(@fixedCity, 'JonqjiA?A?re', 'Jonquière');
    SET @fixedCity = REPLACE(@fixedCity, 'LA©vis', 'Lévis');
    SET @fixedCity = REPLACE(@fixedCity, 'LA?nvis', 'Lévis');
    SET @fixedCity = REPLACE(@fixedCity, 'L''Assodption', 'L''Assomption');
    SET @fixedCity = REPLACE(@fixedCity, 'Dollacd-', 'Dollard-');
    SET @fixedCity = REPLACE(@fixedCity, 'cierre', 'Pierre');
    SET @fixedCity = REPLACE(@fixedCity, '-qoup', '-Loup');
    SET @fixedCity = REPLACE(@fixedCity, 'Moets', 'Monts');
    SET @fixedCity = REPLACE(@fixedCity, 'SantA©', 'Santé');
    SET @fixedCity = REPLACE(@fixedCity, 'RiviA?re', 'Rivière');
    
    -- Fix specific city names that are frequently corrupted
    IF @fixedCity LIKE '%Qu%villon%'
        SET @fixedCity = 'Lebel-sur-Quévillon';
    
    IF @fixedCity LIKE '%JonquiA?%' OR @fixedCity LIKE '%JonqjiA?%'
        SET @fixedCity = 'Jonquière';
    
    IF @fixedCity LIKE '%MontrA?%'
        SET @fixedCity = REPLACE(@fixedCity, 'MontrA?A©al', 'Montréal');
        
    IF @fixedCity LIKE '%CA?%dres%'
        SET @fixedCity = 'Les Cèdres';
        
    IF @fixedCity LIKE '%QuA?A©bec%'
        SET @fixedCity = 'Québec';
        
    RETURN @fixedCity;
END;
GO


=====================================================================================================================================================================================
---Stored Procedure: Data Cleaning for ERP_Master_Patient
=====================================================================================================================================================================================

CREATE OR ALTER PROCEDURE DataCleaning
AS
BEGIN
    -- Step 1: Standardize Phone Numbers
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Clean phone_number
        UPDATE ERP_Master_Patient
        SET phone_number = 
            CASE 
                WHEN phone_number IS NULL 
                     OR TRIM(phone_number) = '' 
                     OR LOWER(TRIM(phone_number)) = 'nan' THEN 'n/a'
                WHEN LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(phone_number), '(', ''), ')', ''), '-', ''), '.', ''), ' ', '')) < 10 THEN 'n/a'
                WHEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(phone_number), '(', ''), ')', ''), '-', ''), '.', ''), ' ', '') NOT LIKE '%[^0-9]%'
                     AND LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(phone_number), '(', ''), ')', ''), '-', ''), '.', ''), ' ', '')) = 10
                THEN 
                    SUBSTRING(
                        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(phone_number), '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''),
                        1, 3
                    ) + '-' +
                    SUBSTRING(
                        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(phone_number), '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''),
                        4, 3
                    ) + '-' +
                    SUBSTRING(
                        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(phone_number), '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''),
                        7, 4
                    )
                ELSE 'n/a'
            END;

        -- Clean emergency_contact_phone
        UPDATE ERP_Master_Patient
        SET emergency_contact_phone = 
            CASE 
                WHEN emergency_contact_phone IS NULL 
                     OR TRIM(emergency_contact_phone) = '' 
                     OR LOWER(TRIM(emergency_contact_phone)) = 'nan' THEN 'n/a'
                WHEN LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(emergency_contact_phone), '(', ''), ')', ''), '-', ''), '.', ''), ' ', '')) < 10 THEN 'n/a'
                WHEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(emergency_contact_phone), '(', ''), ')', ''), '-', ''), '.', ''), ' ', '') NOT LIKE '%[^0-9]%'
                     AND LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(emergency_contact_phone), '(', ''), ')', ''), '-', ''), '.', ''), ' ', '')) = 10
                THEN 
                    SUBSTRING(
                        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(emergency_contact_phone), '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''),
                        1, 3
                    ) + '-' +
                    SUBSTRING(
                        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(emergency_contact_phone), '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''),
                        4, 3
                    ) + '-' +
                    SUBSTRING(
                        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(emergency_contact_phone), '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''),
                        7, 4
                    )
                ELSE 'n/a'
            END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'Error in Step 1: Standardize Phone Numbers';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;

    -- Step 2: Clean First and Last Names
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Remove leading/trailing spaces and invalid characters
        UPDATE ERP_Master_Patient
        SET 
            first_name = UPPER(LEFT(first_name, 1)) + LOWER(SUBSTRING(first_name, 2, LEN(first_name))),
            last_name = UPPER(LEFT(last_name, 1)) + LOWER(SUBSTRING(last_name, 2, LEN(last_name)))
        WHERE first_name IS NOT NULL OR last_name IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'Error in Step 2: Clean First and Last Names';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;

    -- Step 3: Remove Duplicate Records
    BEGIN TRY
        BEGIN TRANSACTION;

        WITH CTE AS (
            SELECT 
                patient_id,
                admission_date,
                ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY admission_date DESC) AS RowNum
            FROM ERP_Master_Patient
        )
        DELETE FROM ERP_Master_Patient
        WHERE EXISTS (
            SELECT 1
            FROM CTE
            WHERE CTE.patient_id = ERP_Master_Patient.patient_id
              AND CTE.admission_date = ERP_Master_Patient.admission_date
              AND CTE.RowNum > 1
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'Error in Step 3: Remove Duplicate Records';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;

    -- Step 4: Clean Date Columns
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Swap admission_date and discharge_date if discharge_date is before admission_date
        UPDATE ERP_Master_Patient
        SET 
            admission_date = discharge_date,
            discharge_date = admission_date
        WHERE 
            admission_date IS NOT NULL AND
            discharge_date IS NOT NULL AND
            discharge_date < admission_date;

        -- Delete rows with invalid dob (age out of range)
        DELETE FROM ERP_Master_Patient
        WHERE 
            dob IS NOT NULL AND
            DATEDIFF(YEAR, dob, GETDATE()) NOT BETWEEN 0 AND 100;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'Error in Step 4: Clean Date Columns';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;

    -- Step 5: Clean Address, City, and State Columns
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Replace NULL or empty addresses with 'n/a'
        UPDATE ERP_Master_Patient
        SET address = 'n/a'
        WHERE address IS NULL OR address = '';

        -- Fix encoding issues in city and state columns
        UPDATE ERP_Master_Patient
        SET 
            city = dbo.FixQuebecCityName(city),
            state = dbo.FixStateName(state)
        WHERE city LIKE '%A?%' OR city LIKE '%A©%' OR state LIKE '%A?%' OR state LIKE '%A©%';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'Error in Step 5: Clean Address, City, and State Columns';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;

    -- Step 6: Clean Email and Insurance Provider Columns
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Replace NULL or empty emails with 'n/a'
        UPDATE ERP_Master_Patient
        SET email = 'n/a'
        WHERE email IS NULL OR email = '';

        -- Replace NULL or empty insurance_provider with 'n/a'
        UPDATE ERP_Master_Patient
        SET insurance_provider = 'n/a'
        WHERE insurance_provider IS NULL OR insurance_provider = '';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'Error in Step 6: Clean Email and Insurance Provider Columns';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;

    PRINT 'Data cleaning completed successfully.';
END;


-------------------------
--EXEC DataCleaning;
-------------------------

=====================================================================================================================================================================================
---Stored Procedure: Insert Unique Patients
=====================================================================================================================================================================================

CREATE PROCEDURE LoadPatients
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Patients ( 
        patient_id, first_name, last_name, dob, gender, address, 
        city, state, postal_code, phone_number, email, 
        insurance_provider, insurance_policy_number, blood_type, 
        allergies, medications, diagnosis, admission_date, 
        discharge_date, emergency_contact_name, emergency_contact_phone, 
        emergency_contact_relationship, insurance_expiration_date, 
        blood_pressure, heart_rate, weight, height, temperature
    )
    SELECT 
        emp.patient_id, emp.first_name, emp.last_name, emp.dob, emp.gender, emp.address, 
        emp.city, emp.state, emp.postal_code, emp.phone_number, emp.email, 
        emp.insurance_provider, emp.insurance_policy_number, emp.blood_type, 
        emp.allergies, emp.medications, emp.diagnosis, emp.admission_date, 
        emp.discharge_date, emp.emergency_contact_name, emp.emergency_contact_phone, 
        emp.emergency_contact_relationship, emp.insurance_expiration_date, 
        emp.blood_pressure, emp.heart_rate, emp.weight, emp.height, emp.temperature
    FROM ERP_Master_Patient emp
    WHERE NOT EXISTS (
        SELECT 1 FROM Patients p WHERE p.patient_id = emp.patient_id
    );

    PRINT 'Patients table successfully updated. No duplicates inserted.';
END;


----------------------
EXEC LoadPatients;
----------------------


=====================================================================================================================================================================================
---Stored Procedure: Update Patient Information
=====================================================================================================================================================================================

CREATE PROCEDURE UpdatePatientInfo
    @patient_id VARCHAR(50),
    @first_name VARCHAR(50) = NULL,
    @last_name VARCHAR(50) = NULL,
    @dob DATE = NULL,
    @gender VARCHAR(50) = NULL,
    @address VARCHAR(50) = NULL,
    @city VARCHAR(50) = NULL,
    @state VARCHAR(50) = NULL,
    @postal_code VARCHAR(50) = NULL,
    @phone_number VARCHAR(50) = NULL,
    @email VARCHAR(50) = NULL,
    @insurance_provider VARCHAR(22) = NULL,
    @insurance_policy_number VARCHAR(50) = NULL,
    @blood_type VARCHAR(3) = NULL,
    @allergies VARCHAR(9) = NULL,
    @medications VARCHAR(13) = NULL,
    @diagnosis VARCHAR(15) = NULL,
    @admission_date DATE = NULL,
    @discharge_date DATE = NULL,
    @emergency_contact_name VARCHAR(50) = NULL,
    @emergency_contact_phone VARCHAR(50) = NULL,
    @emergency_contact_relationship VARCHAR(7) = NULL,
    @insurance_expiration_date DATE = NULL,
    @blood_pressure DECIMAL(5,2) = NULL,
    @heart_rate INT = NULL,
    @weight INT = NULL,
    @height INT = NULL,
    @temperature DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Patients
    SET 
        first_name = COALESCE(@first_name, first_name),
        last_name = COALESCE(@last_name, last_name),
        dob = COALESCE(@dob, dob),
        gender = COALESCE(@gender, gender),
        address = COALESCE(@address, address),
        city = COALESCE(@city, city),
        state = COALESCE(@state, state),
        postal_code = COALESCE(@postal_code, postal_code),
        phone_number = COALESCE(@phone_number, phone_number),
        email = COALESCE(@email, email),
        insurance_provider = COALESCE(@insurance_provider, insurance_provider),
        insurance_policy_number = COALESCE(@insurance_policy_number, insurance_policy_number),
        blood_type = COALESCE(@blood_type, blood_type),
        allergies = COALESCE(@allergies, allergies),
        medications = COALESCE(@medications, medications),
        diagnosis = COALESCE(@diagnosis, diagnosis),
        admission_date = COALESCE(@admission_date, admission_date),
        discharge_date = COALESCE(@discharge_date, discharge_date),
        emergency_contact_name = COALESCE(@emergency_contact_name, emergency_contact_name),
        emergency_contact_phone = COALESCE(@emergency_contact_phone, emergency_contact_phone),
        emergency_contact_relationship = COALESCE(@emergency_contact_relationship, emergency_contact_relationship),
        insurance_expiration_date = COALESCE(@insurance_expiration_date, insurance_expiration_date),
        blood_pressure = COALESCE(@blood_pressure, blood_pressure),
        heart_rate = COALESCE(@heart_rate, heart_rate),
        weight = COALESCE(@weight, weight),
        height = COALESCE(@height, height),
        temperature = COALESCE(@temperature, temperature)
    WHERE patient_id = @patient_id;

    PRINT 'Patient information updated successfully.';
END;



-------------------------------------
--EXEC UpdatePatientInfo 
    @patient_id = 'P12345', 
    @phone_number = '123-456-7890', 
    @address = '123 New Street';
-------------------------------------



=====================================================================================================================================================================================
---Stored Procedure: Manage Billing Information
=====================================================================================================================================================================================


CREATE PROCEDURE ManageBillingInfo
    @billing_id INT = NULL,  -- If NULL, a new record will be inserted
    @patient_id VARCHAR(50),
    @total_amount DECIMAL(10,2),
    @amount_paid DECIMAL(10,2),
    @billing_date DATE,
    @due_date DATE,
    @payment_status VARCHAR(20),
    @insurance_coverage DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate if the patient exists
    IF NOT EXISTS (SELECT 1 FROM Patients WHERE patient_id = @patient_id)
    BEGIN
        PRINT 'Error: Patient does not exist.';
        RETURN;
    END

    -- If billing_id is provided, update the existing record
    IF @billing_id IS NOT NULL AND EXISTS (SELECT 1 FROM Billing WHERE billing_id = @billing_id)
    BEGIN
        UPDATE Billing
        SET 
            patient_id = @patient_id,
            total_amount = @total_amount,
            amount_paid = @amount_paid,
            billing_date = @billing_date,
            due_date = @due_date,
            payment_status = @payment_status,
            insurance_coverage = @insurance_coverage
        WHERE billing_id = @billing_id;

        PRINT 'Billing record updated successfully.';
    END
    ELSE
    BEGIN               
        INSERT INTO Billing (patient_id, total_amount, amount_paid, billing_date, due_date, payment_status, insurance_coverage)
        VALUES (@patient_id, @total_amount, @amount_paid, @billing_date, @due_date, @payment_status, @insurance_coverage);

        PRINT 'Billing record inserted successfully.';
    END
END;


---Insert a New Billing Record
-----------------------------------------
--EXEC ManageBillingInfo 
    @billing_id = NULL, 
    @patient_id = 'P12345', 
    @total_amount = 500.00, 
    @amount_paid = 200.00, 
    @billing_date = '2025-02-27', 
    @due_date = '2025-03-10', 
    @payment_status = 'Pending', 
    @insurance_coverage = 100.00;
------------------------------------------

---Update an Existing Billing Record
-----------------------------------------
--EXEC ManageBillingInfo 
    @billing_id = 5, 
    @patient_id = 'P12345', 
    @total_amount = 500.00, 
    @amount_paid = 500.00, 
    @billing_date = '2025-02-27', 
    @due_date = '2025-03-10', 
    @payment_status = 'Paid', 
    @insurance_coverage = 100.00;

-----------------------------------------



=====================================================================================================================================================================================
---Stored Procedure: •	Allocate Room to Patient
=====================================================================================================================================================================================

CREATE PROCEDURE AllocateRoomToPatient2
    @Patient_ID INT,          -- ID of the patient to be admitted
    @Admission_Date DATE      -- Admission date of the patient
AS
BEGIN
    DECLARE @Available_RoomID INT;

    -- Start a transaction to ensure atomicity
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Find the first available room
        SELECT TOP 1 @Available_RoomID = room_number
        FROM Rooms
        WHERE is_available = 1 -- Check for available rooms
        ORDER BY room_number;

        -- If an available room is found
        IF @Available_RoomID IS NOT NULL
        BEGIN
            -- Mark the room as occupied
            UPDATE Rooms
            SET is_available = 0, -- Mark the room as unavailable
                current_occupancy = current_occupancy + 1, -- Increment occupancy
                Patient_ID = @Patient_ID -- Assign the patient to the room
            WHERE room_number = @Available_RoomID;

            -- Update the patient's admission date in the Patients table
            UPDATE Patients
            SET Admission_Date = @Admission_Date
            WHERE Patient_ID = @Patient_ID;

            -- Commit the transaction
            COMMIT TRANSACTION;

            PRINT 'Room ' + CAST(@Available_RoomID AS VARCHAR) + ' has been allocated to Patient ' + CAST(@Patient_ID AS VARCHAR);
        END
        ELSE
        BEGIN
            -- Rollback the transaction if no room is available
            ROLLBACK TRANSACTION;
            PRINT 'No available rooms found.';
        END
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred. Room allocation failed.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;

----------------------------------------------------------------------------------
EXEC AllocateRoomToPatient2 @Patient_ID = 101, @Admission_Date = '2023-10-01';
----------------------------------------------------------------------------------

CREATE PROCEDURE AllocateRoomToPatient3
    @Patient_ID VARCHAR(50), -- ID of the patient to be admitted (VARCHAR)
    @Admission_Date DATE     -- Admission date of the patient
AS
BEGIN
    DECLARE @Available_RoomID INT;

    -- Start a transaction to ensure atomicity
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Find the first available room
        SELECT TOP 1 @Available_RoomID = room_number
        FROM Rooms
        WHERE is_available = 1 -- Check for available rooms
        ORDER BY room_number;

        -- If an available room is found
        IF @Available_RoomID IS NOT NULL
        BEGIN
            -- Mark the room as occupied
            UPDATE Rooms
            SET is_available = 0, -- Mark the room as unavailable
                current_occupancy = current_occupancy + 1, -- Increment occupancy
                Patient_ID = @Patient_ID -- Assign the patient to the room
            WHERE room_number = @Available_RoomID;

            -- Update the patient's admission date in the Patients table
            UPDATE Patients
            SET Admission_Date = @Admission_Date
            WHERE Patient_ID = @Patient_ID;

            -- Commit the transaction
            COMMIT TRANSACTION;

            PRINT 'Room ' + CAST(@Available_RoomID AS VARCHAR) + ' has been allocated to Patient ' + @Patient_ID;
        END
        ELSE
        BEGIN
            -- Rollback the transaction if no room is available
            ROLLBACK TRANSACTION;
            PRINT 'No available rooms found.';
        END
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred. Room allocation failed.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;

------------------------------------------------------------------------------------------
SELECT * FROM Patients WHERE Patient_ID = '1A15VC0TP43';
SELECT * FROM Rooms WHERE is_available = 1;
---------------------------------------------------------------------------------------------
--Executing procedure
--EXEC AllocateRoomToPatient3 @Patient_ID = '1A15VC0TP43', @Admission_Date = '2023-10-01';
------------------------------------------------------------------------------------------------

SELECT * FROM Rooms WHERE Patient_ID = '1A15VC0TP43';
------------------------------------------------------------------------------------------------



=====================================================================================================================================================================================
---Stored Procedure: Record Patient Discharge
=====================================================================================================================================================================================


CREATE PROCEDURE RecordPatientDischarge
    @Patient_ID VARCHAR(50), -- ID of the patient to be discharged
    @Discharge_Date DATE     -- Discharge date of the patient
AS
BEGIN
    DECLARE @Room_Number INT;

    -- Start a transaction to ensure atomicity
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Find the room assigned to the patient
        SELECT @Room_Number = room_number
        FROM Rooms
        WHERE Patient_ID = @Patient_ID;

        -- If the patient is assigned to a room
        IF @Room_Number IS NOT NULL
        BEGIN
            -- Update the patient's discharge date in the Patients table
            UPDATE Patients
            SET Discharge_Date = @Discharge_Date
            WHERE Patient_ID = @Patient_ID;

            -- Mark the room as available and clear the Patient_ID
            UPDATE Rooms
            SET is_available = 1, -- Mark the room as available
                current_occupancy = current_occupancy - 1, -- Decrement occupancy
                Patient_ID = NULL -- Clear the Patient_ID
            WHERE room_number = @Room_Number;

            -- Commit the transaction
            COMMIT TRANSACTION;

            PRINT 'Patient ' + @Patient_ID + ' has been discharged. Room ' + CAST(@Room_Number AS VARCHAR) + ' is now available.';
        END
        ELSE
        BEGIN
            -- Rollback the transaction if the patient is not assigned to a room
            ROLLBACK TRANSACTION;
            PRINT 'Patient ' + @Patient_ID + ' is not assigned to any room.';
        END
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred. Patient discharge failed.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;


begin transaction 
--------------------------------------------------------------------------------------
EXEC RecordPatientDischarge @Patient_ID = '1A15VC0TP43', @Discharge_Date = '2023-10-05';
--------------------------------------------------------------------------------------
rollback



=====================================================================================================================================================================================
---Stored Procedure: 	Process Payment
=====================================================================================================================================================================================

CREATE PROCEDURE ProcessPayment
    @Billing_ID INT,               -- ID of the billing record
    @Payment_Amount DECIMAL(10, 2), -- Amount being paid
    @Payment_Date DATE             -- Date of the payment
AS
BEGIN
    DECLARE @Total_Amount DECIMAL(10, 2);
    DECLARE @Amount_Paid DECIMAL(10, 2);
    DECLARE @Remaining_Amount DECIMAL(10, 2);
    DECLARE @Payment_Status VARCHAR(20);

    -- Start a transaction to ensure atomicity
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Get the total amount and amount paid for the billing record
        SELECT 
            @Total_Amount = total_amount,
            @Amount_Paid = amount_paid
        FROM Billing
        WHERE Billing_ID = @Billing_ID;

        -- If the billing record exists
        IF @Total_Amount IS NOT NULL
        BEGIN
            -- Calculate the remaining amount due
            SET @Remaining_Amount = @Total_Amount - @Amount_Paid;

            -- Check if the payment amount exceeds the remaining amount due
            IF @Payment_Amount > @Remaining_Amount
            BEGIN
                -- Rollback the transaction if the payment amount is invalid
                ROLLBACK TRANSACTION;
                PRINT 'Payment amount exceeds the remaining amount due. Payment not processed.';
            END
            ELSE
            BEGIN
                -- Update the amount paid in the Billing table
                UPDATE Billing
                SET amount_paid = amount_paid + @Payment_Amount -- Add to the total amount paid
                WHERE Billing_ID = @Billing_ID;

                -- Determine the payment status
                IF (@Amount_Paid + @Payment_Amount) >= @Total_Amount
                BEGIN
                    SET @Payment_Status = 'Paid'; -- Fully paid
                END
                ELSE
                BEGIN
                    SET @Payment_Status = 'Partially Paid'; -- Partially paid
                END;

                -- Update the payment status in the Billing table
                UPDATE Billing
                SET payment_status = @Payment_Status
                WHERE Billing_ID = @Billing_ID;

                -- Commit the transaction
                COMMIT TRANSACTION;

                PRINT 'Payment of ' + CAST(@Payment_Amount AS VARCHAR) + ' processed successfully for Billing ID ' + CAST(@Billing_ID AS VARCHAR) + '.';
                PRINT 'Payment Status: ' + @Payment_Status;
            END
        END
        ELSE
        BEGIN
            -- Rollback the transaction if the billing record does not exist
            ROLLBACK TRANSACTION;
            PRINT 'Billing record not found. Payment not processed.';
        END
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred. Payment processing failed.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;

------------------------------------------------------------------------------------------------
--EXEC ProcessPayment @Billing_ID = 101, @Payment_Amount = 500.00, @Payment_Date = '2023-10-05';
------------------------------------------------------------------------------------------------
---cheking 
SELECT * FROM  Billing WHERE NOT payment_status = 'overdue'
