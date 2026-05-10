-- Add download_date column to prod_bill (run once)
ALTER TABLE prod_bill
ADD COLUMN download_date DATE NULL AFTER is_downloaded;
