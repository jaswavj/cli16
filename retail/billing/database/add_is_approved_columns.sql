-- Adds approval flags for sales report approval flow
-- Run once in MySQL/MariaDB

ALTER TABLE prod_bill
ADD COLUMN is_approved INT NOT NULL DEFAULT 0;

ALTER TABLE prod_bill_due_collection
ADD COLUMN is_approved INT NOT NULL DEFAULT 0;
