-- IV1351 Project Task 1
-- Course layout and teaching load allocation database (PostgreSQL)
--
-- Usage:
--   createdb iv1351
--   psql iv1351 -f create.sql
--   psql iv1351 -f insert.sql

DROP TABLE IF EXISTS allocation, planned_activity, teaching_activity,
    course_instance, study_period, course_layout, course,
    employee_skill, skill, salary_history, employee, department,
    job_title, phone, person, rule_parameter CASCADE;


-- Business rules and formula constants, stored as data instead of in an application
CREATE TABLE rule_parameter (
    rule_parameter_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name              VARCHAR(100) NOT NULL UNIQUE,
    value             DECIMAL(10,3) NOT NULL,
    description       VARCHAR(500)
);


-- People and employees

CREATE TABLE person (
    person_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    personal_number VARCHAR(13) NOT NULL UNIQUE,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    address         VARCHAR(500)
);

CREATE TABLE phone (
    person_id    INT NOT NULL REFERENCES person ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (person_id, phone_number)
);

CREATE TABLE job_title (
    job_title_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_title    VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE department (
    department_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(200) NOT NULL UNIQUE,
    manager_id      INT
);

CREATE TABLE employee (
    employee_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employment_id VARCHAR(20) NOT NULL UNIQUE,
    person_id     INT NOT NULL UNIQUE REFERENCES person,
    department_id INT NOT NULL REFERENCES department,
    job_title_id  INT NOT NULL REFERENCES job_title,
    supervisor_id INT REFERENCES employee ON DELETE SET NULL
);

ALTER TABLE department
    ADD FOREIGN KEY (manager_id) REFERENCES employee ON DELETE SET NULL;

CREATE TABLE salary_history (
    employee_id INT NOT NULL REFERENCES employee ON DELETE CASCADE,
    valid_from  DATE NOT NULL,
    salary      DECIMAL(10,2) NOT NULL CHECK (salary >= 0),
    PRIMARY KEY (employee_id, valid_from)
);

CREATE TABLE skill (
    skill_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employee_skill (
    employee_id INT NOT NULL REFERENCES employee ON DELETE CASCADE,
    skill_id    INT NOT NULL REFERENCES skill ON DELETE CASCADE,
    PRIMARY KEY (employee_id, skill_id)
);


-- Courses

CREATE TABLE course (
    course_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code VARCHAR(10) NOT NULL UNIQUE
);

-- One row per version of a course layout; a new row is added when the layout changes
CREATE TABLE course_layout (
    course_layout_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id        INT NOT NULL REFERENCES course,
    valid_from       DATE NOT NULL,
    course_name      VARCHAR(200) NOT NULL,
    hp               DECIMAL(4,1) NOT NULL CHECK (hp > 0),
    min_students     INT NOT NULL CHECK (min_students >= 0),
    max_students     INT NOT NULL,
    CHECK (max_students >= min_students),
    UNIQUE (course_id, valid_from)
);

CREATE TABLE study_period (
    study_period_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    period_name     VARCHAR(2) NOT NULL UNIQUE
);

CREATE TABLE course_instance (
    course_instance_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    instance_id        VARCHAR(20) NOT NULL UNIQUE,
    course_layout_id   INT NOT NULL REFERENCES course_layout,
    study_period_id    INT NOT NULL REFERENCES study_period,
    study_year         INT NOT NULL CHECK (study_year BETWEEN 2000 AND 2100),
    num_students       INT NOT NULL CHECK (num_students >= 0)
);


-- Teaching activities, planning and allocation

CREATE TABLE teaching_activity (
    teaching_activity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    activity_name        VARCHAR(100) NOT NULL UNIQUE,
    factor               DECIMAL(4,2) NOT NULL CHECK (factor > 0)
);

CREATE TABLE planned_activity (
    course_instance_id   INT NOT NULL REFERENCES course_instance ON DELETE CASCADE,
    teaching_activity_id INT NOT NULL REFERENCES teaching_activity,
    planned_hours        DECIMAL(6,1) NOT NULL CHECK (planned_hours >= 0),
    PRIMARY KEY (course_instance_id, teaching_activity_id)
);

CREATE TABLE allocation (
    employee_id          INT NOT NULL REFERENCES employee ON DELETE CASCADE,
    course_instance_id   INT NOT NULL REFERENCES course_instance ON DELETE CASCADE,
    teaching_activity_id INT NOT NULL REFERENCES teaching_activity,
    allocated_hours      DECIMAL(6,1) NOT NULL CHECK (allocated_hours >= 0),
    PRIMARY KEY (employee_id, course_instance_id, teaching_activity_id)
);
