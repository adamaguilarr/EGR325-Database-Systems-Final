#CREATE DATABASE CBU_TutoringCenter;
#USE CBU_TutoringCenter;

CREATE TABLE Student (
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Major VARCHAR(100),
    Email VARCHAR(100) UNIQUE
);

CREATE TABLE Tutor (
    TutorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Rating DECIMAL(3,2)
);

CREATE TABLE Subject (
    SubjectID INT PRIMARY KEY AUTO_INCREMENT,
    SubjectName VARCHAR(100),
    Department VARCHAR(100)
);

CREATE TABLE TutorSubject (
    TutorID INT,
    SubjectID INT,
    PRIMARY KEY (TutorID, SubjectID),
    FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID),
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)
);

CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    TutorID INT,
    SubjectID INT,
    RoomID INT,
    AppointmentDate DATETIME,
    Status VARCHAR(20),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID),
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)
);

CREATE TABLE Availability (
    AvailabilityID INT PRIMARY KEY AUTO_INCREMENT,
    TutorID INT,
    DayOfWeek VARCHAR(10),
    StartTime TIME,
    EndTime TIME,
    IsAvailable BOOLEAN,
    FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID)
);

CREATE TABLE SessionFeedback (
    FeedbackID INT PRIMARY KEY AUTO_INCREMENT,
    AppointmentID INT,
    StudentRating INT CHECK (StudentRating BETWEEN 1 AND 5),
    Comments TEXT,
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

CREATE TABLE Room (
    RoomID INT PRIMARY KEY AUTO_INCREMENT,
    RoomName VARCHAR(50),
    Capacity INT
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Role VARCHAR(50),
    Email VARCHAR(100)
);
