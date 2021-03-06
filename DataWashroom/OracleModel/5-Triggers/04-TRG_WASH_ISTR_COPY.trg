CREATE OR REPLACE TRIGGER VPI.TRG_WASH_ISTR_COPY
BEFORE INSERT OR UPDATE ON VPI.WASH_ISTR_COPY
FOR EACH ROW
DECLARE
	tSrc_View	VARCHAR2(61) := UPPER(TRIM(:new.SRC_VIEW));
	tDst_Table	VARCHAR2(61) := UPPER(TRIM(:new.DST_TABLE));
BEGIN
	VPI.WASH_ENGINE.CHECK_ISTR_TYPE(DBMS_UTILITY.FORMAT_CALL_STACK, :new.ISTR_ID);

	IF tSrc_View != :new.SRC_VIEW THEN
		:new.SRC_VIEW := tSrc_View;
	END IF;

	IF tDst_Table != :new.DST_TABLE THEN
		:new.DST_TABLE := tDst_Table;
	END IF;

	:new.SRC_FILTER	:= TRIM(:new.SRC_FILTER);

	IF :new.SRC_FILTER IS NULL THEN
		EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('SELECT 0 FROM %s WHERE 1 = 0', tSrc_View);
	ELSE
		EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('SELECT 0 FROM %s WHERE (%s) AND 1 = 0', tSrc_View, :new.SRC_FILTER);
	END IF;

	EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('SELECT 0 FROM %s WHERE 1 = 0', tDst_Table);
END;
/
