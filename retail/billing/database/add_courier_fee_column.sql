-- Add courier fee column in bill detail table (run once)
ALTER TABLE prod_bill_details
ADD COLUMN courier_fee DOUBLE DEFAULT 0.000;
