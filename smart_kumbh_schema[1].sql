-- ============================================================
--  SMART KUMBH MANAGEMENT SYSTEM
--  UCS310 – Database Management Systems
--  Thapar Institute of Engineering and Technology
--  Group 2C13: Yashvardhan, Dhrity Bansal, Sarthak Kaushik
-- ============================================================

CREATE DATABASE IF NOT EXISTS smart_kumbh;
USE smart_kumbh;

-- ============================================================
-- SECTION 1: DDL – TABLE CREATION (3NF Normalized)
-- ============================================================

-- 1. Pilgrims (Central Entity)
CREATE TABLE Pilgrims (
    Pilgrim_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    Age             INT CHECK (Age > 0 AND Age < 150),
    Gender          ENUM('Male','Female','Other') NOT NULL,
    Contact_Number  VARCHAR(15) UNIQUE NOT NULL,
    Address         VARCHAR(255),
    Emergency_Contact_Name   VARCHAR(100),
    Emergency_Contact_Phone  VARCHAR(15),
    Registration_Date DATE DEFAULT (CURRENT_DATE)
);

-- 2. Hospitals
CREATE TABLE Hospitals (
    Hospital_ID     INT AUTO_INCREMENT PRIMARY KEY,
    Hospital_Name   VARCHAR(150) NOT NULL,
    Location        VARCHAR(255) NOT NULL,
    Contact_Number  VARCHAR(15),
    Total_Beds      INT NOT NULL CHECK (Total_Beds >= 0),
    Available_Beds  INT NOT NULL CHECK (Available_Beds >= 0),
    CONSTRAINT chk_beds CHECK (Available_Beds <= Total_Beds)
);

-- 3. Doctors
CREATE TABLE Doctors (
    Doctor_ID       INT AUTO_INCREMENT PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    Specialization  VARCHAR(100) NOT NULL,
    Contact_Number  VARCHAR(15),
    Hospital_ID     INT NOT NULL,
    FOREIGN KEY (Hospital_ID) REFERENCES Hospitals(Hospital_ID) ON DELETE CASCADE
);

-- 4. Police Stations
CREATE TABLE Police_Stations (
    Station_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Station_Name    VARCHAR(150) NOT NULL,
    Location        VARCHAR(255) NOT NULL,
    Contact_Number  VARCHAR(15)
);

-- 5. Police Officers
CREATE TABLE Police_Officers (
    Officer_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    Badge_Number    VARCHAR(30) UNIQUE NOT NULL,
    Rank            VARCHAR(50),
    Station_ID      INT NOT NULL,
    FOREIGN KEY (Station_ID) REFERENCES Police_Stations(Station_ID) ON DELETE CASCADE
);

-- 6. Manager (assigned to Police Station)
CREATE TABLE Manager (
    Manager_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    Contact_Number  VARCHAR(15),
    Station_ID      INT UNIQUE,
    FOREIGN KEY (Station_ID) REFERENCES Police_Stations(Station_ID) ON DELETE SET NULL
);

-- 7. Fire Stations
CREATE TABLE Fire_Stations (
    Fire_Station_ID INT AUTO_INCREMENT PRIMARY KEY,
    Station_Name    VARCHAR(150) NOT NULL,
    Location        VARCHAR(255) NOT NULL,
    Contact_Number  VARCHAR(15),
    Total_Units     INT DEFAULT 0
);

-- 8. Ghats
CREATE TABLE Ghats (
    Ghat_ID         INT AUTO_INCREMENT PRIMARY KEY,
    Ghat_Name       VARCHAR(100) NOT NULL,
    Location        VARCHAR(255) NOT NULL,
    Capacity        INT CHECK (Capacity > 0),
    Nearest_Hospital_ID INT,
    FOREIGN KEY (Nearest_Hospital_ID) REFERENCES Hospitals(Hospital_ID) ON DELETE SET NULL
);

-- 9. Accommodation (Tents)
CREATE TABLE Accommodation (
    Tent_ID         INT AUTO_INCREMENT PRIMARY KEY,
    Tent_Name       VARCHAR(100) NOT NULL,
    Location        VARCHAR(255) NOT NULL,
    Total_Capacity  INT NOT NULL CHECK (Total_Capacity > 0),
    Available_Beds  INT NOT NULL CHECK (Available_Beds >= 0),
    CONSTRAINT chk_tent_beds CHECK (Available_Beds <= Total_Capacity)
);

-- 10. Vendors
CREATE TABLE Vendors (
    Vendor_ID       INT AUTO_INCREMENT PRIMARY KEY,
    Vendor_Name     VARCHAR(150) NOT NULL,
    Shop_Type       VARCHAR(100),
    Location        VARCHAR(255),
    Contact_Number  VARCHAR(15),
    License_Number  VARCHAR(50) UNIQUE
);

-- 11. Transportation
CREATE TABLE Transportation (
    Transport_ID    INT AUTO_INCREMENT PRIMARY KEY,
    Vehicle_Type    VARCHAR(80) NOT NULL,
    Route           VARCHAR(255) NOT NULL,
    Capacity        INT CHECK (Capacity > 0),
    Contact_Number  VARCHAR(15),
    Available       BOOLEAN DEFAULT TRUE
);

-- 12. Incident_Reports
CREATE TABLE Incident_Reports (
    Incident_ID     INT AUTO_INCREMENT PRIMARY KEY,
    Description     TEXT NOT NULL,
    Priority        ENUM('High','Medium','Low') NOT NULL,
    Status          ENUM('Open','In Progress','Resolved') DEFAULT 'Open',
    Reported_Date   DATETIME DEFAULT CURRENT_TIMESTAMP,
    Location        VARCHAR(255),
    Station_ID      INT,
    Fire_Station_ID INT,
    FOREIGN KEY (Station_ID) REFERENCES Police_Stations(Station_ID) ON DELETE SET NULL,
    FOREIGN KEY (Fire_Station_ID) REFERENCES Fire_Stations(Fire_Station_ID) ON DELETE SET NULL
);

-- 13. Lost_And_Found
CREATE TABLE Lost_And_Found (
    Item_ID         INT AUTO_INCREMENT PRIMARY KEY,
    Item_Description VARCHAR(255) NOT NULL,
    Status          ENUM('Lost','Found','Returned') DEFAULT 'Lost',
    Reported_Date   DATE DEFAULT (CURRENT_DATE),
    Location_Found  VARCHAR(255),
    Pilgrim_ID      INT,
    FOREIGN KEY (Pilgrim_ID) REFERENCES Pilgrims(Pilgrim_ID) ON DELETE SET NULL
);

-- ============================================================
-- JUNCTION / RELATIONSHIP TABLES (Many-to-Many)
-- ============================================================

-- Pilgrims ↔ Accommodation
CREATE TABLE Pilgrim_Accommodation (
    Booking_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Pilgrim_ID      INT NOT NULL,
    Tent_ID         INT NOT NULL,
    Check_In_Date   DATE NOT NULL,
    Check_Out_Date  DATE,
    FOREIGN KEY (Pilgrim_ID) REFERENCES Pilgrims(Pilgrim_ID) ON DELETE CASCADE,
    FOREIGN KEY (Tent_ID)    REFERENCES Accommodation(Tent_ID) ON DELETE CASCADE
);

-- Pilgrims ↔ Transportation
CREATE TABLE Pilgrim_Transportation (
    PT_ID           INT AUTO_INCREMENT PRIMARY KEY,
    Pilgrim_ID      INT NOT NULL,
    Transport_ID    INT NOT NULL,
    Booking_Date    DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (Pilgrim_ID)   REFERENCES Pilgrims(Pilgrim_ID) ON DELETE CASCADE,
    FOREIGN KEY (Transport_ID) REFERENCES Transportation(Transport_ID) ON DELETE CASCADE
);

-- Pilgrims ↔ Incident_Reports
CREATE TABLE Pilgrim_Incidents (
    PI_ID           INT AUTO_INCREMENT PRIMARY KEY,
    Pilgrim_ID      INT NOT NULL,
    Incident_ID     INT NOT NULL,
    FOREIGN KEY (Pilgrim_ID)  REFERENCES Pilgrims(Pilgrim_ID) ON DELETE CASCADE,
    FOREIGN KEY (Incident_ID) REFERENCES Incident_Reports(Incident_ID) ON DELETE CASCADE
);

-- Pilgrims ↔ Treatments (via Hospital)
CREATE TABLE Pilgrim_Treatments (
    Treatment_ID    INT AUTO_INCREMENT PRIMARY KEY,
    Pilgrim_ID      INT NOT NULL,
    Doctor_ID       INT NOT NULL,
    Hospital_ID     INT NOT NULL,
    Diagnosis       VARCHAR(255),
    Treatment_Date  DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (Pilgrim_ID)  REFERENCES Pilgrims(Pilgrim_ID) ON DELETE CASCADE,
    FOREIGN KEY (Doctor_ID)   REFERENCES Doctors(Doctor_ID) ON DELETE CASCADE,
    FOREIGN KEY (Hospital_ID) REFERENCES Hospitals(Hospital_ID) ON DELETE CASCADE
);

-- Pilgrims ↔ Vendors (Purchases)
CREATE TABLE Pilgrim_Purchases (
    Purchase_ID     INT AUTO_INCREMENT PRIMARY KEY,
    Pilgrim_ID      INT NOT NULL,
    Vendor_ID       INT NOT NULL,
    Item_Name       VARCHAR(150),
    Amount          DECIMAL(10,2) CHECK (Amount >= 0),
    Purchase_Date   DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (Pilgrim_ID) REFERENCES Pilgrims(Pilgrim_ID) ON DELETE CASCADE,
    FOREIGN KEY (Vendor_ID)  REFERENCES Vendors(Vendor_ID) ON DELETE CASCADE
);

-- ============================================================
-- SECTION 2: TRIGGERS (Automation)
-- ============================================================

DELIMITER //

-- TRIGGER 1: Auto-decrease Accommodation beds on check-in
CREATE TRIGGER trg_checkin_decrease_beds
AFTER INSERT ON Pilgrim_Accommodation
FOR EACH ROW
BEGIN
    UPDATE Accommodation
    SET Available_Beds = Available_Beds - 1
    WHERE Tent_ID = NEW.Tent_ID
      AND Available_Beds > 0;
END //

-- TRIGGER 2: Auto-restore Accommodation beds on check-out
CREATE TRIGGER trg_checkout_restore_beds
AFTER UPDATE ON Pilgrim_Accommodation
FOR EACH ROW
BEGIN
    IF NEW.Check_Out_Date IS NOT NULL AND OLD.Check_Out_Date IS NULL THEN
        UPDATE Accommodation
        SET Available_Beds = Available_Beds + 1
        WHERE Tent_ID = NEW.Tent_ID;
    END IF;
END //

-- TRIGGER 3: Auto-decrease Hospital beds on new treatment
CREATE TRIGGER trg_treatment_decrease_hospital_beds
AFTER INSERT ON Pilgrim_Treatments
FOR EACH ROW
BEGIN
    UPDATE Hospitals
    SET Available_Beds = Available_Beds - 1
    WHERE Hospital_ID = NEW.Hospital_ID
      AND Available_Beds > 0;
END //

-- TRIGGER 4: Prevent overbooking accommodation
CREATE TRIGGER trg_prevent_overbooking
BEFORE INSERT ON Pilgrim_Accommodation
FOR EACH ROW
BEGIN
    DECLARE beds_left INT;
    SELECT Available_Beds INTO beds_left
    FROM Accommodation WHERE Tent_ID = NEW.Tent_ID;
    IF beds_left <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No beds available in this tent.';
    END IF;
END //

DELIMITER ;

-- ============================================================
-- SECTION 3: STORED PROCEDURES
-- ============================================================

DELIMITER //

-- PROCEDURE 1: Register a new pilgrim
CREATE PROCEDURE sp_register_pilgrim(
    IN p_name VARCHAR(100),
    IN p_age INT,
    IN p_gender ENUM('Male','Female','Other'),
    IN p_contact VARCHAR(15),
    IN p_address VARCHAR(255),
    IN p_ec_name VARCHAR(100),
    IN p_ec_phone VARCHAR(15)
)
BEGIN
    INSERT INTO Pilgrims(Name, Age, Gender, Contact_Number, Address,
                         Emergency_Contact_Name, Emergency_Contact_Phone)
    VALUES (p_name, p_age, p_gender, p_contact, p_address, p_ec_name, p_ec_phone);
    SELECT LAST_INSERT_ID() AS New_Pilgrim_ID;
END //

-- PROCEDURE 2: Book accommodation with transaction safety
CREATE PROCEDURE sp_book_accommodation(
    IN p_pilgrim_id INT,
    IN p_tent_id INT,
    IN p_checkin DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Booking failed – rolled back.' AS Result;
    END;

    START TRANSACTION;
        INSERT INTO Pilgrim_Accommodation(Pilgrim_ID, Tent_ID, Check_In_Date)
        VALUES (p_pilgrim_id, p_tent_id, p_checkin);
    COMMIT;
    SELECT 'Accommodation booked successfully.' AS Result;
END //

-- PROCEDURE 3: Report an incident
CREATE PROCEDURE sp_report_incident(
    IN p_desc TEXT,
    IN p_priority ENUM('High','Medium','Low'),
    IN p_location VARCHAR(255),
    IN p_station_id INT
)
BEGIN
    INSERT INTO Incident_Reports(Description, Priority, Location, Station_ID)
    VALUES (p_desc, p_priority, p_location, p_station_id);
    SELECT LAST_INSERT_ID() AS New_Incident_ID;
END //

-- PROCEDURE 4: Get all open High-priority incidents
CREATE PROCEDURE sp_get_high_priority_incidents()
BEGIN
    SELECT i.Incident_ID, i.Description, i.Location, i.Reported_Date,
           ps.Station_Name
    FROM Incident_Reports i
    LEFT JOIN Police_Stations ps ON i.Station_ID = ps.Station_ID
    WHERE i.Priority = 'High' AND i.Status != 'Resolved'
    ORDER BY i.Reported_Date ASC;
END //

DELIMITER ;

-- ============================================================
-- SECTION 4: FUNCTIONS
-- ============================================================

DELIMITER //

-- FUNCTION 1: Get available beds in a tent
CREATE FUNCTION fn_get_tent_availability(p_tent_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE beds INT;
    SELECT Available_Beds INTO beds
    FROM Accommodation WHERE Tent_ID = p_tent_id;
    RETURN IFNULL(beds, -1);
END //

-- FUNCTION 2: Count total incidents for a pilgrim
CREATE FUNCTION fn_count_pilgrim_incidents(p_pilgrim_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Pilgrim_Incidents WHERE Pilgrim_ID = p_pilgrim_id;
    RETURN total;
END //

DELIMITER ;

-- ============================================================
-- SECTION 5: VIEWS
-- ============================================================

-- View 1: Pilgrim full profile with accommodation
CREATE VIEW vw_pilgrim_accommodation AS
SELECT p.Pilgrim_ID, p.Name, p.Contact_Number,
       a.Tent_Name, a.Location AS Tent_Location,
       pa.Check_In_Date, pa.Check_Out_Date
FROM Pilgrims p
JOIN Pilgrim_Accommodation pa ON p.Pilgrim_ID = pa.Pilgrim_ID
JOIN Accommodation a ON pa.Tent_ID = a.Tent_ID;

-- View 2: Doctors with their hospital
CREATE VIEW vw_doctor_hospital AS
SELECT d.Doctor_ID, d.Name AS Doctor_Name, d.Specialization,
       h.Hospital_Name, h.Location AS Hospital_Location
FROM Doctors d
JOIN Hospitals h ON d.Hospital_ID = h.Hospital_ID;

-- View 3: Incident summary with police station
CREATE VIEW vw_incident_summary AS
SELECT i.Incident_ID, i.Description, i.Priority, i.Status,
       i.Location, i.Reported_Date,
       ps.Station_Name
FROM Incident_Reports i
LEFT JOIN Police_Stations ps ON i.Station_ID = ps.Station_ID
ORDER BY FIELD(i.Priority,'High','Medium','Low'), i.Reported_Date;

-- View 4: Hospital bed availability
CREATE VIEW vw_hospital_beds AS
SELECT Hospital_ID, Hospital_Name, Location,
       Total_Beds, Available_Beds,
       (Total_Beds - Available_Beds) AS Occupied_Beds
FROM Hospitals;

-- ============================================================
-- SECTION 6: CURSORS & EXCEPTION HANDLING (Stored Procedure)
-- ============================================================

DELIMITER //

-- Uses a cursor to print all unresolved incidents to an audit log table
CREATE TABLE IF NOT EXISTS Incident_Audit_Log (
    Log_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Incident_ID INT,
    Description TEXT,
    Priority    VARCHAR(20),
    Logged_At   DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE PROCEDURE sp_audit_open_incidents()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_desc TEXT;
    DECLARE v_priority VARCHAR(20);

    DECLARE incident_cursor CURSOR FOR
        SELECT Incident_ID, Description, Priority
        FROM Incident_Reports
        WHERE Status != 'Resolved';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN incident_cursor;
    audit_loop: LOOP
        FETCH incident_cursor INTO v_id, v_desc, v_priority;
        IF done THEN LEAVE audit_loop; END IF;
        INSERT INTO Incident_Audit_Log(Incident_ID, Description, Priority)
        VALUES (v_id, v_desc, v_priority);
    END LOOP;
    CLOSE incident_cursor;

    SELECT CONCAT('Audit complete. Logged ', ROW_COUNT(), ' incidents.') AS Result;
END //

DELIMITER ;

-- ============================================================
-- SECTION 7: TRANSACTION MANAGEMENT EXAMPLE
-- ============================================================

-- Full accommodation booking transaction (ACID demonstration)
-- START TRANSACTION;
--   INSERT INTO Pilgrim_Accommodation(Pilgrim_ID, Tent_ID, Check_In_Date)
--   VALUES (1, 2, '2026-02-15');
--   -- If error occurs:
--   -- ROLLBACK;
-- COMMIT;

-- ============================================================
-- SECTION 8: SAMPLE DML – INSERT DATA
-- ============================================================

INSERT INTO Hospitals(Hospital_Name, Location, Contact_Number, Total_Beds, Available_Beds)
VALUES
  ('Kumbh Central Hospital', 'Sector 1, Prayagraj', '0532-100001', 500, 480),
  ('Mela Medical Camp', 'Sector 3, Triveni', '0532-100002', 200, 195);

INSERT INTO Police_Stations(Station_Name, Location, Contact_Number)
VALUES
  ('Kumbh Main Control', 'Sector 2', '100'),
  ('Triveni Outpost', 'Triveni Ghat', '0532-200002');

INSERT INTO Fire_Stations(Station_Name, Location, Contact_Number, Total_Units)
VALUES
  ('Kumbh Fire HQ', 'Near Sector 4', '101', 10);

INSERT INTO Ghats(Ghat_Name, Location, Capacity, Nearest_Hospital_ID)
VALUES
  ('Triveni Ghat', 'Sangam Area', 100000, 1),
  ('Dashashwamedh Ghat', 'Varanasi Rd', 50000, 2);

INSERT INTO Accommodation(Tent_Name, Location, Total_Capacity, Available_Beds)
VALUES
  ('Camp Alpha', 'Zone A', 200, 200),
  ('Camp Beta', 'Zone B', 150, 150);

INSERT INTO Vendors(Vendor_Name, Shop_Type, Location, Contact_Number, License_Number)
VALUES
  ('Puja Samagri Store', 'Religious items', 'Zone C', '9999988881', 'LIC001'),
  ('Annadata Bhandara', 'Food stall', 'Zone A', '9999988882', 'LIC002');

INSERT INTO Transportation(Vehicle_Type, Route, Capacity, Contact_Number)
VALUES
  ('Bus', 'Prayagraj Station → Sangam', 60, '0532-300001'),
  ('E-Rickshaw', 'Sector 1 → Ghat', 6, '0532-300002');

INSERT INTO Pilgrims(Name, Age, Gender, Contact_Number, Address,
                     Emergency_Contact_Name, Emergency_Contact_Phone)
VALUES
  ('Ramesh Kumar', 45, 'Male',   '9876543210', 'Delhi', 'Suresh Kumar', '9876543211'),
  ('Sunita Devi',  38, 'Female', '9876543220', 'Lucknow', 'Manoj Devi', '9876543221'),
  ('Arjun Singh',  22, 'Male',   '9876543230', 'Jaipur', 'Kiran Singh', '9876543231');

INSERT INTO Doctors(Name, Specialization, Contact_Number, Hospital_ID)
VALUES
  ('Dr. Anil Sharma', 'General Physician', '9111000001', 1),
  ('Dr. Priya Gupta', 'Emergency Medicine', '9111000002', 1),
  ('Dr. Ravi Verma',  'Orthopedics',        '9111000003', 2);

INSERT INTO Police_Officers(Name, Badge_Number, Rank, Station_ID)
VALUES
  ('SI Mohit Yadav',   'UP1001', 'Sub-Inspector', 1),
  ('Const. Deepak Pal','UP1002', 'Constable',     1);

-- ============================================================
-- SECTION 9: SELECT QUERIES (as required by guidelines)
-- ============================================================

-- 1. JOIN: Pilgrims with their accommodation
SELECT p.Name, a.Tent_Name, pa.Check_In_Date
FROM Pilgrims p
JOIN Pilgrim_Accommodation pa ON p.Pilgrim_ID = pa.Pilgrim_ID
JOIN Accommodation a ON pa.Tent_ID = a.Tent_ID;

-- 2. SUBQUERY: Pilgrims who have been treated
SELECT Name FROM Pilgrims
WHERE Pilgrim_ID IN (SELECT DISTINCT Pilgrim_ID FROM Pilgrim_Treatments);

-- 3. AGGREGATE: Count of incidents by priority
SELECT Priority, COUNT(*) AS Total
FROM Incident_Reports
GROUP BY Priority
HAVING COUNT(*) > 0;

-- 4. GROUP BY + HAVING: Hospitals with more than 10 occupied beds
SELECT Hospital_Name, (Total_Beds - Available_Beds) AS Occupied
FROM Hospitals
GROUP BY Hospital_ID, Hospital_Name, Total_Beds, Available_Beds
HAVING Occupied > 10;

-- 5. Doctors per hospital
SELECT h.Hospital_Name, COUNT(d.Doctor_ID) AS Doctor_Count
FROM Hospitals h
LEFT JOIN Doctors d ON h.Hospital_ID = d.Hospital_ID
GROUP BY h.Hospital_ID, h.Hospital_Name;

-- ============================================================
-- END OF SMART KUMBH MANAGEMENT SCHEMA
-- ============================================================
