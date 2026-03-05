-- 1. Add the column and set the default to the legacy date.
-- This automatically populates all EXISTING rows with '2025-11-01 00:00:00'.
ALTER TABLE `characters` ADD COLUMN `created_at` DATETIME DEFAULT '2025-11-01 00:00:00';

-- 2. Update the default value to current timestamp.
-- This ensures all NEW characters created from now on get the actual creation time.
ALTER TABLE `characters` MODIFY COLUMN `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP;
