CREATE TABLE employee_table(
	employee_id INT AUTO_INCREMENT PRIMARY KEY,
    satisfaction_level FLOAT,
    last_evaluation FLOAT,
    number_project INT,
    avg_monthly_hours INT,
    tenure INT,
    work_accident TINYINT,
    employee_left TINYINT,
    promotion_last_5years TINYINT,
    department VARCHAR(50),
    salary VARCHAR(20)
);