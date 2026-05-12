-- Attendance tracking table
-- Run once in MySQL/MariaDB

CREATE TABLE IF NOT EXISTS attendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    entry_date DATE NOT NULL,
    in_time TIME,
    out_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_date (user_id, entry_date),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_user_date ON attendance(user_id, entry_date);
CREATE INDEX idx_entry_date ON attendance(entry_date);
