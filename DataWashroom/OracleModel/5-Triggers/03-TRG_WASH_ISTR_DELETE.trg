CREATE OR REPLACE TRIGGER VPI.TRG_WASH_ISTR_DELETE
BEFORE INSERT OR UPDATE ON VPI.WASH_ISTR_DELETE
FOR EACH ROW
DECLARE
	tDst_Table	VARCHAR2(61) := UPPER(TRIM(:new.DST_TABLE));
BEGIN
	VPI.WASH_ENGINE.CHECK_ISTR_TYPE(DBMS_UTILITY.FORMAT_CALL_STACK, :new.ISTR_ID);

	IF tDst_Table != :new.DST_TABLE THEN
		:new.DST_TABLE := tDst_Table;
	END IF;

	:new.DST_FILTER	:= TRIM(:new.DST_FILTER);

	IF :new.DST_FILTER IS NULL THEN
		EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('SELECT 0 FROM %s WHERE 1 = 0', tDst_Table);
	ELSE
		EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('SELECT 0 FROM %s WHERE (%s) AND 1 = 0', tDst_Table, :new.DST_FILTER);
	END IF;
END;
/
