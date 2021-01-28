USE CANADA

ALTER TABLE [Cda_employmentrate_1990to1999_RawData]
ADD EmploymentID INT IDENTITY (1,1);

--Code to create new tables from raw data to achieve 2NF--
SELECT EmploymentType 
INTO  EmploymentTypeNew
FROM [Cda_employmentrate_1990to1999_RawData];

SELECT Sex 
INTO Gender
FROM [Cda_employmentrate_1990to1999_RawData];

SELECT Year,
	Month,
	EmploymentType,
	Sex,
	Alberta,
	British_Columbia,
	Manitoba, New_Brunswick,
	Newfoundland_and_Labrador,
	Nova_Scotia, Ontario,
	Prince_Edward_Island,
	Quebec 
INTO Provinces
FROM [Cda_employmentrate_1990to1999_RawData];

SELECT Year
INTO YearTable
FROM [Cda_employmentrate_1990to1999_RawData];

SELECT Month 
INTO MonthTable
FROM TimeTable;

--Code to delete duplicates to achieve 2 NF--
WITH cte AS (
SELECT EmploymentType, ROW_NUMBER () OVER (
PARTITION BY EmploymentType
ORDER BY EmploymentType
) row_num
FROM EmploymentTypeNew
)
DELETE FROM cte
WHERE row_num>1;

WITH cte AS (
SELECT Sex, ROW_NUMBER () OVER (
PARTITION BY Sex
ORDER BY Sex
) row_num
FROM Gender
)
DELETE FROM cte
WHERE row_num>1;

WITH cte AS (
SELECT Year, ROW_NUMBER () OVER (
PARTITION BY Year
ORDER BY Year
) row_num
FROM YearTable
)
DELETE FROM cte
WHERE row_num>1;

WITH cte AS (
SELECT Month, ROW_NUMBER () OVER (
PARTITION BY Month
ORDER BY Month
) row_num
FROM MonthTable
)
DELETE FROM cte
WHERE row_num>1;

--Codes to achieve 3NF--
--Alter tables to add new column--
ALTER TABLE Gender
ADD SexUniqueID INT;

ALTER TABLE EmploymentTypeNew
ADD EmploymentID INT;

ALTER TABLE Provinces
ADD EmploymentID INT;

ALTER TABLE Provinces
ADD SexID INT;

ALTER TABLE Provinces
ADD EmployProvinceID INT IDENTITY (1,1);

ALTER TABLE YearTable
ADD YearID INT IDENTITY (1,1);

ALTER TABLE MonthTable
ADD MonthID INT IDENTITY (1,1);

--Update Employment Table--
UPDATE EmploymentTypeNew
SET EmploymentID = 1
WHERE EmploymentType = 'Employment';

UPDATE EmploymentTypeNew
SET EmploymentID = 2
WHERE EmploymentType = 'Part-time employment';

UPDATE EmploymentTypeNew
SET EmploymentID = 3
WHERE EmploymentType = 'Full-time employment';

--Update Gender Table--
UPDATE Gender
SET SexUniqueID = 1
WHERE Sex = 'Both sexes';

UPDATE Gender
SET SexUniqueID = 2
WHERE Sex = 'Males';

UPDATE Gender
SET SexUniqueID = 3
WHERE Sex = 'Females';

--Case Statement for Provinces Table--
UPDATE Provinces 
SET EmploymentID = CASE
	WHEN EmploymentType = 'Employment' Then 1
	WHEN EmploymentType = 'Full-time employment' Then 2
	WHEN EmploymentType = 'Part-time employment' Then 3
	ELSE 0
	END

UPDATE Provinces 
SET SexID = CASE
	WHEN Sex = 'Both sexes' Then 1
	WHEN Sex = 'Males' Then 2
	WHEN Sex = 'Females' Then 3
	ELSE 0
	END

UPDATE Provinces
SET Month = CASE
	WHEN Month = 'January' THEN 1
	WHEN Month = 'February' THEN 2
	WHEN Month = 'March' THEN 3
	WHEN Month = 'April' THEN 4
	WHEN Month = 'May' THEN 5
	WHEN Month = 'June' THEN 6
	WHEN Month = 'July' THEN 7
	WHEN Month = 'August' THEN 8
	WHEN Month = 'September' THEN 9
	WHEN Month = 'October' THEN 10
	WHEN Month = 'November' THEN 11
	WHEN Month = 'December' THEN 12
	ELSE 0
	END;

UPDATE Provinces
SET Year = CASE
	WHEN Year = '1990' THEN 1
	WHEN Year = '1991' THEN 2
	WHEN Year = '1992' THEN 3
	WHEN Year = '1993' THEN 4
	WHEN Year = '1994' THEN 5
	WHEN Year = '1995' THEN 6
	WHEN Year = '1996' THEN 7
	WHEN Year = '1997' THEN 8
	WHEN Year = '1998' THEN 9
	WHEN Year = '1999' THEN 10
	ELSE 0
	END;

--Drop Columns--
ALTER TABLE Provinces
DROP COLUMN EmploymentType;

ALTER TABLE Provinces
DROP COLUMN Sex;

--Alter Column Names--
EXEC sp_rename 'Provinces.Month', 'MonthID', 'COLUMN';
EXEC sp_rename 'Provinces.Year', 'YearID', 'COLUMN';

--Alter Data Type--
ALTER TABLE Provinces
ALTER COLUMN MonthID INT;

--Assign NOT NULL Constraint--
ALTER TABLE Gender
ALTER COLUMN SexUniqueID INT NOT NULL;

--Assign Primary Keys--
ALTER TABLE Provinces
ADD CONSTRAINT PK_EmployProvinceID PRIMARY KEY (EmployProvinceID);

ALTER TABLE YearTable
ADD CONSTRAINT PK_YearID PRIMARY KEY (YearID);

ALTER TABLE MonthTable
ADD CONSTRAINT PK_MonthID PRIMARY KEY (MonthID);

ALTER TABLE Gender
ADD CONSTRAINT PK_SexUniqueID PRIMARY KEY (SexUniqueID);

--Assign Foreign Keys--
ALTER TABLE Provinces
ADD CONSTRAINT FK_EmploymentID FOREIGN KEY (EmploymentID)
REFERENCES EmploymentTypeNew (EmploymentID);

ALTER TABLE Provinces
ADD CONSTRAINT FK_SexID FOREIGN KEY (SexID)
REFERENCES Gender (SexUniqueID);

ALTER TABLE Provinces
ADD CONSTRAINT FK_YearID FOREIGN KEY (YearID)
REFERENCES YearTable (YearID);

ALTER TABLE Provinces
ADD CONSTRAINT FK_MonthID FOREIGN KEY (MonthID)
REFERENCES MonthTable (MonthID);

--Create Join query to determine the employment rate of men who were employed full-tim in January, 1990--
SELECT YearTable.Year,
		MonthTable.Month,
		EmploymentTypeNew.EmploymentType,
		Gender.Sex,
		Provinces.Ontario
INTO OntarioEmploymentResult
FROM Provinces
INNER JOIN EmploymentTypeNew
ON Provinces.EmploymentID = EmploymentTypeNew.EmploymentID
INNER JOIN Gender
ON Provinces.SexID = Gender.SexUniqueID
INNER JOIN YearTable
ON Provinces.YearID = YearTable.YearID
INNER JOIN MonthTable
ON Provinces.MonthID = MonthTable.MonthID
WHERE Provinces.EmploymentID = 3 AND Gender.Sex = 'Males' AND YearTable.Year = '1990' AND MonthTable.Month = 'January';


--SELECT Statements--
SELECT * FROM [Cda_employmentrate_1990to1999_RawData];
SELECT * FROM EmploymentTypeNew;
SELECT * FROM Provinces;
SELECT * FROM Gender;
SELECT * FROM TimeTable;
SELECT * FROM YearTable;
SELECT * FROM MonthTable;
SELECT * FROM Provinces;
SELECT * FROM OntarioEmploymentResult;

--DROP Statements--
DROP TABLE OntarioEmploymentResult;




