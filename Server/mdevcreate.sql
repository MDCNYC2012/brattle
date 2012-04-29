
DROP TABLE IF EXISTS mdev_state;

CREATE TABLE mdev_state (
	ID mediumint NOT NULL AUTO_INCREMENT PRIMARY KEY,
	state varchar(255) NOT NULL
);

INSERT INTO mdev_state (state) VALUES
('done');


DROP TABLE IF EXISTS mdev_headsets;

CREATE TABLE mdev_headsets (
	ID mediumint NOT NULL AUTO_INCREMENT PRIMARY KEY,
	unique_ID varchar(255) NOT NULL,
	meditation mediumint NOT NULL,
	attention mediumint NOT NULL,
	blink mediumint NOT NULL,
	heartRate mediumint NOT NULL
);





DROP TABLE IF EXISTS mdev_deviceData;

CREATE TABLE mdev_deviceData (
	ID mediumint NOT NULL AUTO_INCREMENT PRIMARY KEY,
	unique_ID varchar(255) NOT NULL,
	color varchar(255) NOT NULL,
	spheroMacro varchar(255) NOT NULL
);


INSERT INTO mdev_deviceData (unique_ID, color, spheroMacro) VALUES
('95786ee5d4ef3eb3', 'red', 'red.sphero'),
('71693b9dfdf402c4', 'green', 'green.sphero');




