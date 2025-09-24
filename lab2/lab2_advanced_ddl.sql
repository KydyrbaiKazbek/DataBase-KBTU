CREATE DATABASE university_main
    OWNER = "postgres"
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
    CONNECTION LIMIT = 50
    TEMPLATE = template0;

CREATE DATABASE university_test
    IS_TEMPLATE = true
    CONNECTION LIMIT = 10;

CREATE TABLESPACE student_data
    LOCATION '/data/students';

CREATE TABLESPACE course_data
    OWNER postgres
    LOCATION '/data/courses';

CREATE DATABASE university_distributed
    TABLESPACE = student_data;

