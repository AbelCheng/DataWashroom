CREATE OR REPLACE PACKAGE VPI.PROGRESS_TRACK IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://DataWashroom.codeplex.com
--	Created Date:		2012-08-06
--	Purpose:			Monitor the progress of processing

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


FUNCTION REGISTER
(
	inTotal_Steps		PLS_INTEGER,
	inFirst_Step		PLS_INTEGER	:= 0,
	inFirst_Status		VARCHAR2	:= ''
)	RETURN				PLS_INTEGER;


PROCEDURE GO_STEP
(
	inProgress_ID		PLS_INTEGER,

	inCurrent_Step		PLS_INTEGER	:= NULL,	-- Default: Move forward one step.
	inCurrent_Status	VARCHAR2	:= ''
);


PROCEDURE ON_ERROR
(
	inProgress_ID		PLS_INTEGER,

	inError_Message		VARCHAR2	:= ''
);


PROCEDURE POLLING
(
	inProgress_ID		PLS_INTEGER,

	outTotal_Steps		OUT NUMBER,
	outElapsed_Time		OUT NUMBER,
	outCurrent_Step		OUT NUMBER,
	outCurrent_Status	OUT VARCHAR2
);


END PROGRESS_TRACK;
/
CREATE OR REPLACE PACKAGE BODY VPI.PROGRESS_TRACK IS


FUNCTION REGISTER
(
	inTotal_Steps		PLS_INTEGER,
	inFirst_Step		PLS_INTEGER	:= 0,
	inFirst_Status		VARCHAR2	:= ''
)	RETURN				PLS_INTEGER
IS
PRAGMA AUTONOMOUS_TRANSACTION;
	tProgress_ID		PLS_INTEGER	:= VPI.SEQ_PROGRESS_ID.NEXTVAL;
BEGIN
	INSERT INTO	VPI.PROGRESS_STATUS (PROGRESS_ID, TOTAL_STEPS, CREATED_TIME, LAST_LOG_TIME, CURRENT_STEP, CURRENT_STATUS)
	VALUES	(tProgress_ID, inTotal_Steps, SYSTIMESTAMP, SYSTIMESTAMP, NVL(inFirst_Step, 0), inFirst_Status);

	IF inFirst_Step > 0 THEN
		INSERT INTO VPI.PROGRESS_LOG (PROGRESS_ID, LOG_TIME, CURRENT_STEP, CURRENT_STATUS)
		VALUES	(tProgress_ID, SYSTIMESTAMP, inFirst_Step, inFirst_Status);
	END IF;

	COMMIT;
	RETURN tProgress_ID;
END REGISTER;


PROCEDURE GO_STEP
(
	inProgress_ID		PLS_INTEGER,

	inCurrent_Step		PLS_INTEGER	:= NULL,	-- Default: Move forward one step.
	inCurrent_Status	VARCHAR2	:= ''
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
tCurrent_Step	PLS_INTEGER;
BEGIN
	UPDATE	VPI.PROGRESS_STATUS
	SET
		LAST_LOG_TIME	= SYSTIMESTAMP,
		CURRENT_STEP	= NVL(inCurrent_Step, CURRENT_STEP + 1),
		CURRENT_STATUS	= inCurrent_Status
	WHERE
		PROGRESS_ID		= inProgress_ID
	RETURNING CURRENT_STEP INTO tCurrent_Step;

	INSERT INTO VPI.PROGRESS_LOG (PROGRESS_ID, LOG_TIME, CURRENT_STEP, CURRENT_STATUS)
	VALUES (inProgress_ID, SYSTIMESTAMP, tCurrent_Step, inCurrent_Status);

	COMMIT;
END GO_STEP;


PROCEDURE ON_ERROR
(
	inProgress_ID		PLS_INTEGER,

	inError_Message		VARCHAR2	:= ''
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	UPDATE	VPI.PROGRESS_STATUS
	SET
		LAST_LOG_TIME	= SYSTIMESTAMP,
		ERROR_MESSAGE	= inError_Message
	WHERE
		PROGRESS_ID		= inProgress_ID;

	COMMIT;
END ON_ERROR;


-- This procedure will be called by UI to get current progress, it's outside the running session.
-- So the UI should keep the inProgress_ID locally.
PROCEDURE POLLING
(
	inProgress_ID		PLS_INTEGER,

	outTotal_Steps		OUT NUMBER,
	outElapsed_Time		OUT NUMBER,
	outCurrent_Step		OUT NUMBER,
	outCurrent_Status	OUT VARCHAR2
)
IS
BEGIN
	SELECT
		TOTAL_STEPS, (SYSDATE - CAST(CREATED_TIME AS DATE)) * 86400, CURRENT_STEP, CURRENT_STATUS
	INTO
		outTotal_Steps, outElapsed_Time, outCurrent_Step, outCurrent_Status
	FROM
		VPI.PROGRESS_STATUS
	WHERE
		PROGRESS_ID	= inProgress_ID;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		outTotal_Steps			:= 1;
		outElapsed_Time			:= 0;
		outCurrent_Step			:= 0;
		outCurrent_Status	:= '';
END POLLING;


END PROGRESS_TRACK;
/
