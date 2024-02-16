CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `cid` int(11) DEFAULT NULL,
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `money` text NOT NULL,
  `charinfo` text DEFAULT NULL,
  `job` text NOT NULL,
  `gang` text DEFAULT NULL,
  `position` text NOT NULL,
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`),
  KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `player_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `groups` (
	`name` VARCHAR(50) NOT NULL,
	`type` VARCHAR(50) NOT NULL,
	`data` LONGTEXT NOT NULL,
	PRIMARY KEY (`name`, `type`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `group_grades` (
	`group` VARCHAR(50) NOT NULL,
	`type` VARCHAR(50) NOT NULL,
	`grade` TINYINT(3) UNSIGNED NOT NULL,
	`data` LONGTEXT NOT NULL,
	PRIMARY KEY (`group`, `grade`, `type`),
	CONSTRAINT `fk_groups` FOREIGN KEY (`group`, `type`) REFERENCES `groups` (`name`, `type`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `player_groups` (
	`citizenid` VARCHAR(50) NOT NULL,
	`group` VARCHAR(50) NOT NULL,
	`type` VARCHAR(50) NOT NULL,
	`grade` TINYINT(3) UNSIGNED NOT NULL,
	PRIMARY KEY (`citizenid`, `type`, `group`),
	CONSTRAINT `fk_citizenid` FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT `fk_grade` FOREIGN KEY (`group`, `type`, `grade`) REFERENCES `group_grades` (`group`, `type`, `grade`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;
