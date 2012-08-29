CREATE OR REPLACE PACKAGE VPI.WASH_ENGINE IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://DataWashroom.codeplex.com
--	Created Date:		2012-08-06
--	Purpose:			DataWashroom (Data Clean-up Engine)

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


PROCEDURE CHECK_ISTR_TYPE
(
	inIstr_ID		VARCHAR2,
	inIstr_Type		VARCHAR2
);


PROCEDURE PRECOMPILE
(
	inCycle_ID		VARCHAR2
);


FUNCTION GEN_PROCEDURE
(
	inCycle_ID		VARCHAR2,
	inGen_Progress	VARCHAR2	:= 'Y',
	inStep_Commit	VARCHAR2	:= 'N'
)	RETURN			CLOB;


END WASH_ENGINE;
/
CREATE OR REPLACE PACKAGE BODY VPI.WASH_ENGINE IS


TYPE String_Array	IS TABLE OF VARCHAR2(64) INDEX BY PLS_INTEGER;


FUNCTION MATCH_COLUMNS
(
	inSrc_View		VARCHAR2,
	inDst_Table		VARCHAR2
)	RETURN			String_Array
IS
	tSrc_Schema		VARCHAR2(9)		:= REGEXP_SUBSTR(inSrc_View, '^[^.]+');
	tSrc_ViewName	VARCHAR2(30)	:= REGEXP_SUBSTR(inSrc_View, '[^.]+$');
	tDest_Schema	VARCHAR2(9)		:= REGEXP_SUBSTR(inDst_Table, '^[^.]+');
	tDest_TabName	VARCHAR2(30)	:= REGEXP_SUBSTR(inDst_Table, '[^.]+$');
	tMtch_Columns	String_Array;
BEGIN
	SELECT
		D.COLUMN_NAME
	BULK COLLECT INTO
		tMtch_Columns
	FROM
		SYS.ALL_TAB_COLUMNS		S,
		SYS.ALL_TAB_COLUMNS		D
	WHERE
			S.COLUMN_NAME	= D.COLUMN_NAME
		AND S.TABLE_NAME	= tSrc_ViewName
		AND S.OWNER			= tSrc_Schema
		AND D.TABLE_NAME	= tDest_TabName
		AND	D.OWNER			= tDest_Schema
	ORDER BY
		D.COLUMN_ID;

	RETURN tMtch_Columns;
END MATCH_COLUMNS;


FUNCTION COLUMN_REF_LIST
(
	inColumns	VARCHAR2
)	RETURN		VARCHAR2
IS
BEGIN
	RETURN REGEXP_REPLACE(UPPER(inColumns), '([^[:space:],]+)', '"\1"');
END COLUMN_REF_LIST;


FUNCTION IS_COLUMN_IN_LIST
(
	inColumn_Name		VARCHAR2,
	inColumn_Ref_List	VARCHAR2
)	RETURN				BOOLEAN
IS
BEGIN
	RETURN (INSTR(inColumn_Ref_List, '"' || UPPER(inColumn_Name) || '"') > 0);
END IS_COLUMN_IN_LIST;


FUNCTION CONCAT_STRING
(
	inSource		VARCHAR2,
	inConnector		VARCHAR2,
	inAppend		VARCHAR2
)	RETURN	VARCHAR2
IS
BEGIN
	IF LENGTH(inSource)	> 0 THEN
		RETURN  inSource || inConnector || inAppend;
	ELSE
		RETURN inAppend;
	END IF;
END CONCAT_STRING;


FUNCTION WHERE_EXPRESSION
(
	inFilter	VARCHAR2
)	RETURN		VARCHAR2
IS
BEGIN
	IF TRIM(inFilter) IS NULL THEN
		RETURN '';
	ELSE
		RETURN ' WHERE ' || inFilter;
	END IF;
END WHERE_EXPRESSION;


PROCEDURE CHECK_ISTR_TYPE
(
	inIstr_ID		VARCHAR2,
	inIstr_Type		VARCHAR2
)	AS
	tIstr_Type		VARCHAR2(16);
BEGIN
	SELECT ISTR_TYPE INTO tIstr_Type FROM VPI.WASH_ISTR WHERE ISTR_ID = inIstr_ID;

	IF tIstr_Type != inIstr_Type THEN
		RAISE_APPLICATION_ERROR(-20011, UTL_LMS.FORMAT_MESSAGE('The ISTR_TYPE "%s" in VPI.WASH_ISTR is mismatched to "%s"', tIstr_Type, inIstr_Type));
	END IF;
END CHECK_ISTR_TYPE;


PROCEDURE ADD_PLAN
(
	inCycle_ID		VARCHAR2,
	inIstr_Order	PLS_INTEGER,
	inPlan_SQL		VARCHAR2,
	inIstr_ID		VARCHAR2,
	inIstr_Brief	VARCHAR2
)	IS
BEGIN
	IF inPlan_SQL IS NOT NULL THEN
		INSERT INTO VPI.WASH_DML_PLAN (CYCLE_ID, ISTR_ORDER, PLAN_SQL, ISTR_ID, ISTR_BRIEF, PLANNED_TIME)
		VALUES (inCycle_ID, inIstr_Order, inPlan_SQL, inIstr_ID, inIstr_Brief, SYSDATE);
	END IF;
END ADD_PLAN;


PROCEDURE PLAN_DELETE
(
	inCycle_ID		VARCHAR2,
	inIstr_Order	PLS_INTEGER,
	inIstr_ID		VARCHAR2,
	inIstr_Type		VARCHAR2,
	inDst_Table		VARCHAR2,
	inDst_Filter	VARCHAR2,
	inDescription	VARCHAR2
)	IS
	tIstr_Brief		VARCHAR2(1024);
BEGIN
	IF inDescription IS NULL THEN
		tIstr_Brief	:= UTL_LMS.FORMAT_MESSAGE('%s from %s', INITCAP(inIstr_Type), inDst_Table);
	ELSE
		tIstr_Brief	:= inDescription;
	END IF;

	ADD_PLAN(inCycle_ID, inIstr_Order,
		'DELETE FROM ' || inDst_Table || WHERE_EXPRESSION(inDst_Filter),
		inIstr_ID, tIstr_Brief);
END PLAN_DELETE;


PROCEDURE PLAN_COPY
(
	inCycle_ID		VARCHAR2,
	inIstr_Order	PLS_INTEGER,
	inIstr_ID		VARCHAR2,
	inIstr_Type		VARCHAR2,
	inSrc_View		VARCHAR2,
	inSrc_Filter	VARCHAR2,
	inDst_Table		VARCHAR2,
	inDescription	VARCHAR2
)	IS
	tMtch_Columns	String_Array := MATCH_COLUMNS(inSrc_View, inDst_Table);
	tSelect_List	VARCHAR2(1024);
	tIstr_Brief		VARCHAR2(1024);
BEGIN
	FOR i IN tMtch_Columns.FIRST .. tMtch_Columns.LAST
	LOOP
		IF tSelect_List IS NULL THEN
			tSelect_List := tMtch_Columns(i);
		ELSE
			tSelect_List := tSelect_List || ', ' || tMtch_Columns(i);
		END IF;
	END LOOP;

	IF tSelect_List IS NOT NULL THEN
		IF inDescription IS NULL THEN
			tIstr_Brief	:= UTL_LMS.FORMAT_MESSAGE('%s from %s to %s', INITCAP(inIstr_Type), inSrc_View, inDst_Table);
		ELSE
			tIstr_Brief	:= inDescription;
		END IF;

		ADD_PLAN(inCycle_ID, inIstr_Order,
			UTL_LMS.FORMAT_MESSAGE('INSERT INTO %s (%s) SELECT %s FROM %s%s', inDst_Table, tSelect_List, tSelect_List, inSrc_View, WHERE_EXPRESSION(inSrc_Filter)),
			inIstr_ID, tIstr_Brief);
	END IF;
END PLAN_COPY;


PROCEDURE PLAN_MERGE
(
	inCycle_ID			VARCHAR2,
	inIstr_Order		PLS_INTEGER,
	inIstr_ID			VARCHAR2,
	inIstr_Type			VARCHAR2,
	inSrc_View			VARCHAR2,
	inSrc_Filter		VARCHAR2,
	inDst_Table			VARCHAR2,
	inJoin_Columns		VARCHAR2,
	inUpdate_Columns	VARCHAR2,
	inInsert_Columns	VARCHAR2,
	inDescription		VARCHAR2
)	IS
	tMtch_Columns	String_Array	:= MATCH_COLUMNS(inSrc_View, inDst_Table);
	tMerge_SQL		VARCHAR2(4000)	:= UTL_LMS.FORMAT_MESSAGE('MERGE INTO %s D
USING ', inDst_Table);
	tIstr_Brief		VARCHAR2(1024);
	tJoin_Cols		VARCHAR2(1024)	:= COLUMN_REF_LIST(inJoin_Columns);
	tJoin_On		VARCHAR2(1024);
	tUpdate_Cols	VARCHAR2(1024)	:= COLUMN_REF_LIST(inUpdate_Columns);
	tUpdate_Set		VARCHAR2(1024);
	tInsert_Cols	VARCHAR2(1024)	:= COLUMN_REF_LIST(inInsert_Columns);
	tInsert_Into	VARCHAR2(1024);
	tInsert_Values	VARCHAR2(1024);
BEGIN
	IF inSrc_Filter IS NULL THEN
		tMerge_SQL	:= tMerge_SQL || UTL_LMS.FORMAT_MESSAGE('%s S', inSrc_View);
	ELSE
		tMerge_SQL	:= tMerge_SQL || UTL_LMS.FORMAT_MESSAGE('(SELECT * FROM %s%s) S', inSrc_View, WHERE_EXPRESSION(inSrc_Filter));
	END IF;

	FOR i IN tMtch_Columns.FIRST .. tMtch_Columns.LAST
	LOOP
		IF IS_COLUMN_IN_LIST(tMtch_Columns(i), tJoin_Cols) THEN
			tJoin_On := CONCAT_STRING(tJoin_On, ' AND ', UTL_LMS.FORMAT_MESSAGE('D.%s = S.%s', tMtch_Columns(i), tMtch_Columns(i)));
		END IF;

		IF (inUpdate_Columns = '*' OR IS_COLUMN_IN_LIST(tMtch_Columns(i), tUpdate_Cols)) AND NOT IS_COLUMN_IN_LIST(tMtch_Columns(i), tJoin_Cols) THEN
			tUpdate_Set := CONCAT_STRING(tUpdate_Set, ',
', UTL_LMS.FORMAT_MESSAGE('	D.%s = S.%s', tMtch_Columns(i), tMtch_Columns(i)));
		END IF;

		IF inInsert_Columns = '*' OR IS_COLUMN_IN_LIST(tMtch_Columns(i), tInsert_Cols) THEN
			tInsert_Into	:= CONCAT_STRING(tInsert_Into, ', ', UTL_LMS.FORMAT_MESSAGE('D.%s', tMtch_Columns(i)));
			tInsert_Values	:= CONCAT_STRING(tInsert_Values, ', ', UTL_LMS.FORMAT_MESSAGE('S.%s', tMtch_Columns(i)));
		END IF;
	END LOOP;

	tMerge_SQL	:= tMerge_SQL || UTL_LMS.FORMAT_MESSAGE('
ON (%s)', tJoin_On);

	IF inUpdate_Columns IS NOT NULL THEN
		tMerge_SQL	:= tMerge_SQL || '
WHEN MATCHED THEN UPDATE SET
' || tUpdate_Set;
	END IF;

	IF inInsert_Columns IS NOT NULL THEN
		tMerge_SQL	:= tMerge_SQL || UTL_LMS.FORMAT_MESSAGE('
WHEN NOT MATCHED THEN
	INSERT (%s)
	VALUES (%s)', tInsert_Into, tInsert_Values);
	END IF;

	IF inDescription IS NULL THEN
		tIstr_Brief	:= UTL_LMS.FORMAT_MESSAGE('%s %s into %s', INITCAP(inIstr_Type), inSrc_View, inDst_Table);
	ELSE
		tIstr_Brief	:= inDescription;
	END IF;

	ADD_PLAN(inCycle_ID, inIstr_Order, tMerge_SQL, inIstr_ID, tIstr_Brief);
END PLAN_MERGE;


PROCEDURE PRECOMPILE
(
	inCycle_ID	VARCHAR2
)	AS
BEGIN
	DELETE FROM VPI.WASH_DML_PLAN WHERE CYCLE_ID = inCycle_ID;

	FOR L IN
	(
		SELECT
			B.CYCLE_ID,
			B.ISTR_ORDER,
			B.ISTR_ID,
			B.ISTR_TYPE,
			D.DST_TABLE,
			D.DST_FILTER,
			B.DESCRIPTION_
		FROM
			VPI.WASH_ISTR_DELETE	D,
			VPI.WASH_ISTR			B
		WHERE
				D.ISTR_ID	= B.ISTR_ID
			AND	B.CYCLE_ID	= inCycle_ID
	)
	LOOP
		PLAN_DELETE(L.CYCLE_ID, L.ISTR_ORDER, L.ISTR_ID, L.ISTR_TYPE, L.DST_TABLE, L.DST_FILTER, L.DESCRIPTION_);
	END LOOP;

	FOR L IN
	(
		SELECT
			B.CYCLE_ID,
			B.ISTR_ORDER,
			B.ISTR_ID,
			B.ISTR_TYPE,
			C.SRC_VIEW,
			C.SRC_FILTER,
			C.DST_TABLE,
			B.DESCRIPTION_
		FROM
			VPI.WASH_ISTR_COPY		C,
			VPI.WASH_ISTR			B
		WHERE
				C.ISTR_ID	= B.ISTR_ID
			AND	B.CYCLE_ID	= inCycle_ID
	)
	LOOP
		PLAN_COPY(L.CYCLE_ID, L.ISTR_ORDER, L.ISTR_ID, L.ISTR_TYPE, L.SRC_VIEW, L.SRC_FILTER, L.DST_TABLE, L.DESCRIPTION_);
	END LOOP;

	FOR L IN
	(
		SELECT
			B.CYCLE_ID,
			B.ISTR_ORDER,
			B.ISTR_ID,
			B.ISTR_TYPE,
			M.SRC_VIEW,
			M.SRC_FILTER,
			M.DST_TABLE,
			M.JOIN_COLUMNS,
			M.UPDATE_COLUMNS,
			M.INSERT_COLUMNS,
			B.DESCRIPTION_
		FROM
			VPI.WASH_ISTR_MERGE		M,
			VPI.WASH_ISTR			B
		WHERE
				M.ISTR_ID	= B.ISTR_ID
			AND	B.CYCLE_ID	= inCycle_ID
	)
	LOOP
		PLAN_MERGE(L.CYCLE_ID, L.ISTR_ORDER, L.ISTR_ID, L.ISTR_TYPE, L.SRC_VIEW, L.SRC_FILTER, L.DST_TABLE, L.JOIN_COLUMNS, L.UPDATE_COLUMNS, L.INSERT_COLUMNS, L.DESCRIPTION_);
	END LOOP;

	COMMIT;
END PRECOMPILE;


FUNCTION GEN_PROCEDURE
(
	inCycle_ID		VARCHAR2,
	inGen_Progress	VARCHAR2	:= 'Y',
	inStep_Commit	VARCHAR2	:= 'N'
)	RETURN			CLOB
IS
	tProcedure		VARCHAR2(61);
	tSp_Name		VARCHAR2(30);
	tProgress		BOOLEAN	:= REGEXP_LIKE(inGen_Progress, '^(Y|Yes|T|True|1)$', 'i');
	tStep_Commit	BOOLEAN	:= REGEXP_LIKE(inStep_Commit, '^(Y|Yes|T|True|1)$', 'i');
	tTotal_Steps	PLS_INTEGER;
	tScript			CLOB	:= 'CREATE OR REPLACE PROCEDURE ';
BEGIN
	SELECT PROCEDURE_NAME INTO tProcedure FROM VPI.WASH_CYCLE WHERE CYCLE_ID = inCycle_ID;

	tSp_Name	:= REGEXP_SUBSTR(tProcedure, '[^.]+$');

	DBMS_LOB.APPEND(tScript, UTL_LMS.FORMAT_MESSAGE('%s
IS
	tProgress_ID	PLS_INTEGER;
BEGIN
	', tProcedure));

	IF tProgress THEN
		SELECT COUNT(*) INTO tTotal_Steps FROM VPI.WASH_DML_PLAN WHERE CYCLE_ID = inCycle_ID;

		DBMS_LOB.APPEND(tScript,  UTL_LMS.FORMAT_MESSAGE('tProgress_ID	:= VPI.PROGRESS_TRACK.REGISTER(%d);
	INSERT INTO VPI.WASH_PROGRESS (PROGRESS_ID, CYCLE_ID, REGISTER_TIME)
	VALUES (tProgress_ID, ''%s'', SYSTIMESTAMP);

	COMMIT;

	', tTotal_Steps + 1, inCycle_ID));
	END IF;

	FOR I IN (SELECT PLAN_SQL, ISTR_ID, ISTR_BRIEF FROM VPI.WASH_DML_PLAN WHERE CYCLE_ID = inCycle_ID ORDER BY ISTR_ORDER, PLANNED_TIME)
	LOOP
		IF tProgress THEN
			DBMS_LOB.APPEND(tScript,  UTL_LMS.FORMAT_MESSAGE('VPI.PROGRESS_TRACK.GO_STEP(tProgress_ID, NULL, ''%s'');
	', I.ISTR_BRIEF));
		END IF;

		DBMS_LOB.APPEND(tScript, REPLACE(I.PLAN_SQL, '
', '
	'));
		DBMS_LOB.APPEND(tScript, ';

	');
		IF tStep_Commit THEN
			DBMS_LOB.APPEND(tScript, 'COMMIT;

	');
		END IF;
	END LOOP;

	DBMS_LOB.APPEND(tScript, 'COMMIT;
');
	IF tProgress THEN
		DBMS_LOB.APPEND(tScript, '
	VPI.PROGRESS_TRACK.GO_STEP(tProgress_ID, NULL, ''Done.'');

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		VPI.PROGRESS_TRACK.ON_ERROR(tProgress_ID, SQLERRM);
');
	END IF;

	DBMS_LOB.APPEND(tScript, UTL_LMS.FORMAT_MESSAGE('END %s;
', tSp_Name));

	RETURN tScript;

EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE(SQLERRM);
		RETURN NULL;
END GEN_PROCEDURE;


END WASH_ENGINE;
/
