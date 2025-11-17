-- =====================================================================
-- User Story #2: Admin Adds a New Tutor
-- Persona: Admin User
-- Goal: Add a new tutor profile, assign subjects, and set initial
--       availability while enforcing the 10-hour-per-week rule and
--       preventing overlapping availability slots.
-- =====================================================================

SET @MaxHoursPerWeek := 10;

-- 1. INSERT NEW TUTOR PROFILE
INSERT INTO Tutor (FirstName, LastName, Department, Email, Rating)
VALUES ('Sarah', 'Ramirez', 'Mathematics', 'sarah.ramirez@calbaptist.edu', 0.00);

SET @TutorID := LAST_INSERT_ID();

-- 2. ASSIGN SUBJECTS TO TUTOR (example: Algebra = 1, Calculus = 2)
INSERT INTO TutorSubject (TutorID, SubjectID)
VALUES
    (@TutorID, 1),  -- Algebra
    (@TutorID, 2);  -- Calculus


-- 3. DEFINE INITIAL AVAILABILITY SLOTS IN TEMP TABLE
DROP TEMPORARY TABLE IF EXISTS TempNewSlots;

CREATE TEMPORARY TABLE TempNewSlots (
    DayOfWeek ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    StartTime TIME,
    EndTime   TIME
);

-- Example: 6 total hours
INSERT INTO TempNewSlots (DayOfWeek, StartTime, EndTime) VALUES
    ('Monday',    '09:00:00', '11:00:00'),
    ('Wednesday', '10:00:00', '12:00:00'),
    ('Friday',    '14:00:00', '16:00:00');


-- 4. CREATE REAL TABLE COPY FOR SELF-JOIN (OVERLAP CHECK)
DROP TABLE IF EXISTS TempSlotsCopy;

CREATE TABLE TempSlotsCopy AS
SELECT * FROM TempNewSlots;

ALTER TABLE TempSlotsCopy
ADD COLUMN SlotID INT AUTO_INCREMENT PRIMARY KEY;


-- 5. CALCULATE HOURS FOR NEW SLOTS (IN HOURS)
SELECT
    IFNULL(SUM(TIMESTAMPDIFF(MINUTE, StartTime, EndTime)) / 60.0, 0)
INTO @NewHours
FROM TempNewSlots;

-- 6. CALCULATE EXISTING HOURS FOR THIS TUTOR (SHOULD BE 0 FOR NEW TUTOR, BUT KEPT FOR CONSISTENCY)
SELECT
    IFNULL(SUM(TIMESTAMPDIFF(MINUTE, StartTime, EndTime)) / 60.0, 0)
INTO @ExistingHours
FROM Availability
WHERE TutorID = @TutorID
  AND IsAvailable = TRUE;

-- 7. TOTAL HOURS AFTER ADDING NEW SLOTS
SET @TotalHours := @NewHours + @ExistingHours;


-- 8. OVERLAP CHECK: NEW SLOTS AMONG THEMSELVES
SELECT EXISTS (
    SELECT 1
    FROM TempSlotsCopy A
    JOIN TempSlotsCopy B
      ON A.DayOfWeek = B.DayOfWeek
     AND A.StartTime < B.EndTime
     AND B.StartTime < A.EndTime
     AND A.SlotID < B.SlotID
) INTO @OverlapNew;


-- 9. OVERLAP CHECK: NEW SLOTS VS EXISTING AVAILABILITY (SHOULD BE NONE FOR NEW TUTOR BUT INCLUDED)
SELECT EXISTS (
    SELECT 1
    FROM TempNewSlots n
    JOIN Availability a
      ON a.TutorID = @TutorID
     AND a.IsAvailable = TRUE
     AND n.DayOfWeek = a.DayOfWeek
     AND n.StartTime < a.EndTime
     AND a.StartTime < n.EndTime
) INTO @OverlapExisting;


-- 10. VALIDATION LOGIC
SET @IsValid := (
    CASE
        WHEN @TotalHours <= @MaxHoursPerWeek
         AND @OverlapNew = 0
         AND @OverlapExisting = 0
        THEN 1
        ELSE 0
    END
);


-- 11. CONDITIONAL INSERT OF AVAILABILITY (ATOMIC)
START TRANSACTION;

-- For a brand-new tutor this DELETE does nothing, but keeps logic consistent.
DELETE FROM Availability
WHERE TutorID = @TutorID
  AND @IsValid = 1;

INSERT INTO Availability (TutorID, DayOfWeek, StartTime, EndTime, IsAvailable)
SELECT @TutorID, DayOfWeek, StartTime, EndTime, TRUE
FROM TempNewSlots
WHERE @IsValid = 1;

COMMIT;


-- 12. STATUS MESSAGE
SELECT
    CASE
        WHEN @IsValid = 1 THEN
            'SUCCESS: New tutor added with initial availability.'
        WHEN @OverlapNew = 1 THEN
            'ERROR: New availability time slots overlap each other.'
        WHEN @OverlapExisting = 1 THEN
            'ERROR: New availability time slots overlap existing schedule.'
        WHEN @TotalHours > @MaxHoursPerWeek THEN
            CONCAT('ERROR: Total hours (', @TotalHours,
                   ') exceed weekly limit of ', @MaxHoursPerWeek, '.')
        ELSE
            'ERROR: Unknown validation failure while adding tutor.'
    END AS Message;


-- 13. VERIFICATION: SHOW NEW TUTOR, THEIR SUBJECTS, AND AVAILABILITY (ONLY IF VALID)
SELECT
    t.TutorID,
    CONCAT(t.FirstName, ' ', t.LastName) AS Tutor,
    s.SubjectName,
    a.DayOfWeek,
    a.StartTime,
    a.EndTime,
    TIMESTAMPDIFF(MINUTE, a.StartTime, a.EndTime) / 60.0 AS Hours
FROM Tutor t
LEFT JOIN TutorSubject ts ON t.TutorID = ts.TutorID
LEFT JOIN Subject s ON ts.SubjectID = s.SubjectID
LEFT JOIN Availability a ON t.TutorID = a.TutorID
WHERE t.TutorID = @TutorID
  AND @IsValid = 1
ORDER BY FIELD(a.DayOfWeek,
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    a.StartTime;


-- 14. CLEANUP
DROP TABLE TempSlotsCopy;
-- (TempNewSlots is TEMPORARY and will be dropped automatically at end of session)
