-- Add order meta columns to prod_bill (run once)
ALTER TABLE prod_bill
ADD COLUMN description TEXT,
ADD COLUMN delivery_date DATE,
ADD COLUMN is_downloaded INT DEFAULT 0;
