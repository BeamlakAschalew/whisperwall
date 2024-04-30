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

