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
	inCycle_ID		VARCHAR2,
	inWait_Timeout	PLS_INTEGER	:= VPI.CACHE_UTILITY.gDefault_Refresh_Timeout		-- Seconds
);


PROCEDURE EXIT_LOCK
(
	inCycle_ID		VARCHAR2
);


PROCEDURE ENTER_LOCK
(
	inCycle_IDs		VCH_ID_ARY,
	inWait_Timeout	PLS_INTEGER	:= VPI.CACHE_UTILITY.gDefault_Refresh_Timeout		-- Seconds
);


PROCEDURE EXIT_LOCK
(
	inCycle_IDs		VCH_ID_ARY
);


END WASH_GLOBAL_CACHE;
/
CREATE OR REPLACE PACKAGE BODY VPI.WASH_GLOBAL_CACHE IS


gIn_Locking	PLS_INTEGER	:= 0;


PROCEDURE ENTER_LOCK
(
	inCycle_ID		VARCHAR2,
	inWait_Timeout	PLS_INTEGER		-- Seconds
)
IS
	tLock_Return	PLS_INTEGER;
	tIs_Refreshing	BOOLEAN;
	tWash_Procedure	VARCHAR2(61);
BEGIN
	IF gIn_Locking = 1 OR gIn_Locking = 3 THEN
		RAISE_APPLICATION_ERROR(-20210, 'At least one cache has been locked in the same session already, please release it before enter the new lock.');
	ELSIF gIn_Locking = 0 THEN
		gIn_Locking	:= 1;
	ELSIF gIn_Locking = 2 THEN
		gIn_Locking	:= 3;
	END IF;

	tLock_Return	:= VPI.CACHE_UTILITY.ENTER_REFRESH_LOCK(inCycle_ID, inWait_Timeout);
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
		tLock_Return	:= VPI.CACHE_UTILITY.ENTER_READ_LOCK(inCycle_ID, inWait_Timeout);
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

	IF gIn_Locking = 1 THEN
		gIn_Locking	:= 0;
	END IF;
END EXIT_LOCK;


PROCEDURE ENTER_LOCK
(
	inCycle_IDs		VCH_ID_ARY,
	inWait_Timeout	PLS_INTEGER		-- Seconds
)
IS
	tLock_IDs		VCH_ID_ARY;
BEGIN
	IF gIn_Locking <> 0 THEN
		RAISE_APPLICATION_ERROR(-20210, 'At least one cache has been locked in the same session already, please release it before enter the new lock.');
	END IF;

	SELECT		C.CACHE_ID BULK COLLECT INTO tLock_IDs
	FROM		VPI.CACHE_CONTROL														C,
				(SELECT DISTINCT COLUMN_VALUE AS CYCLE_ID FROM TABLE(inCycle_IDs))		L
	WHERE		C.CACHE_ID	= L.CYCLE_ID
	ORDER BY	C.LOCK_ORDINAL;

	FOR i IN tLock_IDs.FIRST .. tLock_IDs.LAST
	LOOP
		gIn_Locking	:= 2;
		ENTER_LOCK(tLock_IDs(i), inWait_Timeout);
	END LOOP;

END ENTER_LOCK;


PROCEDURE EXIT_LOCK
(
	inCycle_IDs		VCH_ID_ARY
)
IS
	tLock_IDs		VCH_ID_ARY;
BEGIN
	SELECT		C.CACHE_ID BULK COLLECT INTO tLock_IDs
	FROM		VPI.CACHE_CONTROL														C,
				(SELECT DISTINCT COLUMN_VALUE AS CYCLE_ID FROM TABLE(inCycle_IDs))		L
	WHERE		C.CACHE_ID	= L.CYCLE_ID
	ORDER BY	C.LOCK_ORDINAL DESC;

	FOR i IN tLock_IDs.FIRST .. tLock_IDs.LAST
	LOOP
		EXIT_LOCK(tLock_IDs(i));
	END LOOP;

	gIn_Locking	:= 0;
END EXIT_LOCK;


END WASH_GLOBAL_CACHE;
/
