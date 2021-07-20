create database Group_10
go
use Group_10;

-- Encryption Stuff

create master key 
encryption by password = 'University_Samaroo';

create certificate TestCertificate
with subject = 'University Group 10 Test Certificate',
expiry_date = '2021-11-30';

create symmetric key TestSymmetricKey
with algorithm = AES_128
encryption by certificate TestCertificate;

open symmetric key TestSymmetricKey
decryption by certificate TestCertificate;

-- Table Creation (NOT NEEDED, DATA HAS BEEN IMPORTED)
create table Scholarship
(
    ScholarshipID int not null primary key,
    ScholarshipName varchar(45),
    ScholarshipDesc varchar(100),
    ScholarshipAmt money not null
);
create table Student
(
    StudentID int not null primary key,
    FirstName varchar(15) not null,
    LastName varchar(15) not null,
    SSN varbinary(250),
    Major varchar(25) not null,
    Degree varchar (15) not null,
    GPA float(2) not null,
    GradYear int not null, 
    ScholarshipID int
    references Scholarship(ScholarshipID)
);
create table Degree
(
    DegreeID int not null primary key,
    DegreeName varchar(50) not null,
    DegreeDesc varchar(100) not null
);
create table Major 
(
    MajorID int not null primary key,
    MajorName varchar(30) not null,
    DegreeType varchar(30) not null,
    MajorDesc varchar(100) not null,
    DepartmentID int not null
);
create table Staff
(
    StaffID int not null primary key,
    Position varchar(25),
    DepartmentID int 
);
create table StudentDegreeMajor
(
    StudentID int not null primary key 
    references Student(StudentID),
    DegreeID int not null,
    MajorID int not null,
    ExpectedGrad int not null
);
create table Project
(
    ProjectID int not null primary key,
    ProjectDesc varchar(100),
    InstructorID int not null
);
create table StudentProject
(
    ProjectID int not null,
    StudentID int not null
);
create table Clubs
(
    ClubID int not null primary key,
    ClubType varchar(25) not null,
    InstructorID int not null
);
SELECT * FROM CLUBS
create table ClubRegistration
(
    StudentID int not null primary key,
    ClubID int not null
);
create table Instructors
(
    InstructorID int not null primary key,
    FirstName varchar(15) not null,
    LastName varchar(15) not null,
    Position varchar(25) not null,
    DepartmentID int not null
);
create table Courses
(
    CourseID int not null,
    Term varchar(10) not null,
    TotalSeats int not null,
    MeetingTime time(0) not null,
    CourseLoc varchar(25) not null,
    SeatsAvailable int,
    DepartmentID int not null,
    RoomID int not null,
    InstructorID int not null 
    references Instructors(InstructorID),
    BuildingID int not null
);
create table CourseRegistration
(
    StudentID int not null,
    CourseID int not null
);
create table InstructorProject
(
    InstructorID int not null
    references Instructors(InstructorID),
    ProjectID int not null 
    references Project(ProjectID)
);
create table Department
(
    DepartmentID int not null primary key,
    StudentPopulation int not null,
    BuildingID int not null,
    DepartmentName varchar(20) not null
);
create table Building
(
    BuildingID int not null primary key,
    BuildingName varchar(30) not null
);
create table Rooms
(
    RoomID int not null,
    RoomType varchar(30) not null,
    BuildingID int not null 
    references Building(BuildingID)
);
create table CourseInstructor
(
    InstructorID int not null,
    CourseID int not null
);

-- Constraints
alter table Clubs add constraint InstructorID
    foreign key (InstructorID) references Instructors(InstructorID);
alter table Courses add constraint InstructorIDCourse
    foreign key (InstructorID) references Instructors(InstructorID);
alter table Departments add constraint BuildingID
    foreign key (BuildingID) references Buildings(BuildingID);
alter table Courses add constraint BuildingIDCourse
    foreign key (BuildingID) references Buildings(BuildingID);
alter table Instructors add constraint DepartmentIDInstructors
    foreign key (DepartmentID) references Departments(DepartmentID);
alter table Staff add constraint DepartmentIDStaff
    foreign key (DepartmentID) references Departments(DepartmentID);
alter table Courses add constraint DepartmentIDCourse
    foreign key (DepartmentID) references Departments(DepartmentID);
alter table Majors add constraint DepartmentID
    foreign key (DepartmentID) references Departments(DepartmentID);
alter table ClubRegistration add constraint ClubID 
    foreign key (ClubID) references Clubs(ClubID);
alter table StudentDegreeMajor add constraint DegreeID
    foreign key (DegreeID) references Degrees(DegreeID);
alter table StudentDegreeMajor add constraint MajorID
    foreign key (MajorID) references Majors(MajorID); 

exec sp_RENAME 'Courses.CourseID', 'CourseNumber', 'COLUMN'
alter table Courses add CourseID as CONCAT(DepartmentID,'-',CourseNumber)
-- remove duplicate courseIDs
with CTE as (
    select 
    CourseNumber,
    DepartmentID,
    CourseID,
    ROW_NUMBER() over (
        partition by 
        CourseID, 
        CourseNumber,
        DepartmentID
        order by 
        CourseID,
        CourseNumber,
        DepartmentID
    ) row_num 
    from Courses 
) 
DELETE FROM cte
WHERE row_num > 1;

alter table Courses add constraint PK_Course primary key (CourseID)


-- create a function to check if seats are available in a course
-- WORK IN PROGRESS 
-- not sure how to implement it into table
create function CourseAvailability (@TargetCourse as int)
returns int
as begin
    declare @NumSeats int = 0;
    declare @AvailSeats int = 0;
    select (
        select @NumSeats = count(StudentID) 
        from dbo.CourseRegistration
        where CourseID = @TargetCourse
        ),
        (select @AvailSeats = AvailableSeats
        from dbo.Course
        where CourseID = @TargetCourse
        )
    begin 
    if @AvailSeats - @NumSeats = 0
    -- Prevent registration
    else
    -- update the number of seats available
     return @AvailSeats - NumSeats 
    end
end

-- Populate the Database (ALL THE DATA HAS BEEN IMPORTED)
insert Scholarship
    values
    (
        999,
        'Presidential Scholarship',
        'Highest scholarship given to 5% of students each year',
        28000
    ),
    (
        998,
        'Dean''s Scholarship',
        'Scholarship awarded to 10% of students each year',
        15000
    ),
    (
        997,
        'Math & Science Scholarship',
        'Scholarship awarded to students who are studying in the STEM field',
        5000
    ),
    (
       996,
       'Art & History Scholarship',
       'Scholarship awarded to students who excel in the Art or History fields',
       5000 
    ),
    (
        995,
        'Presidential Global Scholarship',
        'Awarded to students who are studying abroad',
        3000
    ),
    (
        994,
        'Alumni Scholarship',
        'Awarded to students is an alum of this university',
        3000
    ),
    (
        993,
        'Honors Scholarship',
        'Awarded to students who are a part of the Honor''s Program',
        8000
    ),
    (
        992,
        'Athelete Scholarship',
        'Awarded to students who are a part of the university''s athletic team',
        2000
    ),
    (
        991,
        'International Student Scholarship',
        'Awarded to students who are the top percentage of the international applicants',
        10000
    ),
    (
        990,
        'High School Scholarship',
        'Awarded to the student who was the top applicant from their high school',
        4000
    )


insert Student 
    values
    (
        10001,
        'John',
        'Smith', 
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '111-11-1111')),
        'Biology', 
        'Bachelors', 
        3.3, 
        2020, 
        NULL
    ),
    (
        10002,
        'Jane',
        'Doe',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '222-22-2222')),
        'Physics',
        'Bachelors',
        3.7,
        2020,
        999
    ),
    (
        10003,
        'Bob',
        'Saget',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '333-33-3333')),
        'Economics',
        'Bachelors',
        3.4,
        2020,
        993
    ),
    (
        10004,
        'Amanda',
        'Lawrence',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '444-44-4444')),
        'Psychology',
        'Bachelors',
        3.5,
        2020,
        993
    ),
    (
        10005,
        'Calvin',
        'Cheung',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '555-55-5555')),
        'Physics',
        'Bachelors',
        3.3,
        2022,
        994   
    ),
    (
        10006,
        'Rebecca',
        'Singh',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '666-66-6666')),    
        'English',
        'Masters',
        4.0,
        2018,
        994
    ),
    (
        10007,
        'Tristan',
        'Baharally',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '777-77-7777')),
        'Psychology',
        'Masters',
        3.8,
        2018,
        994
    ),
    (
        10008,
        'Justin',
        'Kaur',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '121-11-1122')),
        'Exercise Science',
        'Bachelors',
        3.7,
        2021,
        NULL
    ),
    (
        10009,
        'Imran',
        'Khan',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '212-21-1324')),
        'Finance',
        'Bachelors',
        3.4,
        2019,
        NULL
    ),
    (
        10010,
        'Jeffery',
        'Merry',
        EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '132-21-1342')),
        'Electrical Engineering',
        'Masters',
        3.3,
        2020,
        997 
    )
-- Encryption Check    
select SSN, convert(varchar, decryptbykey(SSN)) from Students

insert Degree  
    values
    (
        101,
        'Bachelor of Science',
        'Covers all science disciplines'
    ),
    (
        102, 
        'Bachelor of Arts',
        'Covers all art disciplines'
    ),
    (
        103,
        'Bachelor of Fine Arts', 
        'Most prestigious bachelor''s degree that one can receive in the visual arts'
    ),
    (
        104, 
        'Master of Science', 
        'Covers all graduate science disciplines'
    ),
    (
        105,
        'Master of Arts', 
        'Covers all graduate art disciplines'
    ),
    (
        106,
        'Master of Fine Arts', 
        'Includes visual arts, creative writing, graphic design, photography, filmmaking, dance, theatre'
    ),
    (
        107, 
        'Doctor of Philosophy', 
        'The highest academic degree awarded and requires at least four years of study and extensive original research'
    ),
    (
        108, 
        'Master of Business Administration', 
        'Cover various areas of business such as accounting, business communication, business ethics, business law, finance and more'
    ),
    (
        109, 
        'Bachelor of Applied Science',
        'A highly specialized professional technical degree; typically containing advanced technical training' 
    ),
    (
        110, 
        'Master of Engineering',
        'Academic or professional master''s degree in the field of engineering.'    
    )

insert Building
    values
    (
        201,
        'Forsyth Building'
    ),
    (
        202,
        'Nexus Building'
    ),
    (
        203,
        'Post Hall'
    ),
    (
        204,
        'Snell Library'
    ),
    (
        205,
        'Varick Building'
    ),
    (
        206,
        'Stark Building'
    ),
    (
        207,
        'Swirbul Building'
    ),
    (
        208,
        'Woolworth Building'
    ),
    (
        209,
        'Prudential Building'
    ),
    (
        210,
        'Huntington Building'
    )

insert Department
    values
    (
        100,
        120,
        201,
        'Physics'
    ),
    (
        200,
        300,
        202,
        'Biology'
    ),
    (
        300,
        225,
        203,
        'Chemistry'
    ),
    (
        400,
        210,
        204,
        'English'
    ),
    (
        500,
        160,
        205,
        'History'
    ),
    (
        600,
        500,
        206,
        'Engineering'
    ),
    (
        700,
        300,
        207,
        'Mathematics'
    ),
    (
        800,
        340,
        208,
        'Business'
    ),
    (
        900,
        320,
        209,
        'Social Science'
    ),
    (
        110,
        250,
        210,
        'Public Health'
    )

insert Staff
    values 
    (
        4000,
        'Administrator',
        100
    ),
    (
        4001,
        'Adjunct Professor',
        110
    ),
    (
        4002,
        'Asociate Professor',
        400
    ),
    (
        4003,
        'Department Head',
        500
    ),
    (
        4004,
        'Visiting Professor',
        300
    ),
    (
        4005,
        'Tenured Professor',
        700
    ),
    (
        4006,
        'Associate Professor',
        900
    ),
    (
        4007,
        'Department Head',
        600
    ),
    (
        4008,
        'Adjunct Professor',
        200
    ),
    ( 
        4009,
        'Associate Professor',
        100
    )

insert Rooms
    values 
    (
        100,
        'Classroom',
        201
    ),
    (
        101,
        'Computer Lab',
        201
    ),
    (
        102,
        'Classroom',
        201
    ),
    (
        103,
        'Lecture Hall',
        201
    ),
    (
        104,
        'Classroom',
        201
    ),
    (
        105,
        'Office',
        201
    ),
    (
        106,
        'Department Office',
        201
    ),
    (
        107,
        'Classroom',
        201
    ),
    (
        108,
        'Classroom',
        201
    ),
    (
        109,
        'Computer Lab',
        201
    )

insert Instructors
    values
    ( 
        110,
        'Matthew',
        'Wright',
        'Department Chair',
        100
    ),
    (
        111,
        'Sarah',
        'Wright',
        'Associate Professor',
        700
    ),
    (
        112,
        'John',
        'Petrilli',
        'Tenured Professor',
        700
    ),
    (
        113,
        'Caesar',
        'Agelerakis',
        'Department Chair',
        500
    ),
    (
        114,
        'Julius',
        'Petrizzo',
        'Associate Professor',
        110
    ),
    (
        115,
        'Nicole',
        'Tan',
        'Adjunct Professor',
        300
    ),
    (
        116,
        'Jane',
        'Irwin',
        'Visiting Professor',
        200
    ),
    (
        117,
        'George',
        'Singh',
        'Associate Professor',
        600
    ),
    (
        118, 
        'Obi',
        'Wan',
        'Visiting Professor',
        '500'
    ),
    (
        119,
        'Luke',
        'Moonwalker',
        'Visiting Professor',
        500
    )

insert Course
    values
    (
        101,
        'Fall',
        1,
        50,
        '09:00:00',
        'Forsyth Building',
        NULL,
        30,
        100,
        103,
        110,
        201                
    ),
    (
        102,
        'Fall',
        2,
        50,
        '12:00:00',
        'Forsyth Building',
        NULL,
        45,
        100,
        103,
        110,
        201
    ),
    (
        201,
        'Fall',
        1,
        50,
        '14:00:00',
        'Forsyth Building',
        '100-101',
        30,
        100,
        102,
        110,
        201
    ),
    (
        216,
        'Fall',
        1,
        25,
        '15:00:00',
        'Forsyth Building',
        '100-101, 100-201',
        15,
        100,
        109,
        110,
        201
    ),
    (
        300,
        'Fall',
        1,
        30,
        '09:00:00',
        'Forsyth Building',
        '100-101, 100-201',
        10,
        100,
        109,
        110,
        201
    ),
    (
        330,
        'Spring',
        1,
        25,
        '10:30:00',
        'Forsyth Building',
        '100-101, 100-201',
        25,
        100,
        104,
        110,
        201
    ),
    (
        440,
        'Spring',
        1,
        15,
        '12:00:00',
        'Forsyth Building',
        '100-101, 100-201, 100-301',
        15,
        100,
        103,
        110,
        201    
    ),
    (
        103,
        'Spring',
        1,
        50,
        '09:00:00',
        'Forsyth Building',
        '100-101',
        50,
        100,
        101,
        110,
        201
    ),
    (
        202,
        'Spring',
        1,
        35,
        '12:00:00',
        'Forsyth Building',
        '100-101,100-102,100-201',
        35,
        100,
        101,
        110,
        201
    ),
    (
        210,
        'Spring',
        1,
        20,
        '15:00:00',
        'Forsyth Building',
        '100-101, 100-102',
        20,
        100,
        108,
        110,
        201
    )

insert CourseInstructor
    values 
    (
        110,
        101
    ),
    (
        110,
        102
    ),
    (
        110,
        103
    ),
    (
        110,
        201
    ),
    (
        110,
        202
    ),
    (
        110,
        210
    ),
    (
        110,
        216
    ),
    (
        110,
        300
    ),
    (
        110,
        330
    ),
    (
        110,
        440
    )


insert Major
    values 
    (
        101,
        'Physics',
        'Bachelors',
        'Bachelor of Science in Physics',
        100
    ),
    (
        802,
        'Economics',
        'Bachelors',
        'Bachelor of Science in Economics',
        800
    ),
    (
        811,
        'Finance',
        'Bachelors',
        'Bachelor of Arts in Finance',
        800
    ),
    (
        201,
        'Biology',
        'Bachelors',
        'Bachelor of Science in Biology',
        200
    ),
    (
        902,
        'Psychology',
        'Masters',
        'Master of Science in Psychology',
        900
    ),
    (
        603,
        'Electrical Engineering',
        'Masters',
        'Master of Science in Electrical Engineering',
        600
    ),
    (
        410,
        'English',
        'Masters',
        'Master of Science in English',
        400
    ),
    (
        601,
        'Electrical Engineering',
        'Bachelors',
        'Bachelor of Science in Electrical Engineering',
        600
    ),
    (
        901,
        'Psychology',
        'Bachelors',
        'Bachelor of Science in Psychology',
        900
    ),
    (
        111,
        'Exercise Science',
        'Bachelors',
        'Bachelor of Arts in Exercise Science',
        110
    )

insert StudentDegreeMajor
    values
    (
        10001,
        101,
        201,
        2020
    ),
    (
        10002,
        101,
        101,
        2020
    ),
    (
        10003,
        101,
        802,
        2020
    ),
    (
        10004,
        101,
        901,
        2020
    ),
    (
        10005,
        101,
        101,
        2022
    ),
    (
        10006,
        104,
        410,
        2018
    ),
    (
        10007,
        104,
        902,
        2018
    ),
    (
        10008,
        107,
        111,
        2021
    ),
    (
        10009,
        103,
        811,
        2019
    ),
    (
        10010,
        101,
        603,
        2020
    )
insert Club
    values
    (
        30,
        'Physics Club',
        110
    ),
    (
        31,
        'History Club',
        118
    ),
    (
        32,
        'Weightlifting Club',
        114
    ),
    (
        33,
        'Biology Club',
        116
    ),
    (
        34,
        'Math Club',
        111
    ),
    (
        35,
        'Robotics Club',
        117
    ),
    (
        36,
        'Archaeology Club',
        113
    ),
    (
        37,
        'Chemistry Club',
        115
    ),
    (
        38,
        'Greek & Roman Club',
        119
    ),
    (
        39,
        'Computer Science Club',
        112
    )

insert ClubRegistration
    values 
    (10001, 33), 
    (10002, 30),
    (10003, 31),
    (10004, 38),
    (10005, 30),
    (10006, 38),
    (10007, 36),
    (10008, 32),
    (10009, 32),
    (10010, 32)

insert CourseRegistration
    values
    (10002, 101),
    (10002, 102),
    (10002, 103),
    (10002, 201),
    (10002, 202),
    (10002, 210),
    (10002, 216),
    (10002, 300),
    (10002, 330)
-- These are sample entries, not realistic
insert Project 
    values
    (
        1001,
        'Solid State Physics Research',
        110
    ),
    (
        1002,
        'Graph Theory Project',
        111
    ),
    (
        1003,
        'Abstract Algebra Project',
        112
    ),
    (
        1004,
        'Archaeology Project',
        113
    ),
    (
        1005,
        'Excercising Clinical Trial',
        114
    ),
    (
        1006,
        'Organic Chemistry Project',
        115
    ),
    (
        1007,
        'Marine Biology Excursion',
        116
    ),
    (
        1008,
        'Robotics Competition',
        117
    ),
    (
        1009,
        'Greek Translation Project',
        118
    ),
    (
        1010,
        'Aztec Restoration Project',
        119
    )



insert StudentProject
    values
    (
        1001,
        10002
    ),
    (
        1001,
        10005
    ),
    (
        1001,
        10010
    ),
    (
        1008,
        10010
    ),
    (
        1007,
        10001
    ),
    (
        1005,
        10008
    ),
    (
        1006,
        10001
    ),
    (
        1009,
        10006
    ),
    (
        1008,
        10005
    ),
    (
        1008,
        10002
    )

insert InstructorProject

    values
    (
        110,
        1001
    ),
    (
        111,
        1002
    ),
    (
        112,
        1003
    ),
    (
        113,
        1004
    ),
    (
        114,
        1005
    ),
    (
        115,
        1006
    ),
    (
        116,
        1007
    ),
    (
        117,
        1008
    ),
    (
        118,
        1009
    ),
    (
        119,
        1010
    )
-- Create Views
create view StudentList as 
    select StudentID, FirstName, LastName, Degree, Major
    from Students;

select * from StudentList;

create view InstructorList as 
    select InstructorID, FirstName, LastName, DepartmentID
    from Instructors;

select * from InstructorList;

select * from Majors