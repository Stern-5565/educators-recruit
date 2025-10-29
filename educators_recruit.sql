-- Educators Recruit business scenario implementation
-- This script creates the schema, loads the supplied sample data, and
-- produces the requested reports.

-- Safety cleanup so the script can be rerun without errors.
IF OBJECT_ID('dbo.EducatorPlacements', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.EducatorPlacements;
END;
GO

CREATE TABLE dbo.EducatorPlacements
(
    EducatorID      INT IDENTITY(1,1) PRIMARY KEY,
    FirstName       NVARCHAR(50)  NOT NULL,
    LastName        NVARCHAR(50)  NOT NULL,
    DateOfBirth     DATE          NOT NULL,
    Gender          NVARCHAR(10)  NOT NULL,
    CollegeAttended NVARCHAR(100) NOT NULL,
    DegreeTitle     NVARCHAR(100) NOT NULL,
    MediaSource     NVARCHAR(50)  NOT NULL,
    DateContacted   DATE          NOT NULL,
    SchoolPlaced    NVARCHAR(100) NULL,
    DatePlaced      DATE          NULL
);
GO

INSERT INTO dbo.EducatorPlacements
    (FirstName, LastName, DateOfBirth, Gender, CollegeAttended, DegreeTitle,
     MediaSource, DateContacted, SchoolPlaced, DatePlaced)
VALUES
    (N'Mary',    N'Lynn',    '2000-09-13', N'female', N'Excelsior College',      N'BA in Mathematics Education', N'magazine',          '2022-05-02', N'Brooklyn High School',        '2022-05-09'),
    (N'Josh',    N'Frank',   '1998-04-23', N'male',   N'Georgia State University', N'MA in Social Studies Education', N'social media site', '2022-02-12', N'Manhattan Elementary School', '2022-05-09'),
    (N'Charles', N'Smith',   '1994-07-09', N'male',   N'Excelsior College',      N'PhD in Education',             N'social media site', '2021-08-07', N'New York City Day School',   '2021-08-12'),
    (N'Samantha',N'Brown',   '1999-09-24', N'female', N'Columbia University',    N'BA in English Education',      N'newspaper',         '2021-05-23', N'Brooklyn High School',        '2021-07-30'),
    (N'Howard',  N'Lang',    '1998-08-04', N'male',   N'Georgia State University', N'MA in History Education',     N'word of mouth',     '2022-01-31', NULL,                         NULL),
    (N'Sarah',   N'Blanks',  '1995-10-20', N'female', N'Columbia University',    N'MA in Science Education',      N'social media',      '2020-05-23', N'New York City Day School',   '2020-08-17'),
    (N'Ella',    N'Lewis',   '2000-08-22', N'female', N'Excelsior College',      N'BA in English Education',      N'word of mouth',     '2022-04-01', NULL,                         NULL),
    (N'Julie',   N'Goldman', '1997-03-30', N'female', N'University of Denver',    N'MA in Social Studies Education', N'social media',    '2020-07-14', N'Manhattan Elementary School', '2020-08-17');
GO

/*
Report 1: Number of educators from each college who were placed within 14 days of contacting us.
Only educators with a placement date are considered, and the placement must occur within
14 days (inclusive) of the contact date.
*/
SELECT
    ep.CollegeAttended,
    COUNT(*) AS EducatorsPlacedInUnderTwoWeeks
FROM dbo.EducatorPlacements AS ep
WHERE ep.DatePlaced IS NOT NULL
  AND DATEDIFF(DAY, ep.DateContacted, ep.DatePlaced) <= 14
GROUP BY ep.CollegeAttended
ORDER BY ep.CollegeAttended;
GO

/*
Report 2: Placement success by gender.
Counts the number of placed educators (non-null DatePlaced) per gender.
*/
SELECT
    ep.Gender,
    COUNT(*) AS PlacedEducators
FROM dbo.EducatorPlacements AS ep
WHERE ep.DatePlaced IS NOT NULL
GROUP BY ep.Gender
ORDER BY ep.Gender;
GO

/*
Report 3A: Average number of people who contact us per day.
Calculates the daily counts and averages them.
*/
WITH DailyContacts AS
(
    SELECT
        ep.DateContacted,
        COUNT(*) AS ContactsOnDate
    FROM dbo.EducatorPlacements AS ep
    GROUP BY ep.DateContacted
)
SELECT AVG(ContactsOnDate * 1.0) AS AvgContactsPerDay
FROM DailyContacts;
GO

/*
Report 3B: Number of people who find out about us per form of media.
This shows how many educators in the data learned about us through each media channel,
allowing marketing investments to focus on the most effective sources.
*/
WITH MediaCounts AS
(
    SELECT
        ep.MediaSource,
        COUNT(*) AS EducatorsPerMedia
    FROM dbo.EducatorPlacements AS ep
    GROUP BY ep.MediaSource
)
SELECT
    MediaSource,
    EducatorsPerMedia
FROM MediaCounts
ORDER BY MediaSource;
GO

/*
Report 4: Average number of people we place per day.
Only counts educators with a placement date and averages the daily placements.
*/
WITH DailyPlacements AS
(
    SELECT
        ep.DatePlaced,
        COUNT(*) AS PlacementsOnDate
    FROM dbo.EducatorPlacements AS ep
    WHERE ep.DatePlaced IS NOT NULL
    GROUP BY ep.DatePlaced
)
SELECT AVG(PlacementsOnDate * 1.0) AS AvgPlacementsPerDay
FROM DailyPlacements;
GO

/*
Report 5: Number of educators placed per day per degree title.
*/
SELECT
    ep.DegreeTitle,
    ep.DatePlaced,
    COUNT(*) AS EducatorsPlaced
FROM dbo.EducatorPlacements AS ep
WHERE ep.DatePlaced IS NOT NULL
GROUP BY ep.DegreeTitle, ep.DatePlaced
ORDER BY ep.DegreeTitle, ep.DatePlaced;
GO

/*
Report 6: List of educators who contacted us with first name, last name, age, and degree title.
The age is calculated as of today using precise year calculation.
*/
SELECT
    ep.FirstName,
    ep.LastName,
    DATEDIFF(YEAR, ep.DateOfBirth, CAST(GETDATE() AS DATE))
      - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, ep.DateOfBirth, CAST(GETDATE() AS DATE)), ep.DateOfBirth) > CAST(GETDATE() AS DATE)
             THEN 1 ELSE 0 END AS Age,
    ep.DegreeTitle
FROM dbo.EducatorPlacements AS ep
ORDER BY ep.LastName, ep.FirstName;
GO
