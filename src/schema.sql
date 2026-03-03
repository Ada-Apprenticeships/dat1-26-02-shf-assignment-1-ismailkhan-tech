.open fittrackpro.db
.mode box



DROP TABLE IF EXISTS equipment_maintenance_log;
DROP TABLE IF EXISTS member_health_metrics;
DROP TABLE IF EXISTS personal_training_sessions;
DROP TABLE IF EXISTS class_attendance;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS memberships;
DROP TABLE IF EXISTS class_schedule;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS locations;
PRAGMA foreign_keys = ON;

--locations table

CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT NOT NULL,
    phone_number VARCHAR(20) 
        CHECK (LENGTH(phone_number) >=12), -- phone number must inlucde 12+ char so it can include country code and spacing (e.g. +44 07467 095899")
    email VARCHAR(100) UNIQUE 
        CHECK (email GLOB '*@*.*'),  --GLOB ensures email has @ symbol and domain and is also faster than LIKE for simple stuff
    opening_hours VARCHAR(20) 
        CHECK (opening_hours GLOB '[0-9][0-9]:[0-9][0-9]-[0-9][0-9]:[0-9][0-9]')
        --GLOB here makes sure the format is : HH:MM-HH:MM
        --[0-9] match any single digit
    
);

--Members TABLE
CREATE TABLE members (
    member_id INTEGER PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE 
        CHECK (email GLOB '*@*.*'), --same email validation
    phone_number VARCHAR(20) 
        CHECK (LENGTH(phone_number) >=10), -- members phone numbers could be shorter and not include country code
    date_of_birth DATE NOT NULL,
    join_date DATE NOT NULL DEFAULT (DATE('now')),
    emergency_contact_name VARCHAR(50) NOT NULL,
    emergency_contact_phone VARCHAR(15) NOT NULL
        CHECK (LENGTH(emergency_contact_phone) >= 10),
    CHECK (join_date > date_of_birth) -- logic check: person must be born before joining gym, on the table level

);

--staff

CREATE TABLE staff (
    staff_id INTEGER PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
        CHECK (email GLOB '*@*.*'), 
    phone_number VARCHAR(20) NOT NULL 
        CHECK (LENGTH(phone_number) >=12), -- staff phones may be required to have a country code
    position VARCHAR(20) NOT NULL 
        CHECK (position IN ('Trainer','Manager','Receptionist','Maintenance')), -- restricts to valid job roles only
    hire_date DATE NOT NULL, 
    location_id INTEGER,
    FOREIGN KEY (location_id)
        REFERENCES locations (location_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE

);

--equipment

CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('Cardio','Strength')),
    purchase_date DATE NOT NULL,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    location_id INTEGER,
    --Date Check Constraints
    CHECK (next_maintenance_date >= purchase_date),
    CHECK (next_maintenance_date > last_maintenance_date OR last_maintenance_date IS NULL),
    -- -- DId a Table-level CHECK because this compares multiple columns
    FOREIGN KEY (location_id)
        REFERENCES locations (location_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE

);


--class 
CREATE TABLE classes(
    class_id INTEGER PRIMARY KEY NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    capacity INTEGER NOT NULL
        CHECK (capacity > 0),
    duration INTEGER NOT NULL
        CHECK (duration > 0),
    location_id INTEGER,
    FOREIGN KEY (location_id)
        REFERENCES locations (location_id)
        ON DELETE SET NULL
    --If location closes, class definitions remain (it might be offered elsewhere)
    
);


--class schedule
CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY NOT NULL,
    class_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    CHECK(end_time > start_time),
    FOREIGN KEY (class_id)
        REFERENCES classes (class_id)
        ON DELETE CASCADE --If class type deleted, delete all scheduled sessions, no point keeping sessions for non existent class types
        ON UPDATE CASCADE,
    FOREIGN KEY(staff_id)
        REFERENCES staff(staff_id)
        ON DELETE RESTRICT -- prevents deleting staff who have scheduled classes, so they must re-assign or cancel classes before removing staff
        ON UPDATE CASCADE
);

--memberships

CREATE TABLE memberships(
    membership_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    membership_type VARCHAR(50) NOT NULL
         CHECK (membership_type IN ('Monthly', 'Annual', 'Day Pass', 'Student', 'Senior','Standard','Premium')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
        CHECK (end_date > start_date), --End date must be after start date
    status VARCHAR(20) NOT NULL DEFAULT 'Active' -- defualts to active when created
        CHECK (status IN ('Active', 'Inactive')),
    FOREIGN KEY(member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT


);

--ATTENDANCE

CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
        CHECK (check_out_time IS NULL OR check_out_time > check_in_time), -- check-out time must be after check-in time
    FOREIGN KEY (member_id)
        REFERENCES members (member_id)
        ON DELETE RESTRICT,-- cannot delete member with attendance history, as it may be important for audit trails or access logs
    FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
        ON DELETE RESTRICT -- cannot delete location with attendance records, historical data may need to be preserved for audits or reporting

);

--class attendance

CREATE TABLE class_attendance (
    class_attendance_id INTEGER PRIMARY KEY NOT NULL,
    schedule_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    attendance_status VARCHAR(20) NOT NULL
        CHECK (attendance_status IN ('Registered','Attended','Unattended')),
    FOREIGN KEY (schedule_id)
        REFERENCES class_schedule(schedule_id)
        ON DELETE CASCADE, --If class is cancelled, delete registrations, no point keeping registrations for cancelled lessons
    FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT, --Cannot delete member with class history
    UNIQUE (schedule_id, member_id)

);

--PAYMENTS

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
        CHECK (amount >= 0), 
    payment_date DATETIME NOT NULL,
    payment_method VARCHAR(30) NOT NULL
        CHECK (payment_method IN ('Credit Card','Bank Transfer','PayPal','Cash')),
    payment_type VARCHAR(100) NOT NULL, --Has no check because it might include various descriptions,  e.g, "Monthly membership fee", "Day pass", "Personal Training,Late Cancellation fee"
    FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT
        --Shouldnt delete member with payment history, incase for a audit trail or accounting resource

);

CREATE TABLE personal_training_sessions (
    session_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    notes VARCHAR(250), -- nullable because its not always needed
         CHECK (end_time > start_time),
    FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT, --To preserve session history when member leaves
    FOREIGN KEY(staff_id)
        REFERENCES staff(staff_id)
        ON DELETE NO ACTION --Prevents deleting trainer with sessions, this forces you to re-assign the session before deleting the trainer from the system

);

CREATE TABLE member_health_metrics (
    metric_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    measurement_date DATE NOT NULL,
    weight DECIMAL(5,2)
        CHECK ( weight > 0),
    body_fat_percentage DECIMAL(5,2) -- must be positive
        CHECK (body_fat_percentage BETWEEN 0 AND 100), -- Between allows it to be in the range of 0-100, so the percentage has to be in this range
    muscle_mass DECIMAL (5,2)
         CHECK (muscle_mass >= 0),
    bmi DECIMAL (4,2)
         CHECK (bmi > 0), -- must be positive
    FOREIGN KEY(member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT,
    UNIQUE (member_id, measurement_date) -- enforces that one set of measurement per member per day ( each member can only have one health record per day), this is used as it prevents duplicate entries for the same date

);

CREATE TABLE equipment_maintenance_log(
    log_id INTEGER PRIMARY KEY NOT NULL,
    equipment_id INTEGER NOT NULL,
    maintenance_date DATE NOT NULL,
    description VARCHAR(255), -- nullable, may be a routine check so may not need a description
    staff_id INTEGER, -- nullable as the mainternance might be from an external third party contractor
    FOREIGN KEY (equipment_id)
        REFERENCES equipment(equipment_id)
        ON DELETE CASCADE, -- if equipment is disposed of, delete its maintenance logs, no need to keep logs for equipment that dont exist
    FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL, --This preserves maintenance hsitory if staff leaves
    UNIQUE (equipment_id, maintenance_date) --One maintenance log per equipment per day, so ensures each piece of equipment can have one maintenance log per day (prevents duplicate logs for same the equipment on the same date)

);
