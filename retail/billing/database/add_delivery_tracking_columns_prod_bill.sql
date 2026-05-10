-- Add delivery tracking columns to prod_bill (run once)
ALTER TABLE prod_bill
ADD COLUMN delivery_place VARCHAR(255) NULL AFTER description,
ADD COLUMN delivery_person VARCHAR(255) NULL AFTER delivery_place,
ADD COLUMN delivered_date DATE NULL AFTER delivery_person;

-- Ensure is_delivered exists as integer flag
ALTER TABLE prod_bill
MODIFY COLUMN is_delivered INT DEFAULT 0;
