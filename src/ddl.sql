CREATE DATABASE whispherwall;
USE whispherwall;

CREATE TABLE whisperers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(60) NOT NULL,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(255),
    bio VARCHAR(255),
    dob DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    email VARCHAR(200) NOT NULL,
    gender ENUM('m', 'f', 'u') DEFAULT 'u',
    status ENUM('0', '1', '2') DEFAULT '0'
);

CREATE TABLE walls (
    id INT PRIMARY KEY AUTO_INCREMENT,
    wall_name VARCHAR(50),
    wall_color VARCHAR(50)
);

CREATE TABLE whispers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    whisperer_id INT,
    primary_wall_id INT,
    whisper_content TEXT,
    whispered_at TIMESTAMP,
    FOREIGN KEY (whisperer_id) REFERENCES whisperers(id),
    FOREIGN KEY (primary_wall_id) REFERENCES walls(id)
);

CREATE TABLE whisper_walls (
    whisper_id INT,
    wall_id INT,
    PRIMARY KEY (whisper_id, wall_id),
    FOREIGN KEY (whisper_id) REFERENCES whispers(id),
    FOREIGN KEY (wall_id) REFERENCES walls(id)
);

CREATE TABLE whisper_comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    commentor_id INT,
    comment TEXT,
    whisper_id INT,
    comment_time TIMESTAMP,
    FOREIGN KEY (commentor_id) REFERENCES users(id),
    FOREIGN KEY (whisper_id) REFERENCES whispers(id)
);

CREATE PROCEDURE SignupUser (
    IN p_full_name VARCHAR(60),
    IN p_username VARCHAR(30),
    IN p_email VARCHAR(200),
    IN p_gender ENUM('m', 'f', 'u'),
    IN p_dob VARCHAR(255),
    IN p_bio VARCHAR(255),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE username_count INT;
    SELECT COUNT(*) INTO username_count FROM whisperers WHERE username = p_username;
	IF username_count > 0 THEN
		SELECT 3001 AS status;
	ELSE
		INSERT INTO whisperers (full_name, username, email, gender, dob, bio, password) VALUES (p_full_name, p_username, p_email, p_gender, p_dob, p_bio, (SELECT SHA2(p_password, 256)));
		SELECT 1001 AS status;
	END IF;
END

CREATE PROCEDURE GetUserByUsername(IN p_username VARCHAR(30))
BEGIN
    DECLARE v_username VARCHAR(30);
    DECLARE v_password VARCHAR(255);

    SELECT username, password
    INTO v_username, v_password
    FROM whisperers
    WHERE username = p_username;
    
    IF v_username = NULL THEN
		SELECT 3003 AS status;
	ELSE
		SELECT v_username AS username, v_password AS password;
	END IF;
END;


CREATE PROCEDURE LoginUser(IN p_username VARCHAR(30), IN p_password VARCHAR(255))
BEGIN

    DECLARE logged_in_user_count INT; 

    IF username_count < 1 THEN
        SELECT 3003 AS status;
    ELSE
        SELECT COUNT(*) INTO logged_in_user_count FROM whisperers WHERE password = (SELECT SHA2(p_password, 256));

        IF logged_in_user_count < 1 THEN
            SELECT 3004 AS status;
        ELSE
            SELECT 3005 AS status;
        END IF;
    END IF;

END