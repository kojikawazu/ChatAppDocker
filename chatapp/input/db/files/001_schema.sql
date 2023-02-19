USE chat_database;

CREATE TABLE chat_user
(
   id INTEGER NOT NULL AUTO_INCREMENT,
   name VARCHAR(20) NOT NULL,
   email VARCHAR(20) NOT NULL,
   passwd VARCHAR(20) NOT NULL,
   forgot_passwd VARCHAR(20) NOT NULL,
   created TIMESTAMP NOT NULL,
   updated TIMESTAMP NOT NULL,
   PRIMARY KEY(id)
);

CREATE TABLE chat_room
(
   id INTEGER NOT NULL AUTO_INCREMENT,
   name VARCHAR(20) NOT NULL,
   comment VARCHAR(50) NOT NULL,
   tag VARCHAR(20) NOT NULL,
   max_roomsum INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   created TIMESTAMP NOT NULL,
   updated TIMESTAMP NOT NULL,
   PRIMARY KEY(id)
);

CREATE TABLE chat_comment
(
   id INTEGER NOT NULL AUTO_INCREMENT,
   comment VARCHAR(50) NOT NULL,
   room_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   created TIMESTAMP NOT NULL,
   PRIMARY KEY(id)
);

CREATE TABLE chat_login
(
   id INTEGER NOT NULL AUTO_INCREMENT,
   room_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   created TIMESTAMP NOT NULL,
   updated TIMESTAMP NOT NULL,
   PRIMARY KEY(id)
);

CREATE TABLE chat_enter
(
   id INTEGER NOT NULL AUTO_INCREMENT,
   room_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   manager_id INTEGER NOT NULL,
   created TIMESTAMP NOT NULL,
   PRIMARY KEY(id)
);