SELECT DISTINCT
    emp_no, from_date, to_date
FROM
    t_dept_emp;

----------------------------------------------------
-- new employees by gender each year --
SELECT 
    YEAR(d.from_date) AS calendar_year,
    e.gender,
    COUNT(e.emp_no) AS num_of_emp
FROM
    t_employees e
        JOIN
    t_dept_emp d ON d.emp_no = e.emp_no
GROUP BY calendar_year , e.gender
HAVING calendar_year >= '1990';

----------------------------------------------------
-- compare number manager gender and department from each year --
-- use case statement to determine status of activity --
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , calendar_year;

-- checking join functionality --
SELECT 
    *
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , calendar_year;

----------------------------------------------------

-- Comparing average salary of female/male employees through 2002 respective to department --
SELECT 
    e.gender,
    YEAR(s.from_date) AS calendar_year,
    round(AVG(s.salary),2) AS average_salary,
    d.dept_name
FROM
    t_employees e
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
        JOIN
    t_salaries s ON s.emp_no = e.emp_no
GROUP BY 2, 1, 4
HAVING calendar_year <= '2002'
ORDER BY calendar_year;

----------------------------------------------------

-- Create a stored procedure to call average male/female salary per department filtered by a min/max value --
use employees_mod;
drop procedure if exists filter_salary;

delimiter $$
create procedure filter_salary (in p_min_salary float, in p_max_salary float)
BEGIN
SELECT 
    AVG(s.salary) AS AvgSalary, e.gender, d.dept_name
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
WHERE
    s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no , e.gender;
END$$

delimiter ;

call filter_salary(50000, 90000);





