CREATE OR REPLACE FUNCTION timeline_check() -- Trigger function to ensure chronology is respected
RETURNS TRIGGER AS $$
DECLARE 
    boolean_var BOOLEAN;
BEGIN
    EXECUTE format('SELECT $1.%I >= $1.%I', TG_ARGV[0], TG_ARGV[1]) INTO boolean_var USING NEW;
    IF boolean_var THEN 
        RAISE unique_violation USING MESSAGE = 'The start datetime must occur before the end datetime.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION load_within_berth_timing()
RETURNS TRIGGER AS $$
DECLARE
    berth_arrival TIMESTAMP;
    berth_departure TIMESTAMP;
BEGIN
    -- Get the arrival and departure times of the ship from the Schedule table
    SELECT actual_arrival, actual_departure INTO berth_arrival, berth_departure
    FROM schedule
    WHERE ship_mmsi = NEW.ship_mmsi AND berth_id = NEW.berth_id;

    -- Check if the loading times are within the berth times
    IF NEW.actual_loadstart < berth_arrival OR NEW.actual_loadend > berth_departure THEN
        RAISE EXCEPTION 'The loading times must be within the time the ship is at the berth.';
    END IF; 

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unload_within_berth_timing()
RETURNS TRIGGER AS $$
DECLARE
    berth_arrival TIMESTAMP;
    berth_departure TIMESTAMP;
BEGIN
    -- Get the arrival and departure times of the ship from the Schedule table
    SELECT actual_arrival, actual_departure INTO berth_arrival, berth_departure
    FROM schedule
    WHERE ship_mmsi = NEW.ship_mmsi AND berth_id = NEW.berth_id;

    -- Check if the unloading times are within the berth times
    IF NEW.actual_unloadstart < berth_arrival OR NEW.actual_unloadend > berth_departure THEN
        RAISE EXCEPTION 'The unloading times must be within the time the ship is at the berth.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER before_insert_schedule
BEFORE INSERT ON schedule
FOR EACH ROW
EXECUTE FUNCTION timeline_check('actual_arrival', 'actual_departure');

CREATE OR REPLACE TRIGGER before_insert_loads
BEFORE INSERT ON loads
FOR EACH ROW
EXECUTE FUNCTION timeline_check('actual_loadstart', 'actual_loadend');

CREATE OR REPLACE TRIGGER before_insert_unloads
BEFORE INSERT ON unloads
FOR EACH ROW
EXECUTE FUNCTION timeline_check('actual_unloadstart', 'actual_unloadend');

CREATE OR REPLACE TRIGGER before_insert_transfers
BEFORE INSERT ON transfers
FOR EACH ROW
EXECUTE FUNCTION timeline_check('actual_trfstart', 'actual_trfend');

CREATE TRIGGER verify_loading_timing
BEFORE INSERT OR UPDATE ON loads
FOR EACH ROW
EXECUTE FUNCTION load_within_berth_timing();

CREATE TRIGGER verify_unloading_timing
BEFORE INSERT OR UPDATE ON unloads
FOR EACH ROW
EXECUTE FUNCTION unload_within_berth_timing();

-- TESTS

-- violate timeline_check()
INSERT INTO schedule (ship_mmsi, berth_id, expected_arrival, expected_departure, actual_arrival, actual_departure) VALUES (649063139, 1, '2024-02-06 08:30:00', '2024-02-06 09:30:00', '2024-02-06 10:35:00', '2024-02-06 09:35:00');

-- violate load_within_berth_timing()
INSERT INTO loads (container_iso_code, ship_mmsi, berth_id, expected_loadstart, expected_loadend, actual_loadstart, actual_loadend, from_bay, from_row, from_tier) VALUES ('JZPU3300477', 376733686, 10, '2024-02-06 08:55:00', '2024-02-06 09:10:00', '2024-02-06 08:30:00', '2024-02-06 09:05:00', 1, 21, 3);

-- violate unload_within_berth_timing()
INSERT INTO unloads (container_iso_code, ship_mmsi, berth_id, expected_unloadstart, expected_unloadend, actual_unloadstart, actual_unloadend, to_bay, to_row, to_tier) VALUES ('ZWVZ2591758', 376733686, 10, '2024-02-06 11:50:00', '2024-02-06 12:00:00', '2024-02-06 11:55:00', '2024-02-06 12:05:00', 7, 9, 1);


