USE DATA_9401

SELECT * FROM [gradeRecordModuleV_Master];

--Create tables--
Create table FirstFiftyGrades (
	StudentID INT NOT NULL,
	FirstName NVARCHAR (50),
	LastName NVARCHAR (50),
	MidtermExam FLOAT,
	FinalExam FLOAT,
	Assignment1 FLOAT,
	Assignment2 FLOAT,
	TotalPoints INT,
	StudentAverage FLOAT,
	Grade NVARCHAR (20)
	);

INSERT INTO FirstFiftyGrades
SELECT TOP (50) *
FROM [gradeRecordModuleV_Master]
ORDER BY studentID ASC;

--Code to find duplicates--
SELECT HouseID, count (*)
FROM kc_HousePrice Group BY HouseID
HAVING COUNT (HouseID) >1
ORDER BY HouseID;

--Code to establish 2NF: Eliminate redundant data and dependencies--
--Create NameTable and PK/FK Relationships--
SELECT StudentID,
	FirstName,
	LastName
INTO NameTable
FROM FirstFiftyGrades;

ALTER TABLE NameTable
ADD CONSTRAINT pk_StudentID PRIMARY KEY (StudentID);

ALTER TABLE FirstFiftyGrades
ADD CollectiveID INT IDENTITY (1,1);

ALTER TABLE FirstFiftyGrades
ADD CONSTRAINT pk_CollectiveID PRIMARY KEY (CollectiveID);

ALTER TABLE FirstFiftyGrades
ADD FOREIGN KEY (StudentID) REFERENCES NameTable (StudentID);


--Code to create Student Average Table--
SELECT StudentID,
	StudentAverage,
	Grade
INTO StudentAverageTable
FROM FirstFiftyGrades;

ALTER TABLE StudentAverageTable
ADD StudentAveID INT IDENTITY (1,1);
 
ALTER Table StudentAverageTable
ADD CONSTRAINT pk_StudentAveID PRIMARY KEY (StudentAveID);


--Create Letter Grade Only Table--
SELECT Grade
INTO LetterGradeOnly
FROM FirstFiftyGrades;

--Code to delete duplicates from letter grade table--
WITH CTE AS (
SELECT Grade, ROW_NUMBER () OVER (
PARTITION BY Grade
ORDER BY Grade
) row_number
FROM LetterGradeOnly
)

DELETE FROM cte
WHERE row_number >1
;

--Update Letter Table with missing letter grades--
INSERT INTO LetterGradeOnly
Values ('A+');

INSERT INTO LetterGradeOnly
Values ('A');

INSERT INTO LetterGradeOnly
Values ('B');

ALTER TABLE LetterGradeOnly
ADD LetterID INT;

UPDATE LetterGradeOnly
SET LetterID = 13
WHERE Grade = 'F'

UPDATE LetterGradeOnly
SET LetterID = 12
WHERE Grade = 'D-'

UPDATE LetterGradeOnly
SET LetterID = 11
WHERE Grade = 'D'

UPDATE LetterGradeOnly
SET LetterID = 10
WHERE Grade = 'D+'

UPDATE LetterGradeOnly
SET LetterID = 9
WHERE Grade = 'C-'

UPDATE LetterGradeOnly
SET LetterID = 8
WHERE Grade = 'C'

UPDATE LetterGradeOnly
SET LetterID = 7
WHERE Grade = 'C+'

UPDATE LetterGradeOnly
SET LetterID = 6
WHERE Grade = 'B-'

UPDATE LetterGradeOnly
SET LetterID = 5
WHERE Grade = 'B'

UPDATE LetterGradeOnly
SET LetterID = 4
WHERE Grade = 'B+'

UPDATE LetterGradeOnly
SET LetterID = 3
WHERE Grade = 'A-'

UPDATE LetterGradeOnly
SET LetterID = 2
WHERE Grade = 'A'

UPDATE LetterGradeOnly
SET LetterID = 1
WHERE Grade = 'A+'

ALTER TABLE LetterGradeOnly
ADD CONSTRAINT pk_LetterID PRIMARY KEY (LetterID);

--Create PK/FK relationship between LetterGradeONly Table and StudentAverage Table--
ALTER TABLE StudentAverageTable
ADD LetterID INT;

UPDATE StudentAverageTable
SET LetterID = Case
	When Grade = 'F' Then 1
	When Grade = 'D-' Then 2
	When Grade = 'D' Then 3
	When Grade = 'D+' Then 4
	When Grade = 'C-' Then 5
	When Grade = 'C' Then 6
	When Grade = 'C+' Then 7
	When Grade = 'B-' Then 8
	When Grade = 'B' Then 9
	When Grade = 'B+' Then 10
	When Grade = 'A-' Then 11
	When Grade = 'A' Then 12
	When Grade = 'A+' Then 13
Else 0
END

ALTER TABLE StudentAverageTable
ADD CONSTRAINT fk_StudentID FOREIGN KEY (StudentID)
REFERENCES NameTable (StudentID);

ALTER TABLE StudentAverageTable
ADD CONSTRAINT fk_LetterID FOREIGN KEY (LetterID)
REFERENCES LetterGradeOnly (LetterID);

ALTER TABLE StudentAverageTable
DROP Column Grade;

--Create Letter Grade Table and PK/FK Relationships--
SELECT StudentID,
	StudentAverage,
	Grade 
INTO LetterGrade
FROM FirstFiftyGrades;

ALTER TABLE LetterGrade
ADD GradeID INT IDENTITY (1,1);
 
ALTER Table LetterGrade
ADD CONSTRAINT pk_GradeID PRIMARY KEY (GradeID);

ALTER TABLE FirstFiftyGrades
ADD GradeID INT;

--Case Statement--
Update FirstFiftyGrades
SET GradeID = Case
	When Grade = 'F' Then 1
	When Grade = 'D-' Then 2
	When Grade = 'D' Then 3
	When Grade = 'D+' Then 4
	When Grade = 'C-' Then 5
	When Grade = 'C' Then 6
	When Grade = 'C+' Then 7
	When Grade = 'B-' Then 8
	When Grade = 'B' Then 9
	When Grade = 'B+' Then 10
	When Grade = 'A-' Then 11
	When Grade = 'A' Then 12
	When Grade = 'A+' Then 13
Else 0
END
WHERE Grade IN ('F', 'D-', 'D', 'D+', 'C-', 'C', 'C+', 'B-', 'B', 'B+', 'A-', 'A', 'A+');


--Code to drop columns--
ALTER Table FirstFiftyGrades
DROP COLUMN FirstName, LastName;

ALTER Table FirstFiftyGrades
DROP COLUMN StudentAverage;

ALTER Table FirstFiftyGrades
DROP COLUMN Grade, GradeID;

ALTER Table StudentAverageTable
DROP COLUMN Grade;

--JOIN--
SELECT NameTable.FirstName,
		NameTable.LastName,
		StudentAverageTable.StudentAverage
FROM NameTable INNER JOIN StudentAverageTable
ON NameTable.StudentID = StudentAverageTable.StudentID

SELECT NameTable.StudentID,
	NameTable.FirstName,
	NameTable.LastName,
	StudentAverageTable.StudentAverage,
	LetterGradeOnly.Grade
FROM NameTable 
INNER JOIN StudentAverageTable
ON NameTable.StudentID = StudentAverageTable.StudentID
INNER JOIN LetterGradeOnly
ON StudentAverageTable.LetterID = LetterGradeOnly.LetterID;

 SELECT NameTable.StudentID,
	NameTable.FirstName,
	NameTable.LastName,
	StudentAverageTable.StudentAverage,
	FirstFiftyGrades.TotalPoints,
	LetterGradeOnly.Grade
FROM NameTable 
INNER JOIN StudentAverageTable
ON NameTable.StudentID = StudentAverageTable.StudentID
INNER JOIN LetterGradeOnly
ON StudentAverageTable.LetterID = LetterGradeOnly.LetterID
INNER JOIN FirstFiftyGrades
ON NameTable.StudentID = FirstFiftyGrades.StudentID;

--Select Statements--
SELECT * FROM FirstFiftyGrades
ORDER BY StudentID ASC;

SELECT * FROM NameTable;

SELECT * FROM LetterGradeOnly
ORDER BY LetterID ASC;

SELECT * FROM StudentAverageTable;