CREATE TABLE ships (
	MMSI INT PRIMARY KEY,
	name VARCHAR(100),
	flag VARCHAR(50),
	length DECIMAL(10,2) NOT NULL,
	width DECIMAL(10,2) NOT NULL
);

CREATE TABLE berths (
	berth_id INT PRIMARY KEY
);

CREATE TABLE containers (
	iso_code VARCHAR(50) PRIMARY KEY,
	type VARCHAR(255)
);

CREATE TABLE locations (
	bay INT,
	row INT,
	tier INT,
	PRIMARY KEY (bay, row, tier)
);

CREATE TABLE DateTime (
	datetime_record SERIAL PRIMARY KEY,
	datetime TIMESTAMP NOT NULL
);

CREATE TABLE schedule (
	ship_mmsi INT PRIMARY KEY, 
	berth_id INT PRIMARY KEY,
	arrival_datetime_record INT,
    	departure_datetime_record INT,
	FOREIGN KEY (ship_mmsi) REFERENCES ships(MMSI) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (berth_id) REFERENCES berths(berth_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (arrival_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (departure_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE loads (
    load_id SERIAL PRIMARY KEY,
    container_iso_code VARCHAR(50),
    ship_mmsi INT,  
    berth_id INT,
    loadstart_datetime_record INT,
    loadend_datetime_record INT,
    from_bay INT,
    from_row INT,
    from_tier INT,
    FOREIGN KEY (ship_mmsi) REFERENCES ships(mmsi) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ship_mmsi, berth_id) REFERENCES schedule(ship_mmsi, berth_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (container_iso_code) REFERENCES containers(iso_code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (loadstart_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (loadend_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (from_bay, from_row, from_tier) REFERENCES locations(bay, row, tier) ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE unloads (
    unload_id SERIAL PRIMARY KEY,
    container_iso_code VARCHAR(50),
    ship_mmsi INT,
    berth_id INT,
    unloadstart_datetime_record INT,
    unloadend_datetime_record INT,
    to_bay INT,
    to_row INT,
    to_tier INT,
    FOREIGN KEY (unloadstart_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (unloadend_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ship_mmsi) REFERENCES ships(mmsi) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (container_iso_code) REFERENCES containers(iso_code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_bay, to_row, to_tier) REFERENCES locations(bay, row, tier) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE transfers (
    transfer_id SERIAL PRIMARY KEY,
    container_iso_code VARCHAR(50),
    start_datetime_record INT,
    end_datetime_record INT,
    from_bay INT,
    from_row INT,
    from_tier INT,
    to_bay INT,
    to_row INT,
    to_tier INT,
    FOREIGN KEY (container_iso_code) REFERENCES containers(iso_code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (start_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (end_datetime_record) REFERENCES DateTime(datetime_record) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (from_bay, from_row, from_tier) REFERENCES locations(bay, row, tier) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_bay, to_row, to_tier) REFERENCES locations(bay, row, tier) ON UPDATE CASCADE ON DELETE CASCADE
);