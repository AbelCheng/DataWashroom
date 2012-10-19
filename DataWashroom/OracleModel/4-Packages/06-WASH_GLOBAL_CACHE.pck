CREATE OR REPLACE PACKAGE VPI.WASH_GLOBAL_CACHE IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://DataWashroom.codeplex.com
--	Created Date:		2012-10-18
--	Purpose:			Global DataWashroom Cache

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


PROCEDURE ENTER_LOCK
(
	inCycle_ID		VARCHAR2
);


PROCEDURE EXIT_LOCK
(
	inCycle_ID		VARCHAR2
);


END WASH_GLOBAL_CACHE;
/
CREATE OR REPLACE PACKAGE BODY VPI.WASH_GLOBAL_CACHE IS


PROCEDURE ENTER_LOCK
(
	inCycle_ID		VARCHAR2
)
IS
	tLock_Return	PLS_INTEGER;
	tIs_Refreshing	BOOLEAN;
	tWash_Procedure	VARCHAR2(61);
BEGIN
	tLock_Return	:= VPI.CACHE_UTILITY.ENTER_REFRESH_LOCK(inCycle_ID);
	tIs_Refreshing	:= (tLock_Return = 0 OR tLock_Return = 4);

	IF tLock_Return = 0 THEN	-- Need to refresh
		SELECT PROCEDURE_NAME INTO tWash_Procedure FROM VPI.WASH_CYCLE WHERE CYCLE_ID = inCycle_ID;
		EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('BEGIN %s; END;', tWash_Procedure);
	--	COMMIT;
	END IF;

	IF tIs_Refreshing THEN
		VPI.CACHE_UTILITY.EXIT_REFRESH_LOCK(inCycle_ID);
		tIs_Refreshing	:= FALSE;
	END IF;

	IF tLock_Return = 0 OR tLock_Return = 10 THEN	-- The data is ready for reading
		tLock_Return	:= VPI.CACHE_UTILITY.ENTER_READ_LOCK(inCycle_ID);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF tIs_Refreshing THEN
			VPI.CACHE_UTILITY.EXIT_REFRESH_LOCK(inCycle_ID);
		END IF;
	--	ROLLBACK;
		RAISE;
END ENTER_LOCK;


PROCEDURE EXIT_LOCK
(
	inCycle_ID		VARCHAR2
)
IS
BEGIN
	VPI.CACHE_UTILITY.EXIT_READ_LOCK(inCycle_ID);
END EXIT_LOCK;


END WASH_GLOBAL_CACHE;
/
