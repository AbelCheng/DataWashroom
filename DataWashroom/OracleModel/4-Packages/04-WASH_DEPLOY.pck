CREATE OR REPLACE PACKAGE VPI.WASH_DEPLOY
AUTHID CURRENT_USER IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://DataWashroom.codeplex.com
--	Created Date:		2012-08-29
--	Purpose:			DataWashroom Deployment Utilities

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


FUNCTION DEPLOY_PROCEDURE
(
	inCycle_ID		VARCHAR2,
	inVer_Comment	VARCHAR2	:= '',
	inGen_Progress	VARCHAR2	:= 'Y',
	inStep_Commit	VARCHAR2	:= 'N'
)	RETURN			PLS_INTEGER;


END WASH_DEPLOY;
/
CREATE OR REPLACE PACKAGE BODY VPI.WASH_DEPLOY IS


FUNCTION DEPLOY_PROCEDURE
(
	inCycle_ID		VARCHAR2,
	inVer_Comment	VARCHAR2	:= '',
	inGen_Progress	VARCHAR2	:= 'Y',
	inStep_Commit	VARCHAR2	:= 'N'
)	RETURN			PLS_INTEGER
AS
	tProcedure_Code	CLOB		:= VPI.WASH_ENGINE.GEN_PROCEDURE(inCycle_ID, inGen_Progress, inStep_Commit);
	tProcedure_Name	VARCHAR2(61);
	tVersion		PLS_INTEGER;
	tError_Msg		VARCHAR2(512);
BEGIN
	IF tProcedure_Code IS NULL THEN
		RETURN NULL;
	END IF;

	UPDATE	VPI.WASH_CYCLE
	SET		LATEST_VERSION	= LATEST_VERSION + 1
	WHERE	CYCLE_ID = inCycle_ID
	RETURNING PROCEDURE_NAME, LATEST_VERSION INTO tProcedure_Name, tVersion;

	INSERT INTO VPI.WASH_VERSION (CYCLE_ID, VERSION_, PROCEDURE_NAME, PROCEDURE_SCRIPT, COMMENT_)
	VALUES (inCycle_ID, tVersion, tProcedure_Name, tProcedure_Code, inVer_Comment);

	COMMIT;

	EXECUTE IMMEDIATE tProcedure_Code;

	UPDATE	VPI.WASH_VERSION
	SET		DEPLOY_STATUS	= 1
	WHERE	VERSION_	= tVersion
		AND	CYCLE_ID	= inCycle_ID;

	COMMIT;
	RETURN tVersion;

EXCEPTION
	WHEN OTHERS THEN
		tError_Msg	:= SQLERRM;
		ROLLBACK;

	UPDATE	VPI.WASH_VERSION
	SET		DEPLOY_STATUS	= -1,
			DEPLOY_ERROR	= tError_Msg
	WHERE	VERSION_		= tVersion
		AND	CYCLE_ID		= inCycle_ID;

	COMMIT;
	RETURN tVersion;
END DEPLOY_PROCEDURE;


END WASH_DEPLOY;
/
