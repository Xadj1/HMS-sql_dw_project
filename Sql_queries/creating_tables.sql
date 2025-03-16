-- Patients Table
CREATE TABLE Patients (
    patient_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dob DATE,
    gender VARCHAR(50),
    address VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(50),
    phone_number VARCHAR(50),
    email VARCHAR(50),
    insurance_provider VARCHAR(50),
    insurance_policy_number VARCHAR(50),
    blood_type VARCHAR(3),
    allergies VARCHAR(50),
    medications VARCHAR(50),
    diagnosis VARCHAR(50),
    admission_date DATE,
    discharge_date DATE,
    emergency_contact_name VARCHAR(50),
    emergency_contact_phone VARCHAR(50),
    emergency_contact_relationship VARCHAR(50),
    insurance_expiration_date DATE,
    blood_pressure DECIMAL(5,2),
    heart_rate INT,
    weight INT,
    height INT,
    temperature DECIMAL(5,2)
);

-- Doctors Table
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty VARCHAR(100),
    phone_number VARCHAR(50),
    email VARCHAR(50)
);

-- Nurses Table
CREATE TABLE Nurses (
    nurse_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(50),
    email VARCHAR(50)
);

-- Billing Table
CREATE TABLE Billing (
    billing_id INT PRIMARY KEY IDENTITY(1,1),
    patient_id VARCHAR(50) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    total_amount DECIMAL(10,2),
    amount_paid DECIMAL(10,2),
    billing_date DATE,
    due_date DATE,
    payment_status VARCHAR(50),
    insurance_coverage DECIMAL(10,2)
);

-- Insurance Table
CREATE TABLE Insurance (
    insurance_id INT PRIMARY KEY IDENTITY(1,1),
    patient_id VARCHAR(50) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    insurance_provider VARCHAR(50),
    policy_number VARCHAR(50),
    coverage_start_date DATE,
    coverage_end_date DATE
);

-- Rooms Table
CREATE TABLE Rooms (
    room_number INT PRIMARY KEY,
    room_type VARCHAR(50),
    capacity INT,
    current_occupancy INT,
    is_available BIT DEFAULT 1 -- 1 for available, 0 for occupied
);

-- Treatment Table (Links Patients with Doctors and Nurses)
CREATE TABLE Treatment (
    treatment_id INT PRIMARY KEY IDENTITY(1,1),
    patient_id VARCHAR(50) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id INT REFERENCES Doctors(doctor_id) ON DELETE SET NULL,
    nurse_id INT REFERENCES Nurses(nurse_id) ON DELETE SET NULL,
    treatment_date DATE,
    diagnosis VARCHAR(255),
    medication VARCHAR(255)
);

-- Admissions Table (Links Patients with Rooms)
CREATE TABLE Admissions (
    admission_id INT PRIMARY KEY IDENTITY(1,1),
    patient_id VARCHAR(50) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    room_number INT REFERENCES Rooms(room_number) ON DELETE SET NULL,
    admission_date DATE,
    discharge_date DATE
);

