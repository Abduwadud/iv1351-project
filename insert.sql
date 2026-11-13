-- IV1351 Project Task 1
-- Test data. Run after create.sql:  psql iv1351 -f insert.sql
-- Primary keys are generated, so foreign keys are looked up through natural keys.

BEGIN;

-- Rules and formula constants
INSERT INTO rule_parameter (name, value, description) VALUES
    ('max_instances_per_period', 4,     'Max number of different course instances a teacher may be allocated to in one period'),
    ('exam_hours_base',          32,    'Examination hours = exam_hours_base + exam_hours_per_student * #students'),
    ('exam_hours_per_student',   0.725, 'See exam_hours_base'),
    ('admin_hours_per_hp',       2,     'Admin hours = admin_hours_per_hp * HP + admin_hours_base + admin_hours_per_student * #students'),
    ('admin_hours_base',         28,    'See admin_hours_per_hp'),
    ('admin_hours_per_student',  0.2,   'See admin_hours_per_hp');

INSERT INTO study_period (period_name) VALUES ('P1'), ('P2'), ('P3'), ('P4');

INSERT INTO teaching_activity (activity_name, factor) VALUES
    ('Lecture',        3.60),
    ('Lab',            2.40),
    ('Tutorial',       2.40),
    ('Seminar',        1.80),
    ('Others',         1.00),
    ('Examination',    1.00),
    ('Administration', 1.00);

INSERT INTO job_title (job_title) VALUES
    ('Professor'),
    ('Associate Professor'),
    ('Lecturer'),
    ('PhD Student'),
    ('Teaching Assistant');

INSERT INTO skill (skill_name) VALUES
    ('Databases'),
    ('Discrete Mathematics'),
    ('Operating Systems'),
    ('Embedded Systems'),
    ('Mobile Development'),
    ('Object-Oriented Design'),
    ('Programming');

INSERT INTO department (department_name) VALUES
    ('Computer Science'),
    ('Mathematics'),
    ('Electrical Engineering');


-- People
INSERT INTO person (personal_number, first_name, last_name, address) VALUES
    ('19700312-1234', 'Anna',    'Berg',      'Valhallavägen 10, 114 27 Stockholm'),
    ('19751105-2345', 'Omar',    'Said',      'Kistagången 5, 164 40 Kista'),
    ('19680720-3456', 'Lisa',    'Holm',      'Sveavägen 44, 113 59 Stockholm'),
    ('19820214-4567', 'Erik',    'Lund',      'Drottninggatan 81, 111 60 Stockholm'),
    ('19900930-5678', 'Sara',    'Nilsson',   'Hornsgatan 12, 118 20 Stockholm'),
    ('19790402-6789', 'Johan',   'Ek',        'Odengatan 3, 113 22 Stockholm'),
    ('19850617-7890', 'Maria',   'Svensson',  'Fleminggatan 20, 112 26 Stockholm'),
    ('19920823-8901', 'David',   'Andersson', 'Ringvägen 101, 116 61 Stockholm'),
    ('19950111-9012', 'Elin',    'Karlsson',  'Kungsholmsgatan 7, 112 27 Stockholm'),
    ('19970305-0123', 'Ahmed',   'Hassan',    'Husby allé 2, 164 30 Kista'),
    ('19880909-1357', 'Sofia',   'Larsson',   'Birger Jarlsgatan 50, 114 29 Stockholm'),
    ('19730128-2468', 'Peter',   'Gustafsson','Götgatan 66, 118 26 Stockholm'),
    ('19980714-3579', 'Nora',    'Ali',       'Tensta allé 9, 163 64 Spånga'),
    ('19660503-4680', 'Karin',   'Olsson',    'Lidingövägen 4, 115 25 Stockholm');

INSERT INTO phone (person_id, phone_number)
SELECT p.person_id, v.phone
FROM (VALUES
    ('19700312-1234', '070-1234567'),
    ('19700312-1234', '08-7901000'),
    ('19751105-2345', '073-2345678'),
    ('19680720-3456', '076-3456789'),
    ('19820214-4567', '070-4567890'),
    ('19900930-5678', '072-5678901'),
    ('19790402-6789', '073-6789012'),
    ('19790402-6789', '08-7901000'),
    ('19850617-7890', '070-7890123'),
    ('19920823-8901', '076-8901234'),
    ('19950111-9012', '072-9012345'),
    ('19970305-0123', '073-0123456'),
    ('19880909-1357', '070-1357913'),
    ('19730128-2468', '076-2468024'),
    ('19980714-3579', '072-3579135'),
    ('19660503-4680', '070-4680246')
) AS v(pnr, phone)
JOIN person p ON p.personal_number = v.pnr;


-- Employees (supervisors are set afterwards, since they reference other employees)
INSERT INTO employee (employment_id, person_id, department_id, job_title_id)
SELECT v.emp, p.person_id, d.department_id, j.job_title_id
FROM (VALUES
    ('E1001', '19700312-1234', 'Computer Science',       'Professor'),
    ('E1002', '19751105-2345', 'Computer Science',       'Associate Professor'),
    ('E1003', '19680720-3456', 'Mathematics',            'Professor'),
    ('E1004', '19820214-4567', 'Computer Science',       'Lecturer'),
    ('E1005', '19900930-5678', 'Mathematics',            'Lecturer'),
    ('E1006', '19790402-6789', 'Electrical Engineering', 'Associate Professor'),
    ('E1007', '19850617-7890', 'Electrical Engineering', 'Lecturer'),
    ('E1008', '19920823-8901', 'Computer Science',       'PhD Student'),
    ('E1009', '19950111-9012', 'Mathematics',            'PhD Student'),
    ('E1010', '19970305-0123', 'Computer Science',       'Teaching Assistant'),
    ('E1011', '19880909-1357', 'Computer Science',       'Lecturer'),
    ('E1012', '19730128-2468', 'Electrical Engineering', 'Professor'),
    ('E1013', '19980714-3579', 'Electrical Engineering', 'Teaching Assistant'),
    ('E1014', '19660503-4680', 'Mathematics',            'Associate Professor')
) AS v(emp, pnr, dept, title)
JOIN person     p ON p.personal_number = v.pnr
JOIN department d ON d.department_name = v.dept
JOIN job_title  j ON j.job_title       = v.title;

UPDATE employee e SET supervisor_id = s.employee_id
FROM (VALUES
    ('E1002', 'E1001'), ('E1004', 'E1001'), ('E1008', 'E1002'), ('E1010', 'E1004'), ('E1011', 'E1001'),
    ('E1005', 'E1003'), ('E1009', 'E1005'), ('E1014', 'E1003'),
    ('E1006', 'E1012'), ('E1007', 'E1006'), ('E1013', 'E1007')
) AS v(emp, sup)
JOIN employee s ON s.employment_id = v.sup
WHERE e.employment_id = v.emp;

UPDATE department d SET manager_id = e.employee_id
FROM (VALUES
    ('Computer Science',       'E1001'),
    ('Mathematics',            'E1003'),
    ('Electrical Engineering', 'E1012')
) AS v(dept, emp)
JOIN employee e ON e.employment_id = v.emp
WHERE d.department_name = v.dept;

-- Monthly salaries in SEK; some employees have had a raise
INSERT INTO salary_history (employee_id, valid_from, salary)
SELECT e.employee_id, v.valid_from::DATE, v.salary
FROM (VALUES
    ('E1001', '2024-01-01', 68000), ('E1001', '2025-07-01', 71000),
    ('E1002', '2024-01-01', 58000), ('E1002', '2025-07-01', 60500),
    ('E1003', '2024-01-01', 70000),
    ('E1004', '2024-01-01', 48000), ('E1004', '2026-01-01', 50000),
    ('E1005', '2024-01-01', 47000),
    ('E1006', '2024-01-01', 57000),
    ('E1007', '2024-01-01', 46500), ('E1007', '2025-07-01', 48000),
    ('E1008', '2024-01-01', 34000), ('E1008', '2025-01-01', 35500),
    ('E1009', '2024-01-01', 34000),
    ('E1010', '2024-01-01', 28000),
    ('E1011', '2024-01-01', 49000),
    ('E1012', '2024-01-01', 72000),
    ('E1013', '2024-01-01', 27500),
    ('E1014', '2024-01-01', 59000)
) AS v(emp, valid_from, salary)
JOIN employee e ON e.employment_id = v.emp;

INSERT INTO employee_skill (employee_id, skill_id)
SELECT e.employee_id, s.skill_id
FROM (VALUES
    ('E1001', 'Databases'), ('E1001', 'Object-Oriented Design'),
    ('E1002', 'Operating Systems'), ('E1002', 'Programming'),
    ('E1003', 'Discrete Mathematics'),
    ('E1004', 'Databases'), ('E1004', 'Programming'),
    ('E1005', 'Discrete Mathematics'),
    ('E1006', 'Embedded Systems'),
    ('E1007', 'Embedded Systems'), ('E1007', 'Programming'),
    ('E1008', 'Databases'), ('E1008', 'Operating Systems'),
    ('E1009', 'Discrete Mathematics'),
    ('E1010', 'Programming'), ('E1010', 'Databases'),
    ('E1011', 'Mobile Development'), ('E1011', 'Object-Oriented Design'),
    ('E1012', 'Embedded Systems'),
    ('E1013', 'Embedded Systems'),
    ('E1014', 'Discrete Mathematics')
) AS v(emp, skill)
JOIN employee e ON e.employment_id = v.emp
JOIN skill    s ON s.skill_name    = v.skill;


-- Courses and course layout versions
INSERT INTO course (course_code) VALUES
    ('IV1351'), ('IX1500'), ('ID1206'), ('IS1300'), ('ID2216'), ('IV1350');

-- IV1351 changes from 7.5 to 15 HP from 2026-10-26, so it has two layout versions
INSERT INTO course_layout (course_id, valid_from, course_name, hp, min_students, max_students)
SELECT c.course_id, v.valid_from::DATE, v.name, v.hp, v.min_s, v.max_s
FROM (VALUES
    ('IV1351', '2024-01-01', 'Data Storage Paradigms',          7.5, 50, 250),
    ('IV1351', '2026-10-26', 'Data Storage Paradigms',         15.0, 50, 250),
    ('IX1500', '2024-01-01', 'Discrete Mathematics',            7.5, 50, 150),
    ('ID1206', '2024-01-01', 'Operating Systems',               7.5, 40, 200),
    ('IS1300', '2024-01-01', 'Embedded Systems',                7.5, 20, 120),
    ('ID2216', '2024-01-01', 'Developing Mobile Applications',  7.5, 30, 150),
    ('IV1350', '2024-01-01', 'Object-Oriented Design',          7.5, 50, 300)
) AS v(code, valid_from, name, hp, min_s, max_s)
JOIN course c ON c.course_code = v.code;

-- Each instance references the layout version that was valid when it started
INSERT INTO course_instance (instance_id, course_layout_id, study_period_id, study_year, num_students)
SELECT v.inst, cl.course_layout_id, sp.study_period_id, v.yr, v.students
FROM (VALUES
    ('2025-50273', 'IV1351', '2024-01-01', 'P2', 2025, 200),
    ('2025-50413', 'IX1500', '2024-01-01', 'P1', 2025, 150),
    ('2025-50110', 'ID1206', '2024-01-01', 'P2', 2025, 120),
    ('2025-50201', 'IS1300', '2024-01-01', 'P1', 2025,  90),
    ('2026-10783', 'IV1351', '2024-01-01', 'P1', 2026, 180),
    ('2026-10790', 'IV1351', '2026-10-26', 'P2', 2026, 160),
    ('2026-10784', 'IX1500', '2024-01-01', 'P1', 2026, 140),
    ('2026-10750', 'ID1206', '2024-01-01', 'P2', 2026, 130),
    ('2026-10830', 'IS1300', '2024-01-01', 'P2', 2026,  95),
    ('2026-10812', 'ID2216', '2024-01-01', 'P2', 2026, 110),
    ('2026-60104', 'IV1350', '2024-01-01', 'P3', 2026, 210)
) AS v(inst, code, layout_from, period, yr, students)
JOIN course        c  ON c.course_code = v.code
JOIN course_layout cl ON cl.course_id = c.course_id AND cl.valid_from = v.layout_from::DATE
JOIN study_period  sp ON sp.period_name = v.period;


-- Planned hours per activity (examination and administration hours are derived, not stored)
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours)
SELECT ci.course_instance_id, ta.teaching_activity_id, v.hours
FROM (VALUES
    ('2025-50273', 'Lecture', 20), ('2025-50273', 'Tutorial', 80), ('2025-50273', 'Lab', 40),
    ('2025-50273', 'Seminar', 80), ('2025-50273', 'Others', 650),
    ('2025-50413', 'Lecture', 44), ('2025-50413', 'Seminar', 64), ('2025-50413', 'Others', 200),
    ('2025-50110', 'Lecture', 30), ('2025-50110', 'Lab', 48), ('2025-50110', 'Others', 120),
    ('2025-50201', 'Lecture', 24), ('2025-50201', 'Lab', 60), ('2025-50201', 'Others', 100),
    ('2026-10783', 'Lecture', 20), ('2026-10783', 'Tutorial', 72), ('2026-10783', 'Lab', 40),
    ('2026-10783', 'Seminar', 72), ('2026-10783', 'Others', 600),
    ('2026-10790', 'Lecture', 36), ('2026-10790', 'Tutorial', 96), ('2026-10790', 'Lab', 64),
    ('2026-10790', 'Seminar', 96), ('2026-10790', 'Others', 900),
    ('2026-10784', 'Lecture', 44), ('2026-10784', 'Seminar', 60), ('2026-10784', 'Others', 180),
    ('2026-10750', 'Lecture', 32), ('2026-10750', 'Lab', 50), ('2026-10750', 'Seminar', 20), ('2026-10750', 'Others', 130),
    ('2026-10830', 'Lecture', 24), ('2026-10830', 'Lab', 64), ('2026-10830', 'Others', 90),
    ('2026-10812', 'Lecture', 28), ('2026-10812', 'Tutorial', 40), ('2026-10812', 'Others', 110),
    ('2026-60104', 'Lecture', 30), ('2026-60104', 'Tutorial', 60), ('2026-60104', 'Seminar', 40), ('2026-60104', 'Others', 220)
) AS v(inst, activity, hours)
JOIN course_instance   ci ON ci.instance_id   = v.inst
JOIN teaching_activity ta ON ta.activity_name = v.activity;


-- Which teacher does which activity in which course instance
INSERT INTO allocation (employee_id, course_instance_id, teaching_activity_id, allocated_hours)
SELECT e.employee_id, ci.course_instance_id, ta.teaching_activity_id, v.hours
FROM (VALUES
    -- IV1351 2025 P2
    ('E1001', '2025-50273', 'Lecture', 20), ('E1001', '2025-50273', 'Examination', 100),
    ('E1004', '2025-50273', 'Tutorial', 40), ('E1004', '2025-50273', 'Administration', 83),
    ('E1008', '2025-50273', 'Lab', 40), ('E1008', '2025-50273', 'Seminar', 40),
    ('E1010', '2025-50273', 'Tutorial', 40), ('E1010', '2025-50273', 'Seminar', 40),
    ('E1010', '2025-50273', 'Examination', 77),
    -- IX1500 2025 P1
    ('E1003', '2025-50413', 'Lecture', 44), ('E1003', '2025-50413', 'Administration', 73),
    ('E1005', '2025-50413', 'Seminar', 64), ('E1009', '2025-50413', 'Examination', 141),
    -- ID1206 2025 P2
    ('E1002', '2025-50110', 'Lecture', 30), ('E1002', '2025-50110', 'Administration', 67),
    ('E1008', '2025-50110', 'Lab', 48), ('E1008', '2025-50110', 'Examination', 119),
    -- IS1300 2025 P1
    ('E1006', '2025-50201', 'Lecture', 24), ('E1007', '2025-50201', 'Lab', 60),
    ('E1006', '2025-50201', 'Examination', 97),
    -- IV1351 2026 P1
    ('E1001', '2026-10783', 'Lecture', 20), ('E1004', '2026-10783', 'Tutorial', 72),
    ('E1008', '2026-10783', 'Lab', 40), ('E1010', '2026-10783', 'Seminar', 72),
    ('E1001', '2026-10783', 'Administration', 79), ('E1004', '2026-10783', 'Examination', 163),
    -- IV1351 2026 P2
    ('E1001', '2026-10790', 'Lecture', 36), ('E1011', '2026-10790', 'Tutorial', 48),
    ('E1010', '2026-10790', 'Tutorial', 48), ('E1008', '2026-10790', 'Lab', 64),
    ('E1004', '2026-10790', 'Seminar', 96), ('E1001', '2026-10790', 'Examination', 148),
    -- IX1500 2026 P1
    ('E1014', '2026-10784', 'Lecture', 44), ('E1005', '2026-10784', 'Seminar', 60),
    ('E1009', '2026-10784', 'Examination', 134), ('E1003', '2026-10784', 'Administration', 71),
    -- ID1206 2026 P2
    ('E1002', '2026-10750', 'Lecture', 32), ('E1008', '2026-10750', 'Lab', 50),
    ('E1002', '2026-10750', 'Seminar', 20), ('E1002', '2026-10750', 'Examination', 126),
    -- IS1300 2026 P2
    ('E1012', '2026-10830', 'Lecture', 24), ('E1007', '2026-10830', 'Lab', 32),
    ('E1013', '2026-10830', 'Lab', 32), ('E1006', '2026-10830', 'Examination', 101),
    -- ID2216 2026 P2
    ('E1011', '2026-10812', 'Lecture', 28), ('E1010', '2026-10812', 'Tutorial', 40),
    ('E1011', '2026-10812', 'Examination', 112),
    -- IV1350 2026 P3
    ('E1001', '2026-60104', 'Lecture', 30), ('E1011', '2026-60104', 'Tutorial', 60),
    ('E1004', '2026-60104', 'Seminar', 40), ('E1004', '2026-60104', 'Examination', 184)
) AS v(emp, inst, activity, hours)
JOIN employee          e  ON e.employment_id  = v.emp
JOIN course_instance   ci ON ci.instance_id   = v.inst
JOIN teaching_activity ta ON ta.activity_name = v.activity;

COMMIT;
