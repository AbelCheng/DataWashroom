CREATE OR REPLACE PACKAGE VPI.DEPLOY_UTILITY
AUTHID CURRENT_USER IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://DataWashroom.codeplex.com
--	Share with			http://view.codeplex.com
--	Created Date:		2012-09-10
--	Purpose:			Deployment Utilities

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


FUNCTION EXPORT_INSERT_SQL
(
	inTable_Name	VARCHAR2,
	inSrc_Filter	VARCHAR2	:= NULL,
	inOrder_By		VARCHAR2	:= NULL
)	RETURN			CLOB;


END DEPLOY_UTILITY;
/
CREATE OR REPLACE PACKAGE BODY VPI.DEPLOY_UTILITY
IS


FUNCTION CONCAT_STRING
(
	inSource		VARCHAR2,
	inConnector		VARCHAR2,
	inAppend		VARCHAR2
)	RETURN			VARCHAR2
IS
BEGIN
	IF inSource IS NOT NULL THEN
		IF inAppend IS NOT NULL THEN
			RETURN inSource || inConnector || inAppend;
		ELSE
			RETURN inSource;
		END IF;
	ELSE
		RETURN inAppend;
	END IF;
END CONCAT_STRING;


FUNCTION EXPORT_INSERT_SQL
(
	inTable_Name	VARCHAR2,
	inSrc_Filter	VARCHAR2	:= NULL,
	inOrder_By		VARCHAR2	:= NULL
)	RETURN			CLOB
IS
	tFull_Name		VARCHAR2(61)	:= UPPER(TRIM(inTable_Name));
	tSchema			VARCHAR2(30)	:= REGEXP_SUBSTR(tFull_Name, '^[^.]+');
	tTable_Name		VARCHAR2(30)	:= REGEXP_SUBSTR(tFull_Name, '[^.]+$');
	tIns_Col_List	VARCHAR2(2000);
	tSel_Col_List	VARCHAR2(4000);
	tCol_Expr		VARCHAR2(2000);
	tSelect_SQL		VARCHAR2(4000);
	tRC				SYS_REFCURSOR;
	tIns_SQL		VARCHAR2(4000);
	tInsert_SQL		CLOB			:= '
';
BEGIN
	FOR C IN (SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_SET_NAME FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = tTable_Name AND OWNER = tSchema ORDER BY COLUMN_ID)
	LOOP
		tIns_Col_List	:= CONCAT_STRING(tIns_Col_List, ', ', C.COLUMN_NAME);

		IF C.CHARACTER_SET_NAME IS NOT NULL THEN
			tCol_Expr	:= UTL_LMS.FORMAT_MESSAGE('NVL2(%s, '''''''' || REPLACE(REPLACE(%s, '''''''', ''''''''''''), ''&'', '''''' || CHR(38) || '''''') || '''''''', ''NULL'')', C.COLUMN_NAME, C.COLUMN_NAME);
		ELSIF C.DATA_TYPE IN ('NUMBER', 'NUMERIC', 'FLOAT', 'DEC', 'DECIMAL', 'INTEGER', 'INT', 'SMALLINT', 'REAL', 'DOUBLE PRECISION', 'BINARY_FLOAT', 'BINARY_DOUBLE') THEN
			tCol_Expr	:= UTL_LMS.FORMAT_MESSAGE('NVL(TO_CHAR(%s), ''NULL'')', C.COLUMN_NAME);
		ELSE
			tCol_Expr	:= UTL_LMS.FORMAT_MESSAGE('NVL2(%s, '''''''' || TO_CHAR(%s) || '''''''', ''NULL'')', C.COLUMN_NAME, C.COLUMN_NAME);
		END IF;

		tSel_Col_List	:= CONCAT_STRING(tSel_Col_List, ' || '', '' || ', tCol_Expr);
	END LOOP;

	IF tIns_Col_List IS NULL THEN
		RETURN NULL;
	END IF;

	tSelect_SQL	:= UTL_LMS.FORMAT_MESSAGE('SELECT ''INSERT INTO %s (%s) VALUES ('' || %s || '')'' AS INS_SQL FROM %s', tFull_Name, tIns_Col_List, tSel_Col_List, tFull_Name);

	IF TRIM(inSrc_Filter) IS NOT NULL THEN
		tSelect_SQL	:= tSelect_SQL || ' WHERE ' || inSrc_Filter;
	END IF;

	IF TRIM(inOrder_By) IS NOT NULL THEN
		tSelect_SQL	:= tSelect_SQL || ' ORDER BY ' || inOrder_By;
	END IF;

	tIns_SQL	:= RPAD('--', LENGTH(tSelect_SQL) + 3, '-') || '
';
	DBMS_LOB.APPEND(tInsert_SQL, tIns_SQL);
	DBMS_LOB.APPEND(tInsert_SQL, '-- ');
	DBMS_LOB.APPEND(tInsert_SQL, tSelect_SQL);
	DBMS_LOB.APPEND(tInsert_SQL, '
');
	DBMS_LOB.APPEND(tInsert_SQL, tIns_SQL);

	OPEN tRC FOR tSelect_SQL;
	LOOP
		FETCH tRC INTO tIns_SQL;
		EXIT WHEN tRC%NOTFOUND;

		DBMS_LOB.APPEND(tInsert_SQL, tIns_SQL);
		DBMS_LOB.APPEND(tInsert_SQL, ';
');
	END LOOP;
	CLOSE tRC;

	RETURN tInsert_SQL;
END EXPORT_INSERT_SQL;


END DEPLOY_UTILITY;
/
