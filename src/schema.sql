.open fittrackpro.db
.mode box


PRAGMA foreign_keys = ON;
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

--locations table
CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT NOT NULL,
    phone_number VARCHAR(20) CHECK (LENGTH(phone_number) >=12),
    email VARCHAR(100) UNIQUE CHECK (email GLOB '*@*.*'), 
    opening _hours VARCHAR(20) CHECK (opening_hours GLOB '[0-9][0-9]:[0-9][0-9]-[0-9][0-9]:[0-9][0-9]')
    
);

CREATE TABLE members (
    member_id INTEGER PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE CHECK (email GLOB '*@*.*'),
    phone_number VARCHAR(20) 
    CHECK (LENGTH(phone_number) >=10),
    date_of_birth DATE NOT NULL
    CHECK (date_of_brirth , DATE('now')),
    join_date DATE NOT NULL DEFAULT (DATE('now'))
    CHECK(join_date <= DATE('now')),
    emergency_contact_name VARCHAR(50) NOT NULL,
    emergency_contact_phone VARCHAR(15) NOT NULL
    CHECK(LENGTH(emergency_contact_phone) >= 10),
    CHECK (join_date > date_of_birth)
    
);

--staff

CREATE TABLE staff (
    staff_id INTEGER PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
    CHECK (email GLOB '*@*.*'), 
    phone_number VARCHAR(20) NOT NULL 
    CHECK (LENGTH(phone_number) >=12),
    position VARCHAR(20) NOT NULL 
    CHECK IN ('Trainer','Manager','Receptionist','Maintenance'))
    hire_date DATE NOT NULL CHECK(hire_date <= DATE('now')),
    location_id INTEGER NOT NULL,
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
    purchase_date DATE NOT NULL 
        CHECK(purchase_date <= DATE('now')),
    last_maintenance_date DATE
        CHECK(last_maintenance_Date <= DATE('now')) 
        CHECK(next_maintenance_date >= purchase_date),
    next_maintenance_date DATE
         CHECK (next_maintenance_date > last_maintenance_date),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id)
        REFERENCES locations (location_id)
        ON DELETE SET NULL,
        ON UPDATE CASCADE,
    CHECK(last_maintenance_Date <= DATE('now'))

);


--class 
CREATE TABLE classes
    class_id INTEGER PRIMARY KEY NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    capacity INTEGER NOT NULL
        CHECK(capacity > 0),
    duration INTEGER NOT NULL
        CHECK (duration > 0),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id)
        REFERENCES locations (location_id)
        ON DELETE SET NULL
    
);


--class schedule
CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY NOT NULL,
    class_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    CHECK(end_time > start_time),
    FOREIGN KEY (class_id),
        REFERENCES classes(class_id),
        ON DELETE CASCADE,
        ON UPDATE CASCADE
    FOREIGN KEY(staff_id),
        REFERENCES staff(staff_id),
        ON DELETE CASCADE,
        ON UPDATE CASCADE,
);

--memberships

CREATE TABLE memberships(
    membership_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    membership_type VARCHAR(50) NOT NULL
         CHECK (membership_type IN ('Monthly', 'Annual', 'Day Pass', 'Student', 'Senior'))
    start_date DATE NOT NULL 
         CHECK(start_date <= DATE('now')),
    end_date DATE NOT NULL
        CHECK(end_date > start_date),
    status VARCHAR(20) NOT NULL DEFAULT 'Active' 
        CHECK (status IN ('Active', 'Inactive')),
    FOREIGN KEY(member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE,


);

--ATTENDANCE

CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
        CHECK (check_out_time IS NULL OR check_out_time > check_in_time)
    FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT,
    FOREIGN KEY(location_id)
        REFERENCES locations(location_id)
        ON DELETE RESTRICT,
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
        ON DELETE CASCADE,
    FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT,
    UNIQUE (schedule_id, member_id)

);

--PAYMENTS

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
        CHECK (amount >= 0),
    payment_datE DATETIME NOT NULL,
    payment_method VARCHAR(30) NOT NULL
        CHECK(payment_method IN ('Credit Card','Bank Transfer','Paypal')),
    payment_type VARCHAR(100) NOT NULL,
    FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE NO ACTION

);

CREATE TABLE personal_training_sessions (
    session_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    session_date DATE NOT NULL
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    notes VARCHAR(250),
    FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT
    FOREIGN KEY(staff_id)
        REFRENCES staff(staff_id)
        ON DELETE NO ACTION,
    CHECK (end_time . start_time)

);

CREATE TABLE member_health_metrics (
    metric_id INTEGER PRIMARY KEY NOT NULL,
    member_id INTEGER NOT NULL,
    measurement_date DATE NOT NULL,
    weight DECIMAL (5,2),
        CHECK (weight is NULL OR weight > 0),
    body_fat_percentage DECIMAL(5,2),
        CHECK (body_fat_percentage BETWEEN 0 AND 100),
    muscle_mass DECIMAL (5,2
         CHECK (muscle_mass >= 0),
    bmi DECIMAL (4,2)
         CHECK (bmi > 0),
    FOREIGN KEY(member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT,
    UNIQUE (members_id, measurement_date)

);

CREATE TABLE equipment_maintenance_log(
    log_id INTEGER PRIMARY KEY NOT NULL,
    equipment_id INTEGER NOT NULL,
    maintenance_date DATE NOT NULL,
    description VARCHAR(255),
    staff_id INTEGER,
    FOREIGN KEY (equipment_id)
        REFERENCES equipment(equipment_id)
        ON DELETE CASCADE,
    FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
    UNIQUE (equipment_id, maintenance_date)

);
