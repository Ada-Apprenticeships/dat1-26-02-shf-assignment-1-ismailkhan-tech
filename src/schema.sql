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
    location_id integer PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    address TEXT NOT NULL,
    phone_number TEXT
        CHECK(phone_number GLOB '[0-9]*'),
    email TEXT UNIQUE
        CHECK(email GLOB '*@.*'),
    opening _hours TEXT
        CHECK(opening_hours GLOB '[0-9][0-9]:[0-9][0-9]-[0-9][0-9]:[0-9][0-9]')
    
);

CREATE TABLE members (
    member_id INTEGER PRIMARY KEY
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone_number TEXT
        CHECK(phone_number GLOB '[0-9]*'),
    date_of_birth DATE,
    join_date DATE NOT NULL,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT
        CHECK (emergency_contact_phone GLOB '[0-9]*')
    
);

--staff

CREATE TABLE staff (
    staff_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone_number TEXT
        CHECK (phone_number GLOB '[0-9]*'),
    position TEXT NOT NULL
        CHECK (position IN ('Trainer','Manager','Receptionist','Maintenance'))
    hire_date DATE
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id)
        References locations (location_id)
        ON DELETE CASCADE

);

--equipment

CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('Cardio','Strength')),
    purchase_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
        ON DELETE CASCADE,
    UNIQUE (name, location_id)

);

--class schedule
CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY,
    class_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    FOREIGN KEY (class_id)
        REFERENCES classes(class_id)
        ON DELETE CASCADE,
    FOREIGN KEY(staff_id)
        REFERENCES staff(staff_id)
        ON DELETE CASCADE,
    CHECK (end_time > start_time)
);

--memberships

CREATE TABLE memberships(
    membership_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL
        CHECK(status IN('Active','Inactive')),
    FOREIGN KEY(member_id)
        REFERENCES members(member_id)
        ON DELETE RESTRICT,
    CHECK (end_date > start date),
    UNIQUE (member_id, start_date)

);

