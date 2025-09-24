-- task 1.1
CREATE DATABASE university_main
    OWNER "postgres"
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
    CONNECTION LIMIT = 50
    TEMPLATE = template0;

CREATE DATABASE university_test
    IS_TEMPLATE = true
    CONNECTION LIMIT = 10;

--task 1.2
CREATE TABLESPACE student_data
    LOCATION '/data/students';

CREATE TABLESPACE course_data
    OWNER "postgres"
    LOCATION '/data/courses';

CREATE DATABASE university_distributed
    ENCODING = 'UTF8';

-- task 2.1

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa DECIMAL(3, 2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(10, 2),
    is_tenured BOOLEAN,
    years_experience INT
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INT,
    course_fee DECIMAL(8, 2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);

-- task 2.2
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INT,
    professor_id INT,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    year INT,
    grade CHAR(2),
    attendance_percentage DECIMAL(4, 1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
);
-- task 3.1
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20);

ALTER TABLE students
    ALTER COLUMN phone TYPE VARCHAR(20);

ALTER TABLE students
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE';

ALTER TABLE students
    ALTER COLUMN gpa SET DEFAULT 0.00;


ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ADD COLUMN last_promotion_date DATE;

ALTER TABLE professors
    ALTER COLUMN years_experience TYPE SMALLINT;

ALTER TABLE professors
    ALTER COLUMN is_tenured SET DEFAULT false;



ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INT,
    ADD COLUMN difficulty_level SMALLINT;

ALTER TABLE courses
    ALTER COLUMN course_code TYPE VARCHAR(10);

ALTER TABLE courses
    ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE courses
    ADD COLUMN lab_required BOOLEAN DEFAULT false;



-- task3.2

ALTER TABLE class_schedule
    ADD COLUMN room_capacity INT,
    DROP COLUMN duration,
    ADD COLUMN session_type VARCHAR(15),
    ADD COLUMN equipment_needed TEXT;

ALTER TABLE class_schedule
    ALTER COLUMN classroom TYPE VARCHAR(30);



ALTER TABLE student_records
    ADD COLUMN extra_credit_points DECIMAL(3, 1),
    ADD COLUMN final_exam_date DATE;

ALTER TABLE student_records
    ALTER COLUMN grade TYPE VARCHAR(5);

ALTER TABLE student_records
    ALTER COLUMN extra_credit_points SET DEFAULT 0.0;

ALTER TABLE student_records
    DROP COLUMN last_updated;


-- task 4.1

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(12, 2),
    established_year INT
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price DECIMAL(7, 2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INT,
    book_id INT,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount DECIMAL(5, 2),
    loan_status VARCHAR(20)
);

-- task 4.2
CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4, 1),
    max_percentage DECIMAL(4, 1),
    gpa_points DECIMAL(3, 2)
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INT,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

-- task 4.2
ALTER TABLE professors
    ADD COLUMN department_id INT;

ALTER TABLE students
    ADD COLUMN advisor_id INT;

ALTER TABLE courses
    ADD COLUMN department_id INT;


-- task 5.1

DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4, 1),
    max_percentage DECIMAL(4, 1),
    gpa_points DECIMAL(3, 2),
    description TEXT
);


DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INT,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

-- task 5.2
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
    TEMPLATE university_main;


-- #################################################
-- TASK DURING THE LESSON start time


CREATE DATABASE library_system
    CONNECTION LIMIT = 75;

CREATE TABLESPACE digital_content
    LOCATION '/storage/ebooks';

CREATE TABLE book_catalog(
    catalog_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    book_title VARCHAR(150),
    author_name VARCHAR(100),
    publisher VARCHAR(80),
    publication_year SMALLINT,
    total_pages INT,
    book_format CHAR(10),
    purchase_price DECIMAL(5,2),
    is_available BOOLEAN
);

CREATE TABLE digital_downloads
(
    download_id SERIAL PRIMARY KEY,
    user_id     INT,
    catalog_id  INT,
    download_timestamp TIMESTAMP WITH TIME ZONE,
    file_format VARCHAR(10),
    file_size_mb REAL,
    download_completed BOOLEAN,
    expiry_date DATE,
    access_count SMALLINT
);

ALTER TABLE book_catalog
    ADD COLUMN genre VARCHAR(50),
    ADD COLUMN library_section CHAR(3),
    ALTER COLUMN genre SET DEFAULT 'UNKNOWN';

ALTER TABLE digital_downloads
    ADD COLUMN device_type VARCHAR(30),
    ADD COLUMN file_size_mb INT,
    ADD COLUMN last_accessed TIME WITH TIME ZONE
;

CREATE TABLE reading_sessions(
    Session_ID SERIAL PRIMARY KEY,
    User_Reference INT,
    Book_Rrference INT,
    Session_Start TIME WITH TIME ZONE,
    Reading_DUration INTERVAL,
    Pages_Read SMALLINT,
    Session_Active BOOLEAN
);