
-----------Backup  Data:
SELECT * INTO ERP_Master_Patient_Backup FROM ERP_Master_Patient;



select * from ERP_Master_Patient

-- Listing all columns in the table 

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ERP_Master_Patient';

                                                      --DATA CLEANING--
====================================================================================================================================================
--Step 1: Standardize Phone Numbers
--Columns: phone_number, emergency_contact_phone
====================================================================================================================================================


select phone_number, emergency_contact_phone from ERP_Master_Patient

--begin transaction

UPDATE ERP_Master_Patient
SET phone_number = 
    CASE 
        -- Handle NULL, empty strings, and 'nan'
        WHEN phone_number IS NULL 
             OR TRIM(phone_number) = '' 
             OR LOWER(TRIM(phone_number)) = 'nan' THEN 'n/a'
        
        -- Get cleaned number for validation
        WHEN LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(phone_number), '(', ''), ')', ''), '-', ''), '.', ''), ' ', '')) < 10 THEN 'n/a'
        
        -- Format valid 10-digit numbers
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

--rollback 



====================================================================================================================================================
--Step 2: Cheking data quality
--Columns: first_name, last_name
====================================================================================================================================================


	SELECT
    'NULL or Empty' AS IssueType,
    COUNT(*) AS IssueCount
FROM ERP_Master_Patient
WHERE first_name IS NULL OR first_name = ''
   OR last_name IS NULL OR last_name = ''
UNION ALL
SELECT
    'Leading/Trailing Spaces',
    COUNT(*)
FROM ERP_Master_Patient
WHERE first_name LIKE ' %' OR first_name LIKE '% '
   OR last_name LIKE ' %' OR last_name LIKE '% '
UNION ALL
SELECT
    'Invalid Characters',
    COUNT(*)
FROM ERP_Master_Patient
WHERE first_name LIKE '%[^a-zA-Z \-'']%'
   OR last_name LIKE '%[^a-zA-Z \-'']%'
UNION ALL
SELECT
    'Inconsistent Capitalization',
    COUNT(*)
FROM ERP_Master_Patient
WHERE first_name NOT LIKE UPPER(LEFT(first_name, 1)) + '%'
   OR last_name NOT LIKE UPPER(LEFT(last_name, 1)) + '%'
UNION ALL
SELECT
    'Unusual Name Lengths',
    COUNT(*)
FROM ERP_Master_Patient
WHERE LEN(first_name) < 2 OR LEN(first_name) > 50
   OR LEN(last_name) < 2 OR LEN(last_name) > 50
UNION ALL
SELECT
    'Duplicate Names',
    COUNT(*)
FROM (
    SELECT first_name, last_name
    FROM ERP_Master_Patient
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
) AS DuplicateNames
UNION ALL
SELECT
    'Special Cases (e.g., Numbers)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE first_name LIKE '%[0-9]%'
   OR last_name LIKE '%[0-9]%'
UNION ALL
SELECT
    'Mixed Case Issues',
    COUNT(*)
FROM ERP_Master_Patient
WHERE first_name COLLATE Latin1_General_BIN = UPPER(first_name)
   OR first_name COLLATE Latin1_General_BIN = LOWER(first_name)
   OR last_name COLLATE Latin1_General_BIN = UPPER(last_name)
   OR last_name COLLATE Latin1_General_BIN = LOWER(last_name)
UNION ALL
SELECT
    'Non-Standard Formats (e.g., Multiple Spaces)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE first_name LIKE '%  %'
   OR last_name LIKE '%  %';
  






  SELECT *
FROM ERP_Master_Patient
WHERE first_name LIKE '%[^a-zA-Z \-'']%'
   OR last_name LIKE '%[^a-zA-Z \-'']%';
	


	SELECT first_name, last_name, COUNT(*) AS DuplicateCount
FROM ERP_Master_Patient
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;
	
	
WITH DuplicateNames AS (
    SELECT
        *,
        COUNT(*) OVER (PARTITION BY first_name, last_name) AS DuplicateCount
    FROM ERP_Master_Patient
)
SELECT *
FROM DuplicateNames
WHERE DuplicateCount > 1
ORDER BY first_name, last_name;	
	


====================================================================================================================================================
--Step 3: deleting duplicates
--Columns: patient_id 
====================================================================================================================================================


---Check for Duplicate Values

SELECT patient_id, COUNT(*) AS DuplicateCount
FROM ERP_Master_Patient
GROUP BY patient_id
HAVING COUNT(*) > 1;



with DuplicateID as (
	select *,
	Count(*) Over (partition by patient_id) as duplicatecount
	from erp_master_patient
	)
	select * from duplicateid where duplicatecount>1
	order by patient_id


-------------------------------------------------------------------------------------------------------

----Identify Duplicates and Keep the Latest admission_date

WITH  CTE AS (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY admission_date DESC) AS RowNum
		FROM erp_master_patient
)
SELECT * FROM CTE WHERE  RowNum >1 

----Delete Duplicates

BEGIN TRANSACTION 

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

COMMIT TRANSACTION

	
---Changing the  values in the firstname and lastname columns to capital letters (only first letters)

UPDATE Erp_master_patient
SET 
    first_name = UPPER(LEFT(first_name, 1)) + LOWER(SUBSTRING(first_name, 2, LEN(first_name))),
    last_name = UPPER(LEFT(last_name, 1)) + LOWER(SUBSTRING(last_name, 2, LEN(last_name)));


select * from ERP_Master_Patient


====================================================================================================================================================
--Step 3: Working with date columns 
--Columns:  dob, admission_date, discharge_date, insurance_expiration_date 
====================================================================================================================================================




-- NULL or Empty Checks
SELECT
    'NULL or Empty (dob)' AS IssueType,
    COUNT(*) AS IssueCount
FROM ERP_Master_Patient
WHERE dob IS NULL
UNION ALL
SELECT
    'NULL or Empty (admission_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE admission_date IS NULL
UNION ALL
SELECT
    'NULL or Empty (discharge_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE discharge_date IS NULL
UNION ALL
SELECT
    'NULL or Empty (insurance_expiration_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE insurance_expiration_date IS NULL

UNION ALL

-- Future Dates Checks
SELECT
    'Future Dates (dob)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE dob > GETDATE()
UNION ALL
SELECT
    'Future Dates (admission_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE admission_date > GETDATE()
UNION ALL
SELECT
    'Future Dates (discharge_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE discharge_date > GETDATE()
UNION ALL
SELECT
    'Future Dates (insurance_expiration_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE insurance_expiration_date < GETDATE()

UNION ALL

-- Unrealistic Dates (Before 1900) Checks
SELECT
    'Unrealistic Dates (Before 1900 - dob)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE dob < '1900-01-01'
UNION ALL
SELECT
    'Unrealistic Dates (Before 1900 - admission_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE admission_date < '1900-01-01'
UNION ALL
SELECT
    'Unrealistic Dates (Before 1900 - discharge_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE discharge_date < '1900-01-01'
UNION ALL
SELECT
    'Unrealistic Dates (Before 1900 - insurance_expiration_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE insurance_expiration_date < '1900-01-01'

UNION ALL

-- Logical Inconsistency Checks
SELECT
    'Logical Inconsistency (discharge_date before admission_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE 
    admission_date IS NOT NULL AND
    discharge_date IS NOT NULL AND
    discharge_date < admission_date
UNION ALL
SELECT
    'Logical Inconsistency (insurance_expiration_date before admission_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE 
    admission_date IS NOT NULL AND
    insurance_expiration_date IS NOT NULL AND
    insurance_expiration_date < admission_date

UNION ALL

-- Default Values Checks (for date columns, we check for common default minimum dates)
SELECT
    'Default Values (dob - min date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE dob = '1900-01-01'
UNION ALL
SELECT
    'Default Values (admission_date - min date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE admission_date = '1900-01-01'
UNION ALL
SELECT
    'Default Values (discharge_date - min date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE discharge_date = '1900-01-01'
UNION ALL
SELECT
    'Default Values (insurance_expiration_date - min date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE insurance_expiration_date = '1900-01-01'

UNION ALL

-- Age Out of Range Check
SELECT
    'Age Out of Range (dob)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE 
    dob IS NOT NULL AND
    DATEDIFF(YEAR, dob, GETDATE()) NOT BETWEEN 0 AND 100;



	-- Logical Inconsistency Checks
SELECT
    'Logical Inconsistency (discharge_date before admission_date)',
    COUNT(*)
FROM ERP_Master_Patient
WHERE 
    admission_date IS NOT NULL AND
    discharge_date IS NOT NULL AND
    discharge_date < admission_date

	
		-- Logical Inconsistency Checks
SELECT
   admission_date,
   discharge_date
FROM ERP_Master_Patient
WHERE 
    admission_date IS NOT NULL AND
    discharge_date IS NOT NULL AND
    discharge_date < admission_date



-- Swap admission_date and discharge_date

UPDATE ERP_Master_Patient
SET 
    admission_date = discharge_date,
    discharge_date = admission_date
WHERE 
    admission_date IS NOT NULL AND
    discharge_date IS NOT NULL AND
    discharge_date < admission_date;

-- Verify the results

SELECT admission_date, discharge_date
FROM ERP_Master_Patient
WHERE 
    admission_date IS NOT NULL AND
    discharge_date IS NOT NULL;



	-- Age Out of Range Check
SELECT
      dob
FROM ERP_Master_Patient
WHERE 
    dob IS NOT NULL AND
    DATEDIFF(YEAR, dob, GETDATE()) NOT BETWEEN 0 AND 100;


-- Delete rows with invalid dob

DELETE FROM ERP_Master_Patient
WHERE 
    dob IS NOT NULL AND
    DATEDIFF(YEAR, dob, GETDATE()) NOT BETWEEN 0 AND 100;




====================================================================================================================================================
--Step 4: Adress 
--Columns: adress
====================================================================================================================================================

SELECT
    'NULL or Empty' AS IssueType,
    COUNT(*) AS IssueCount
FROM ERP_Master_Patient
WHERE address IS NULL OR address = ''



SELECT
    address
FROM ERP_Master_Patient
WHERE address IS NULL OR address = ''

-- Update NULL or empty addresses with 'n/a'
UPDATE ERP_Master_Patient
SET address = 'n/a'
WHERE address IS NULL OR address = '';


====================================================================================================================================================
--Step 5: City 
--Columns: city
====================================================================================================================================================

SELECT
    'NULL or Empty' AS IssueType,
    COUNT(*) AS IssueCount
FROM ERP_Master_Patient
WHERE city IS NULL OR city = ''
UNION ALL
SELECT
  city
FROM ERP_Master_Patient
WHERE city LIKE '%[^a-zA-Z ]%' -- Adjust the pattern as needed




-- Create a function to fix encoding issues in Quebec city names
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

-- For testing purposes, you can use this query to see the corrections before updating
SELECT 
    city AS Original,
    dbo.FixQuebecCityName(city) AS Corrected
FROM ERP_Master_Patient
WHERE city LIKE '%A?%' 
   OR city LIKE '%A©%'
   OR city LIKE '%Qu%villon%'
   OR city LIKE '%JonquiA?%'
   OR city LIKE '%MontrA?%'
   OR city LIKE '%CA?%dres%'
   OR city LIKE 'Saiot-%'
   OR city LIKE 'Saiat-%'
   OR city LIKE '%Dollacd-%'
ORDER BY city;

-- Once you've verified the corrections look good, run this update statement:

BEGIN TRANSACTION;

UPDATE ERP_Master_Patient
SET city = dbo.FixQuebecCityName(city)
WHERE city LIKE '%A?%' 
   OR city LIKE '%A©%'
   OR city LIKE '%Qu%villon%'
   OR city LIKE '%JonquiA?%'
   OR city LIKE '%MontrA?%'
   OR city LIKE '%CA?%dres%'
   OR city LIKE 'Saiot-%'
   OR city LIKE 'Saiat-%'
   OR city LIKE '%Dollacd-%';

-- Review the changes
SELECT 'Number of rows updated:', @@ROWCOUNT;

-- If the changes look good, commit the transaction
 --COMMIT TRANSACTION;

-- If something went wrong, you can roll back
-- ROLLBACK TRANSACTION;
*/





====================================================================================================================================================
--Step 6: State 
--Columns: state
====================================================================================================================================================


SELECT
     state 
FROM ERP_Master_Patient
WHERE  state  IS NULL OR  state  = ''

SELECT
   state 
FROM ERP_Master_Patient
WHERE  state  LIKE '%[^a-zA-Z ]%' -- Adjust the pattern as needed


-- Create a function to fix encoding issues in the state column
CREATE OR ALTER FUNCTION dbo.FixStateName(@state NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @fixedState NVARCHAR(255) = @state;

    -- Fix common encoding issues
    SET @fixedState = REPLACE(@fixedState, 'A?A©', 'é');
    SET @fixedState = REPLACE(@fixedState, 'A?A?', 'é');
    SET @fixedState = REPLACE(@fixedState, 'A©', 'é');
    SET @fixedState = REPLACE(@fixedState, 'QuA?A©bec', 'Québec');
    SET @fixedState = REPLACE(@fixedState, 'QuA©bec', 'Québec');
    SET @fixedState = REPLACE(@fixedState, 'QuA?A©bei', 'Québec');
    SET @fixedState = REPLACE(@fixedState, 'QuA?A©bic', 'Québec');
    SET @fixedState = REPLACE(@fixedState, 'QuA?A©yec', 'Québec');
    SET @fixedState = REPLACE(@fixedState, 'QoA?A©bec', 'Québec');
    SET @fixedState = REPLACE(@fixedState, 'QuA?dbec', 'Québec');
    SET @fixedState = REPLACE(@fixedState, 'QuA?rbec', 'Québec');

    RETURN @fixedState;
END;
GO

-- Test the function before applying updates
SELECT 
    state AS Original,
    dbo.FixStateName(state) AS Corrected
FROM ERP_Master_Patient
WHERE state LIKE '%A?%' OR state LIKE '%A©%' OR state LIKE '%QuA%';

-- Update the state column
BEGIN TRANSACTION;

UPDATE ERP_Master_Patient
SET state = dbo.FixStateName(state)
WHERE state LIKE '%A?%' OR state LIKE '%A©%' OR state LIKE '%QuA%';

-- Review the number of rows updated
SELECT 'Number of rows updated:', @@ROWCOUNT;

-- Commit the transaction if everything is correct
-- COMMIT TRANSACTION;

-- Rollback if something goes wrong
-- ROLLBACK TRANSACTION;





select * from ERP_Master_Patient




----------------------------------------------
select email from ERP_Master_Patient
where   email is null or   email = ' '


UPDATE ERP_Master_Patient
SET email = 'n/a'
WHERE email IS NULL OR email = '';

------------------------------------------

select insurance_provider from ERP_Master_Patient
where   insurance_provider is null or   insurance_provider = ' '

UPDATE ERP_Master_Patient
SET insurance_provider = 'n/a'
WHERE insurance_provider IS NULL OR insurance_provider = '';


------------------------------------------

select emergency_contact_name from ERP_Master_Patient
where    emergency_contact_name   is null or    emergency_contact_name   = ' '

UPDATE ERP_Master_Patient
SET insurance_provider = 'n/a'
WHERE insurance_provider IS NULL OR insurance_provider = '';




select * from ERP_Master_Patient


SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ERP_Master_Patient';

