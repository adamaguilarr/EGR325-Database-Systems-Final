-- Create and select database
CREATE DATABASE IF NOT EXISTS CBU_TutoringCenter;
USE CBU_TutoringCenter;

-- =========================
-- Base tables
-- =========================

CREATE TABLE IF NOT EXISTS Student (
    StudentID   INT PRIMARY KEY AUTO_INCREMENT,
    FirstName   VARCHAR(50),
    LastName    VARCHAR(50),
    Major       VARCHAR(100),
    Email       VARCHAR(100) UNIQUE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Tutor (
    TutorID     INT PRIMARY KEY AUTO_INCREMENT,
    FirstName   VARCHAR(50),
    LastName    VARCHAR(50),
    Department  VARCHAR(100),
    Email       VARCHAR(100) UNIQUE,
    Rating      DECIMAL(3,2)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Subject (
    SubjectID   INT PRIMARY KEY AUTO_INCREMENT,
    SubjectName VARCHAR(100),
    Department  VARCHAR(100)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Room (
    RoomID      INT PRIMARY KEY AUTO_INCREMENT,
    RoomName    VARCHAR(50),
    Capacity    INT
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Staff (
    StaffID     INT PRIMARY KEY AUTO_INCREMENT,
    FirstName   VARCHAR(50),
    LastName    VARCHAR(50),
    Role        VARCHAR(50),
    Email       VARCHAR(100)
) ENGINE = InnoDB;

-- =========================
-- Relationship tables
-- =========================

-- Many to many Tutor <-> Subject
CREATE TABLE IF NOT EXISTS TutorSubject (
    TutorID   INT,
    SubjectID INT,
    PRIMARY KEY (TutorID, SubjectID),
    CONSTRAINT fk_tutorsubject_tutor
        FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID),
    CONSTRAINT fk_tutorsubject_subject
        FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)
) ENGINE = InnoDB;

-- Appointments between student and tutor, in a room, for a subject
CREATE TABLE IF NOT EXISTS Appointment (
    AppointmentID   INT PRIMARY KEY AUTO_INCREMENT,
    StudentID       INT,
    TutorID         INT,
    SubjectID       INT,
    RoomID          INT,
    AppointmentDate DATETIME,
    Status          VARCHAR(20),
    CONSTRAINT fk_appointment_student
        FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT fk_appointment_tutor
        FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID),
    CONSTRAINT fk_appointment_subject
        FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID),
    CONSTRAINT fk_appointment_room
        FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
) ENGINE = InnoDB;

-- Tutor weekly availability
CREATE TABLE IF NOT EXISTS Availability (
    AvailabilityID INT PRIMARY KEY AUTO_INCREMENT,
    TutorID        INT,
    DayOfWeek      VARCHAR(10),
    StartTime      TIME,
    EndTime        TIME,
    IsAvailable    BOOLEAN,
    CONSTRAINT fk_availability_tutor
        FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID)
) ENGINE = InnoDB;

-- Feedback on sessions
CREATE TABLE IF NOT EXISTS SessionFeedback (
    FeedbackID     INT PRIMARY KEY AUTO_INCREMENT,
    AppointmentID  INT,
    StudentRating  INT CHECK (StudentRating BETWEEN 1 AND 5),
    Comments       TEXT,
    CONSTRAINT fk_feedback_appointment
        FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
) ENGINE = InnoDB;
