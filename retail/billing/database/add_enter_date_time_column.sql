-- Add enter_date_time to prod_bill (actual system entry timestamp)
-- Run once on the database

ALTER TABLE prod_bill
ADD COLUMN enter_date_time DATETIME NULL DEFAULT NULL AFTER time;

-- Optional: backfill existing rows using current date + time
UPDATE prod_bill
SET enter_date_time = TIMESTAMP(date, time)
WHERE enter_date_time IS NULL;
