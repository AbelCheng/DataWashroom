CREATE TABLE VPI.WASH_ISTR_CHK_UK
(
	ISTR_ID					VARCHAR2(32)		NOT NULL,
	DST_TABLE				VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)
	DST_FILTER				VARCHAR2(1024),
	KEY_COLUMNS				VARCHAR2(256)		NOT NULL,
	SET_EXPR_IF_UNIQUE		VARCHAR2(1024),
	SET_EXPR_IF_DUPLICATE	VARCHAR2(1024),

	CONSTRAINT PK_WASH_ISTR_CHK_UK PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_CHK_UK FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_CHK_UK_DT CHECK (INSTR(DST_TABLE, '.') > 0),
	CONSTRAINT CK_WASH_ISTR_CHK_UK_IF CHECK (SET_EXPR_IF_UNIQUE IS NOT NULL OR SET_EXPR_IF_DUPLICATE IS NOT NULL)
);

COMMENT ON TABLE VPI.WASH_ISTR_CHK_UK
	IS 'Check Unique Key ¨C Checks the uniqueness by a supposed business key, and tags it something if a row is unique or tags it something if a row is duplicate.';

COMMENT ON COLUMN VPI.WASH_ISTR_CHK_UK.ISTR_ID
	IS 'The ISTR_ID embodies the inheritance from the base WASH_ISTR.';
COMMENT ON COLUMN VPI.WASH_ISTR_CHK_UK.DST_TABLE
	IS 'Specifies the target table to be checked. Schema name is always required in the table name. (E.g. ABC.TABLE_DST)';
COMMENT ON COLUMN VPI.WASH_ISTR_CHK_UK.DST_FILTER
	IS '(Optional)Specifies the search conditions used to limit the number of rows to be checked (E.g. ID_TYPE = ''ISIN''). If this column is NULL, all the rows from the table will be checked.';
COMMENT ON COLUMN VPI.WASH_ISTR_CHK_UK.KEY_COLUMNS
	IS 'Specifies a column or a list of columns which is supposed to be a unique key. A composite key (includes two or more columns) must be delimited by commas (E.g. DATE_, POS_ID).';
COMMENT ON COLUMN VPI.WASH_ISTR_CHK_UK.SET_EXPR_IF_UNIQUE
	IS 'Specifies a comma-separated list of clause(s) {column_name = expression}[,...n] for tagging a row if its supposed key is unique. For example: IS_QUALIFIED = ''Y'', REDIRECT_CODE = ORIG_CODE.';
COMMENT ON COLUMN VPI.WASH_ISTR_CHK_UK.SET_EXPR_IF_DUPLICATE
	IS 'Specifies a comma-separated list of clause(s) {column_name = expression}[,...n] for tagging a row if its supposed key is duplicate. For example: IS_QUALIFIED = ''N'', REDIRECT_CODE = ''N/A''.';
