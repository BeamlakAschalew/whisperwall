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
    status ENUM('0', '1', '2') DEFAULT '0',
    up_karma INT DEFAULT 0,
    down_karma INT DEFAULT 0,
    acceptance DECIMAL(3, 2)
);

CREATE TABLE walls (
    id INT PRIMARY KEY AUTO_INCREMENT,
    wall_name VARCHAR(50),
    wall_color VARCHAR(50)
);

CREATE TABLE whispers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    whisperer_id INT,
    in_reference INT,
    primary_wall_id INT,
    whisper_content TEXT,
    whispered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    up_karma INT DEFAULT 0,
    down_karma INT DEFAULT 0,
    FOREIGN KEY (whisperer_id) REFERENCES whisperers(id) ON DELETE CASCADE,
    FOREIGN KEY (primary_wall_id) REFERENCES walls(id) ON DELETE CASCADE,
    FOREIGN KEY (in_reference) REFERENCES whispers(id) ON DELETE SET NULL
);

CREATE TABLE whisper_walls (id INT PRIMARY KEY AUTO_INCREMENT, 
    whisper_id INT, 
    wall_id INT, 
    FOREIGN KEY (whisper_id) REFERENCES whispers(id) ON DELETE CASCADE, 
    FOREIGN KEY (wall_id) REFERENCES walls(id) ON DELETE CASCADE
); 

CREATE TABLE whisper_comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    commentor_id INT,
    in_reference INT,
    comment TEXT,
    whisper_id INT,
    comment_time TIMESTAMP,
    FOREIGN KEY (commentor_id) REFERENCES whisperers(id) ON DELETE CASCADE,
    FOREIGN KEY (whisper_id) REFERENCES whispers(id) ON DELETE CASCADE,
    FOREIGN KEY (in_reference) REFERENCES whispers(id) ON DELETE SET NULL
);

CREATE TABLE whisper_karma (
    karma_id INT AUTO_INCREMENT, 
    whisper_id INT, 
    karma_type ENUM('1','-1'), 
    awarder INT, PRIMARY KEY (karma_id, whisper_id),
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (whisper_id) REFERENCES whispers(id) ON DELETE CASCADE, 
    FOREIGN KEY (awarder) REFERENCES whisperers(id) ON DELETE CASCADE
);

CREATE TABLE comment_karma (
    karma_id INT AUTO_INCREMENT,
    comment_id INT,
    karma_type ENUM('1','-1'), 
    awarder INT, PRIMARY KEY (karma_id, comment_id),
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (comment_id) REFERENCES whisper_comments(id) ON DELETE CASCADE, 
    FOREIGN KEY (awarder) REFERENCES whisperers(id) ON DELETE CASCADE
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred while posting whisper';
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
END


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


-- dbdiagram.io code:

-- // Use DBML to define your database structure
-- // Docs: https://dbml.dbdiagram.io/docs

-- Table whisperers {
--   id integer [primary key]
--   full_name varchar
--   username varchar
--   password varchar
--   bio varchar
--   dob date
--   created_at timestamp
--   email varchar
--   gender enum
--   status enum
--   telegram_username varchar
--   up_karma int
--   down_karma integer
--   acceptance double
-- }

-- Table walls {
--   id integer [primary key]
--   wall_name varchar
--   wall_color varchar
-- }

-- Table whispers {
--   id integer [primary key]
--   whisperer_id integer
--   primary_wall_id integer
--   whisper_content text
--   whispered_at timestamp
--   up_karma integer
--   down_karma integer
--   comment_count integer
-- }

-- Table whisper_walls {
--   id integer [primary key]
--   whisper_id integer
--   wall_id int 
-- }

-- Table whisper_comments {
--   id integer [primary key]
--   commentor_id integer
--   comment text
--   whisper_id integer
--   comment_time timestamp
-- }

-- Table whisper_karma {
--   karma_id integer [primary key]
--   whisper_id integer
--   karma_type enum
--   awarder integer
--   awarded_at timestamp
-- }

-- Table comment_karma {
--   karma_id integer [primary key]
--   comment_id integer
--   karma_type enum
--   awarder integer
--   awarder_at timestamp
-- }

-- Ref: whisperers.id < whispers.id
-- Ref: whispers.primary_wall_id < walls.id
-- Ref: whisper_walls.wall_id > walls.id
-- Ref: whisper_comments.whisper_id < whispers.id
-- Ref: whispers.id < whisper_walls.whisper_id
-- Ref: whisper_comments.commentor_id > whisperers.id
-- Ref: whisper_karma.whisper_id > whispers.id
-- Ref: whisper_karma.awarder > whisperers.id
-- Ref: comment_karma.comment_id > whisper_comments.id
-- Ref: comment_karma.awarder > whisperers.id
