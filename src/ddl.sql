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
    telegram_username TEXT,
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
    up_karma INT DEFAULT 0,
    down_karma INT DEFAULT 0,
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

CREATE TABLE whisper_karma (karma_id INT AUTO_INCREMENT, whisper_id INT, karma_type ENUM('1','-1'), awarder INT, PRIMARY KEY (karma_id, whisper_id), FOREIGN KEY (whisper_id) REFERENCES whispers (id), FOREIGN KEY (awarder) REFERENCES whisperers(id));

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

-- NOT TO BE USED
CREATE PROCEDURE InsertWhisper(
    IN in_primary_wall_id INT,
    IN in_whisperer_id INT,
    IN in_whisper_content TEXT,
    IN in_whisper_wall_insert TEXT
)
BEGIN
    -- Declare and initialize variables for status
    DECLARE whisper_status INT DEFAULT 0;
    DECLARE whisper_wall_status INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred, changes rolled back.';
    END;

    START TRANSACTION;
    
    -- Insert into whispers table
    INSERT INTO whispers (whisperer_id, primary_wall_id, whisper_content)
    VALUES (in_whisperer_id, in_primary_wall_id, in_whisper_content);
    
    -- Update status variables
    SET whisper_status = 1;
    
    -- Execute additional insert statement provided
    SET @query = in_whisper_wall_insert;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Update status variables
    SET whisper_wall_status = 1;
    
    COMMIT;
    
    -- Return status
    SELECT whisper_status, whisper_wall_status;
END

-------------------

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertWhisper`(
    IN in_primary_wall_id INT,
    IN in_whisperer_id INT,
    IN in_whisper_content TEXT
)
BEGIN
    -- Declare and initialize variables for status and last inserted ID
    DECLARE whisper_status INT DEFAULT 0;
    DECLARE last_whisper_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred, changes rolled back.';
    END;

    START TRANSACTION;
    
    -- Insert into whispers table
    INSERT INTO whispers (whisperer_id, primary_wall_id, whisper_content)
    VALUES (in_whisperer_id, in_primary_wall_id, in_whisper_content);
    
    -- Get the last inserted ID
    SET last_whisper_id = LAST_INSERT_ID();
    
    -- Update status variable
    SET whisper_status = 1;
    
    COMMIT;
    
    -- Return status and last inserted ID
    SELECT whisper_status, last_whisper_id AS last_inserted_id;
END;


CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertWhisperWall`(
    IN in_whisper_wall_insert TEXT
)
BEGIN
    -- Declare and initialize variables for status
    DECLARE whisper_wall_status INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred, changes rolled back.';
    END;

    START TRANSACTION;
    
    -- Execute additional insert statement provided
    SET @query = in_whisper_wall_insert;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Update status variables
    SET whisper_wall_status = 1;
    
    COMMIT;
    
    -- Return status
    SELECT whisper_wall_status;
END