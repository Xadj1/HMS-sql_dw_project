
---1. View for Patient Summary

CREATE VIEW v_PatientSummary AS
SELECT
    patient_id,
    first_name,
    last_name,
    dob,
    gender,
    phone_number,
    email,
    insurance_provider,
    insurance_policy_number,
    blood_type,
    allergies,
    medications,
    diagnosis,
    admission_date,
    discharge_date,
    emergency_contact_name,
    emergency_contact_phone,
    emergency_contact_relationship
FROM
    Patients;


	---Example Usage of the View
-------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Retrieve All Patient Summaries
SELECT * FROM v_PatientSummary;

-- 2. Retrieve Patient Summaries for a Specific Gender (e.g., 'Female')
SELECT *
FROM v_PatientSummary
WHERE gender = 'Female';

-- 3. Retrieve Patient Summaries for a Specific Blood Type (e.g., 'O+')
SELECT *
FROM v_PatientSummary
WHERE blood_type = 'O+';

-- 4. Retrieve Patients Admitted Within a Specific Date Range (e.g., January 2023)
SELECT *
FROM v_PatientSummary
WHERE admission_date BETWEEN '2023-01-01' AND '2023-01-31';

-- 5. Retrieve Patients with a Specific Diagnosis (e.g., 'Diabetes')
SELECT *
FROM v_PatientSummary
WHERE diagnosis = 'flu';

-- 6. Retrieve Patients with a Specific Insurance Provider (e.g., 'XYZ Insurance')
SELECT *
FROM v_PatientSummary
WHERE insurance_provider = 'Cigna';

-- 7. Retrieve Patients with No Discharge Date (Still Admitted)
SELECT *
FROM v_PatientSummary
WHERE discharge_date IS NULL;

-- 8. Retrieve Patients with a Specific Allergy (e.g., 'Penicillin')
SELECT *
FROM v_PatientSummary
WHERE allergies LIKE '%peanuts%';

-- 9. Retrieve Patients by Emergency Contact Relationship (e.g., 'Spouse')
SELECT *
FROM v_PatientSummary
WHERE emergency_contact_relationship = 'Spouse';

-- 10. Retrieve Patients Sorted by Admission Date (Oldest to Newest)
SELECT *
FROM v_PatientSummary
ORDER BY admission_date ASC;
-------------------------------------------------------------------------------------------------------------------------------------------


----2. View for Doctor Assignments

CREATE VIEW v_DoctorAssignments AS
SELECT
    d.doctor_id,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    d.specialty,
    COUNT(t.patient_id) AS patient_count
FROM
    Doctors d
    LEFT JOIN Treatment t ON d.doctor_id = t.doctor_id -- Link Doctors to Treatment
    LEFT JOIN Patients p ON t.patient_id = p.patient_id -- Link Treatment to Patients
GROUP BY
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialty;

---Example Usage of the View
-------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Retrieve All Doctor Assignments
SELECT * FROM v_DoctorAssignments;

-- 2. Retrieve Doctors with the Most Patients (Sorted by Patient Count)
SELECT *
FROM v_DoctorAssignments
ORDER BY patient_count DESC;

-- 3. Retrieve Doctors with No Patients Assigned
SELECT *
FROM v_DoctorAssignments
WHERE patient_count = 0;

-- 4. Retrieve Doctors in a Specific Specialty (e.g., 'Cardiology')
SELECT *
FROM v_DoctorAssignments
WHERE specialty = 'Cardiology';

-- 5. Retrieve Assignments for a Specific Doctor (e.g., doctor_id = 201)
SELECT *
FROM v_DoctorAssignments
WHERE doctor_id = 201;

-- 6. Count the Number of Doctors in Each Specialty
SELECT specialty, COUNT(*) AS doctor_count
FROM v_DoctorAssignments
GROUP BY specialty;

-- 7. Retrieve Doctors with a Specific Patient Count (e.g., at least 5 patients)
SELECT *
FROM v_DoctorAssignments
WHERE patient_count >= 5;

-- 8. Retrieve Doctors with the Fewest Patients (Sorted by Patient Count)
SELECT *
FROM v_DoctorAssignments
ORDER BY patient_count ASC;

-- 9. Retrieve Doctors and Their Patient Counts for a Specific Specialty (e.g., 'Pediatrics')
SELECT *
FROM v_DoctorAssignments
WHERE specialty = 'Neurology';

-- 10. Retrieve the Total Number of Patients Assigned to All Doctors
SELECT SUM(patient_count) AS total_patients_assigned
FROM v_DoctorAssignments;
-------------------------------------------------------------------------------------------------------------------------------------------


----3. View for Billing Summary

CREATE VIEW v_BillingSummary AS
SELECT
    b.billing_id,
    p.patient_id,
    p.first_name,
    p.last_name,
    b.total_amount,
    b.amount_paid,
    (b.total_amount - b.amount_paid) AS outstanding_balance,
    b.billing_date,
    b.due_date,
    b.payment_status,
    b.insurance_coverage
FROM
    Billing b
    JOIN Patients p ON b.patient_id = p.patient_id;



---Example Usage of the View
-------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Retrieve All Billing Summaries
SELECT * FROM v_BillingSummary;

-- 2. Filter by Payment Status (e.g., Unpaid)
SELECT *
FROM v_BillingSummary
WHERE payment_status = 'Overdue'; 
-- 3. Calculate Total Outstanding Balance
SELECT SUM(outstanding_balance) AS total_outstanding_balance
FROM v_BillingSummary;

-- 4. Find Patients with High Outstanding Balances (e.g., > $1000)
SELECT *
FROM v_BillingSummary
WHERE outstanding_balance > 1000; 

-- 5. Filter by Billing Date (e.g., January 2023)
SELECT *
FROM v_BillingSummary
WHERE billing_date BETWEEN '2023-01-01' AND '2023-01-31'; 

-- 6. Retrieve Billing Details for a Specific Patient (e.g., patient_id = 101)
SELECT *
FROM v_BillingSummary
WHERE patient_id = '1AY6NF1HW21'; 

-- 7. Find Bills Due Soon (e.g., within the next 7 days)
SELECT *
FROM v_BillingSummary
WHERE due_date BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE());

-- 8. Retrieve Bills with Partial Payments
SELECT *
FROM v_BillingSummary
WHERE payment_status = 'Partial';

-- 9. Sort Bills by Outstanding Balance (Highest to Lowest)
SELECT *
FROM v_BillingSummary
ORDER BY outstanding_balance DESC;

-- 10. Retrieve Bills with No Insurance Coverage
SELECT *
FROM v_BillingSummary
WHERE insurance_coverage = 0;

-------------------------------------------------------------------------------------------------------------------------------------------


-----4. View for Room Availability

CREATE VIEW v_RoomAvailability AS
SELECT
    room_number,
    room_type,
    capacity,
    current_occupancy,
    (capacity - current_occupancy) AS available_beds,
    CASE
        WHEN current_occupancy < capacity THEN 'Available'
        ELSE 'Occupied'
    END AS availability_status
FROM
    Rooms;

---Example Usage of the View
-------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Retrieve All Room Availability Information
SELECT * FROM v_RoomAvailability;

-- 2. Retrieve Available Rooms (Rooms with Available Beds)
SELECT *
FROM v_RoomAvailability
WHERE availability_status = 'Available';

-- 3. Retrieve Occupied Rooms (Rooms with No Available Beds)
SELECT *
FROM v_RoomAvailability
WHERE availability_status = 'Occupied';

-- 4. Retrieve Rooms with Specific Room Type (e.g., 'ICU')
SELECT *
FROM v_RoomAvailability
WHERE room_type = 'ICU';  

-- 5. Retrieve Rooms with High Availability (e.g., at least 3 available beds)
SELECT *
FROM v_RoomAvailability
WHERE available_beds >= 3;

-- 6. Retrieve Rooms with Specific Room Numbers (e.g., 201, 202, 203)
SELECT *
FROM v_RoomAvailability
WHERE room_number IN (201, 202, 203); 

-- 7. Count the Number of Available and Occupied Rooms
SELECT availability_status, COUNT(*) AS room_count
FROM v_RoomAvailability
GROUP BY availability_status;

-- 8. Retrieve Rooms with Full Capacity (No Available Beds)
SELECT *
FROM v_RoomAvailability
WHERE available_beds = 0;

-- 9. Sort Rooms by Available Beds (Highest to Lowest)
SELECT *
FROM v_RoomAvailability
ORDER BY available_beds DESC;

-- 10. Retrieve Rooms with Specific Capacity (e.g., capacity = 4)
SELECT *
FROM v_RoomAvailability
WHERE capacity = 4; 
-------------------------------------------------------------------------------------------------------------------------------------------



----5. View for Patient Room Allocation

CREATE VIEW v_PatientRoomAllocation AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    r.room_number,
    r.room_type,
    p.admission_date
FROM
    Patients p
    JOIN Rooms r ON p.patient_id = r.patient_id;



---Example Usage of the View
-------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Retrieve All Patient Room Allocations
SELECT * FROM v_PatientRoomAllocation;

-- 2. Retrieve Room Allocations for a Specific Patient (e.g., patient_id = 101)
SELECT *
FROM v_PatientRoomAllocation
WHERE patient_id = '1A27EF4HA57';

-- 3. Retrieve Patients in a Specific Room (e.g., room_number = 205)
SELECT *
FROM v_PatientRoomAllocation
WHERE room_number = 205; 

-- 4. Retrieve Patients Admitted on a Specific Date (e.g., '2023-10-01')
SELECT *
FROM v_PatientRoomAllocation
WHERE admission_date = '2023-10-01'; 

-- 5. Retrieve Patients in a Specific Room Type (e.g., 'ICU')
SELECT *
FROM v_PatientRoomAllocation
WHERE room_type = 'ICU';

-- 6. Retrieve Patients Admitted Within a Date Range (e.g., January 2023)
SELECT *
FROM v_PatientRoomAllocation
WHERE admission_date BETWEEN '2023-01-01' AND '2023-01-31'; 

-- 7. Retrieve Patients in Rooms with High Occupancy (e.g., room_type = 'General Ward')
SELECT *
FROM v_PatientRoomAllocation
WHERE room_type = 'General Ward';

-- 8. Sort Patients by Admission Date (Oldest to Newest)
SELECT *
FROM v_PatientRoomAllocation
ORDER BY admission_date ASC;

-- 9. Retrieve Patients in Rooms with Specific Room Numbers (e.g., 201, 202, 203)
SELECT *
FROM v_PatientRoomAllocation
WHERE room_number IN (201, 202, 203); 

-- 10. Count the Number of Patients in Each Room Type
SELECT room_type, COUNT(*) AS patient_count
FROM v_PatientRoomAllocation
GROUP BY room_type;


----6. View for Patient-Doctor Assignments

CREATE VIEW v_PatientDoctorAssignments AS
SELECT
    p.patient_id,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    d.doctor_id,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    d.specialty
FROM
    Patients p
    JOIN Treatment t ON p.patient_id = t.patient_id -- Link Patients to Treatment
    JOIN Doctors d ON t.doctor_id = d.doctor_id; -- Link Treatment to Doctors

---Example Usage of the View
-------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Retrieve All Patient-Doctor Assignments
SELECT * FROM v_PatientDoctorAssignments;

-- 2. Retrieve Assignments for a Specific Patient (e.g., patient_id = 101)
SELECT *
FROM v_PatientDoctorAssignments
WHERE patient_id = '1A27EF4HA57';

-- 3. Retrieve Assignments for a Specific Doctor (e.g., doctor_id = 201)
SELECT *
FROM v_PatientDoctorAssignments
WHERE doctor_id = 201;

-- 4. Retrieve Assignments for a Specific Specialty (e.g., 'Cardiology')
SELECT *
FROM v_PatientDoctorAssignments
WHERE specialty = 'Cardiology';

-- 5. Retrieve Patients Assigned to a Specific Doctor (e.g., doctor_id = 201)
SELECT patient_first_name, patient_last_name
FROM v_PatientDoctorAssignments
WHERE doctor_id = 201;

-- 6. Retrieve Doctors Assigned to a Specific Patient (e.g., patient_id = 101)
SELECT doctor_first_name, doctor_last_name, specialty
FROM v_PatientDoctorAssignments
WHERE patient_id = '1A27EF4HA57';

-- 7. Count the Number of Patients Assigned to Each Doctor
SELECT doctor_id, doctor_first_name, doctor_last_name, COUNT(patient_id) AS patient_count
FROM v_PatientDoctorAssignments
GROUP BY doctor_id, doctor_first_name, doctor_last_name;

-- 8. Retrieve Patients with Multiple Doctors (e.g., more than 1 doctor)
SELECT patient_id, patient_first_name, patient_last_name, COUNT(doctor_id) AS doctor_count
FROM v_PatientDoctorAssignments
GROUP BY patient_id, patient_first_name, patient_last_name
HAVING COUNT(doctor_id) > 1;

-- 9. Retrieve Assignments for Patients Admitted Within a Specific Date Range (e.g., January 2023)
SELECT *
FROM v_PatientDoctorAssignments
WHERE patient_id IN (
    SELECT patient_id
    FROM Patients
    WHERE admission_date BETWEEN '2023-01-01' AND '2023-01-31'
);

-- 10. Retrieve Assignments for Patients with a Specific Diagnosis (e.g., 'Diabetes')
SELECT *
FROM v_PatientDoctorAssignments
WHERE patient_id IN (
    SELECT patient_id
    FROM Patients
    WHERE diagnosis = 'Diabetes'
);
-------------------------------------------------------------------------------------------------------------------------------------------

