CREATE OR REPLACE PACKAGE VPI.CACHE_UTILITY IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://DataWashroom.codeplex.com
--	Share with			http://view.codeplex.com
--	Created Date:		2012-10-11
--	Purpose:			Global Cache Controller

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


gDefault_Refresh_Timeout	PLS_INTEGER	:= 3600;		-- Default number of seconds to continue trying to get into a critical section.


FUNCTION ENTER_REFRESH_LOCK
(
	inCache_ID		VARCHAR2,
	inWait_Timeout	PLS_INTEGER	:= gDefault_Refresh_Timeout,		-- Seconds
	inForce_Refresh	VARCHAR2	:= 'N'
)	RETURN			PLS_INTEGER;


PROCEDURE EXIT_REFRESH_LOCK
(
	inCache_ID		VARCHAR2
);


PROCEDURE SET_REFRESH_PROGRESS
(
	inCache_ID		VARCHAR2,
	inProgress_ID	PLS_INTEGER
);


FUNCTION ENTER_READ_LOCK
(
	inCache_ID		VARCHAR2,
	inWait_Timeout	PLS_INTEGER	:= gDefault_Refresh_Timeout		-- Seconds
)	RETURN			PLS_INTEGER;


PROCEDURE EXIT_READ_LOCK
(
	inCache_ID		VARCHAR2
);


END CACHE_UTILITY;
/
CREATE OR REPLACE PACKAGE BODY VPI.CACHE_UTILITY IS


--	gRead_Lock_Mode		PLS_INTEGER	:= DBMS_LOCK.S_MODE;
--	gWrite_Lock_Mode	PLS_INTEGER	:= DBMS_LOCK.X_MODE;


FUNCTION GET_LOCK_HANDLE
(
	inCache_ID		VARCHAR2
)	RETURN			VARCHAR2
IS
	tLock_Handle	VARCHAR2(30);
BEGIN
	DBMS_LOCK.ALLOCATE_UNIQUE('CACHE$' || inCache_ID, tLock_Handle);
	RETURN tLock_Handle;
END GET_LOCK_HANDLE;


FUNCTION ENTER_REFRESH_LOCK
(
	inCache_ID		VARCHAR2,
	inWait_Timeout	PLS_INTEGER	:= gDefault_Refresh_Timeout,		-- Seconds
	inForce_Refresh	VARCHAR2	:= 'N'
)	RETURN			PLS_INTEGER
IS
PRAGMA AUTONOMOUS_TRANSACTION;
	tLock_Handle	VARCHAR2(30)	:= GET_LOCK_HANDLE(inCache_ID);
	tForce_Refresh	BOOLEAN			:= NVL(REGEXP_LIKE(inForce_Refresh, '^(Y|Yes|T|True|1)$', 'i'), FALSE);
	tCache_Expiry	DATE;
	tReturn			PLS_INTEGER;
BEGIN
	SELECT
		REFRESH_END + (CACHE_EXPIRY / 1440)
	INTO
		tCache_Expiry
	FROM
		VPI.CACHE_CONTROL
	WHERE
		CACHE_ID = inCache_ID;

	IF tCache_Expiry > SYSDATE AND NOT tForce_Refresh THEN
		RETURN 10;	-- Cached doesn't need to refresh, the data is available for reading.
	ELSE
		-- Cache must be refreshed now.
		tReturn	:= DBMS_LOCK.REQUEST(tLock_Handle, DBMS_LOCK.X_MODE, inWait_Timeout);
		IF tReturn != 0 THEN
			RETURN tReturn;
		END IF;

		-- One of other sessions could refresh just now at the point of boundary.
		UPDATE	VPI.CACHE_CONTROL
		SET		REFRESH_START	= SYSDATE,
				PROGRESS_ID		= NULL,
				REFRESH_END		= NULL
		WHERE
			(
				REFRESH_END + (CACHE_EXPIRY / 1440)	<= SYSDATE
				OR	REFRESH_END	IS NULL
			)
			AND	CACHE_ID	= inCache_ID;

		IF SQL%ROWCOUNT = 1 THEN	-- Obtaining the token to execute refreshing actually.
			COMMIT;
			RETURN 0;				-- Callers must check the return value 0 to refresh the cache.
		ELSE
			ROLLBACK;
			tReturn	:= DBMS_LOCK.RELEASE(tLock_Handle);
			RETURN 10;				-- Other session has just refreshed the cache, the data is available for reading again.
		END IF;
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20100, UTL_LMS.FORMAT_MESSAGE('The inCache_ID ''%s'' has not been registered in VPI.CACHE_CONTROL table.', inCache_ID));
END ENTER_REFRESH_LOCK;


PROCEDURE EXIT_REFRESH_LOCK
(
	inCache_ID		VARCHAR2
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	IF DBMS_LOCK.RELEASE(GET_LOCK_HANDLE(inCache_ID)) = 0 THEN
		UPDATE	VPI.CACHE_CONTROL
		SET		REFRESH_END		= SYSDATE
		WHERE	REFRESH_END		IS NULL
			AND	REFRESH_START	IS NOT NULL
			AND	CACHE_ID		= inCache_ID;

		COMMIT;
	END IF;
END EXIT_REFRESH_LOCK;


PROCEDURE SET_REFRESH_PROGRESS
(
	inCache_ID		VARCHAR2,
	inProgress_ID	PLS_INTEGER
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	UPDATE	VPI.CACHE_CONTROL
	SET		PROGRESS_ID	= inProgress_ID
	WHERE	PROGRESS_ID	IS NULL
		AND	CACHE_ID	= inCache_ID;

	COMMIT;
END SET_REFRESH_PROGRESS;


FUNCTION ENTER_READ_LOCK
(
	inCache_ID		VARCHAR2,
	inWait_Timeout	PLS_INTEGER	:= gDefault_Refresh_Timeout		-- Seconds
)	RETURN			PLS_INTEGER
IS
	tCache_Expiry	DATE;
BEGIN
	SELECT
		REFRESH_END + ((CACHE_EXPIRY + 0.1) / 1440)
	INTO
		tCache_Expiry
	FROM
		VPI.CACHE_CONTROL
	WHERE
		CACHE_ID = inCache_ID;

	IF tCache_Expiry < SYSDATE OR tCache_Expiry IS NULL THEN
		RAISE_APPLICATION_ERROR(-20531, UTL_LMS.FORMAT_MESSAGE('The data of inCache_ID ''%s'' is not ready.', inCache_ID));
	END IF;

	RETURN DBMS_LOCK.REQUEST(GET_LOCK_HANDLE(inCache_ID), DBMS_LOCK.S_MODE, inWait_Timeout);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20100, UTL_LMS.FORMAT_MESSAGE('The inCache_ID ''%s'' has not been registered in VPI.CACHE_CONTROL table.', inCache_ID));
END ENTER_READ_LOCK;


PROCEDURE EXIT_READ_LOCK
(
	inCache_ID		VARCHAR2
)
IS
	tReturn			PLS_INTEGER;
BEGIN
	tReturn	:= DBMS_LOCK.RELEASE(GET_LOCK_HANDLE(inCache_ID));
END EXIT_READ_LOCK;


END CACHE_UTILITY;
/
