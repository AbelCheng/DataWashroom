CREATE OR REPLACE TRIGGER VPI.TRG_WASH_CYCLE_DEL
AFTER DELETE ON VPI.WASH_CYCLE
FOR EACH ROW
BEGIN
	DELETE FROM VPI.CACHE_CONTROL
	WHERE CACHE_ID	= :old.CYCLE_ID;
END;
/