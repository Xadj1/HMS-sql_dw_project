
=====================================================================================================================================================================
---window functions to calculate the average length of stay for patients
=====================================================================================================================================================================

SELECT
    patient_id,
    first_name,
    last_name,
    admission_date,
    discharge_date,
    DATEDIFF(day, admission_date, COALESCE(discharge_date, GETDATE())) AS length_of_stay,
    AVG(DATEDIFF(day, admission_date, COALESCE(discharge_date, GETDATE()))) OVER () AS avg_length_of_stay
FROM
    Patients
WHERE
    discharge_date IS NOT NULL; -- Exclude patients still admitted


-- Include patients still admitted

	SELECT
    patient_id,
    first_name,
    last_name,
    admission_date,
    discharge_date,
    DATEDIFF(day, admission_date, COALESCE(discharge_date, GETDATE())) AS length_of_stay,
    AVG(DATEDIFF(day, admission_date, COALESCE(discharge_date, GETDATE()))) OVER () AS avg_length_of_stay
FROM
    Patients;

=====================================================================================================================================================================
----Trigger that logs updates made to patient records into an audit table to track changes.
=====================================================================================================================================================================

CREATE TABLE PatientAuditLog (
    audit_id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
    patient_id INT NOT NULL, -- ID of the patient
    changed_by NVARCHAR(128) NOT NULL, -- User who made the change
    change_date DATETIME NOT NULL DEFAULT GETDATE(), -- Timestamp of the change
    old_data NVARCHAR(MAX), -- Old data (before update)
    new_data NVARCHAR(MAX) -- New data (after update)
);


CREATE TRIGGER trg_PatientUpdateAudit
ON Patients
AFTER UPDATE
AS
BEGIN
    -- Insert the old and new data into the audit table
    INSERT INTO PatientAuditLog (patient_id, changed_by, change_date, old_data, new_data)
    SELECT
        i.patient_id, -- Patient ID from the inserted table (new data)
        SYSTEM_USER, -- Current user making the change
        GETDATE(), -- Current date and time
        (SELECT * FROM deleted FOR JSON AUTO), -- Old data (before update)
        (SELECT * FROM inserted FOR JSON AUTO) -- New data (after update)
    FROM
        inserted i
    INNER JOIN
        deleted d ON i.patient_id = d.patient_id; -- Join inserted and deleted tables
END;


---example usage 

--UPDATE Patients
--SET first_name = 'Johnny', last_name = 'Smith'
--WHERE patient_id = '1A27EF4HA57';

SELECT * FROM PatientAuditLog;

=====================================================================================================================================================================
------Recursive CTE to Explore Family Relationships
=====================================================================================================================================================================

WITH FamilyTree AS (
    -- Anchor member: Start with the specified patient
    SELECT
        patient_id,
        first_name,
        last_name,
        phone_number,
        emergency_contact_phone,
        emergency_contact_relationship,
        1 AS level -- Level of the hierarchy (starting at 1)
    FROM
        Patients
    WHERE
        patient_id = '1A85MW4XX91' 

    UNION ALL

    -- Recursive member: Traverse the hierarchy
    SELECT
        p.patient_id,
        p.first_name,
        p.last_name,
        p.phone_number,
        p.emergency_contact_phone,
        p.emergency_contact_relationship,
        ft.level + 1 AS level -- Increment the level
    FROM
        Patients p
    INNER JOIN
        FamilyTree ft ON p.emergency_contact_phone = ft.phone_number
)
SELECT
    patient_id,
    first_name,
    last_name,
    phone_number,
    emergency_contact_phone,
    emergency_contact_relationship,
    level
FROM
    FamilyTree;





