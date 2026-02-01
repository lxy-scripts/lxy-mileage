CREATE TABLE IF NOT EXISTS `vehicle_mileage` (
  `plate` varchar(50) NOT NULL,
  `mileage` double DEFAULT 0,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optional: Migrate existing mileage from player_vehicles if you want
-- INSERT IGNORE INTO vehicle_mileage (plate, mileage) SELECT plate, drivingdistance FROM player_vehicles;
