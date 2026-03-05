-- Add armor HUD position column to the characters table.
-- Stores the last dragged position as "topPx,leftPx" (e.g. "620px,30px").
-- NULL means "use the default position from config".
ALTER TABLE `characters` ADD COLUMN `armor_hud_pos` TEXT DEFAULT NULL;
