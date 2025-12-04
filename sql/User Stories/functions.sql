USE CBU_TutoringCenter;

DROP FUNCTION IF EXISTS fn_TutorWeeklyHours;

DELIMITER $$

CREATE FUNCTION fn_TutorWeeklyHours(pTutorID INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE vTotalHours DECIMAL(5,2);

    SELECT 
        IFNULL(SUM(TIMESTAMPDIFF(MINUTE, StartTime, EndTime)) / 60.0, 0)
    INTO vTotalHours
    FROM Availability
    WHERE TutorID = pTutorID
      AND IsAvailable = TRUE;

    RETURN vTotalHours;
END$$

DELIMITER ;