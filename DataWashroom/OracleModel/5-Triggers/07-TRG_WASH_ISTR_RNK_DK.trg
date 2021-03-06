CREATE OR REPLACE TRIGGER VPI.TRG_WASH_ISTR_RNK_DK
BEFORE INSERT OR UPDATE ON VPI.WASH_ISTR_RNK_DK
FOR EACH ROW
DECLARE
	tDst_Table	VARCHAR2(61) := UPPER(TRIM(:new.DST_TABLE));
	tTest_SQL	VARCHAR2(2000);
BEGIN
	VPI.WASH_ENGINE.CHECK_ISTR_TYPE(DBMS_UTILITY.FORMAT_CALL_STACK, :new.ISTR_ID);

	IF tDst_Table != :new.DST_TABLE THEN
		:new.DST_TABLE := tDst_Table;
	END IF;

	:new.KEY_COLUMNS	:= UPPER(TRIM(:new.KEY_COLUMNS));
	:new.DST_FILTER		:= TRIM(:new.DST_FILTER);
	:new.ORDER_BY		:= TRIM(:new.ORDER_BY);
	:new.RN_COLUMN		:= UPPER(TRIM(:new.RN_COLUMN));

	tTest_SQL	:= UTL_LMS.FORMAT_MESSAGE('INSERT INTO %s (%s) SELECT %s FROM %s WHERE 1 = 0', tDst_Table, :new.KEY_COLUMNS, :new.KEY_COLUMNS, tDst_Table);

	IF :new.DST_FILTER IS NOT NULL THEN
		tTest_SQL	:= tTest_SQL || UTL_LMS.FORMAT_MESSAGE(' AND (%s)', :new.DST_FILTER);
	END IF;

	EXECUTE IMMEDIATE tTest_SQL;

	EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('SELECT %s FROM %s WHERE %s = 0 ORDER BY %s', :new.RN_COLUMN, tDst_Table, :new.RN_COLUMN, :new.ORDER_BY);
END;
/
