CREATE TABLE sys.patient (
 patient_id INT auto_increment NOT NULL,
 username varchar(100) NOT NULL,
 phone_number varchar(100) NOT NULL,
 password varchar(100) NOT NULL,
 email varchar(100),
 CONSTRAINT NewTable_PK PRIMARY KEY (patient_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;