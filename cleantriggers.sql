-- CLEAR ALL TRIGGERS
DROP TRIGGER IF EXISTS before_insert_schedule ON schedule;
DROP TRIGGER IF EXISTS before_insert_loads ON loads;
DROP TRIGGER IF EXISTS before_insert_unloads ON unloads;
DROP TRIGGER IF EXISTS before_insert_transfers on transfers;
DROP TRIGGER IF EXISTS verify_loading_timing on loads;
DROP TRIGGER IF EXISTS verify_unloading_timing on unloads;
