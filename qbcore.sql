CREATE TABLE IF NOT EXISTS `players` (
  `userid` MEDIUMINT UNSIGNED NOT NULL,
  `citizenid` INT NOT NULL AUTO_INCREMENT,
  `charinfo` text DEFAULT NULL,
  `job` text NOT NULL,
  `gang` text DEFAULT NULL,
  `position` text NOT NULL,
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`),
  FOREIGN KEY (`userid`) REFERENCES `users` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `last_updated` (`last_updated`),
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `users` (
  `userid` MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) DEFAULT NULL,
  `license2` VARCHAR(50) DEFAULT NULL,
  `steam` VARCHAR(20) DEFAULT NULL,
  `fivem` VARCHAR(10) DEFAULT NULL,
  `discord` VARCHAR(20) DEFAULT NULL,
  PRIMARY KEY (`userid`)
);
