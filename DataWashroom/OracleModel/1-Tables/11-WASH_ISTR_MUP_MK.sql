CREATE TABLE VPI.WASH_ISTR_MUP_MK
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	SRC_VIEW		VARCHAR2(61)		NOT NULL,	-- Source View (must include schema.view/table)
	SRC_FILTER		VARCHAR2(1024),
	SRC_KEY_COLUMNS	VARCHAR2(256)		NOT NULL,
	DST_TABLE		VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)
	DST_KEY_COLUMNS	VARCHAR2(256)		NOT NULL,
	DST_VAL_COLUMNS	VARCHAR2(512),
	SRC_VALUES		VARCHAR2(512),

	CONSTRAINT PK_WASH_ISTR_MUP_MK PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_MUP_MK FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_MUP_MK_S CHECK (INSTR(SRC_VIEW, '.') > 0),
	CONSTRAINT CK_WASH_ISTR_MUP_MK_D CHECK (INSTR(DST_TABLE, '.') > 0)
);

COMMENT ON TABLE VPI.WASH_ISTR_MUP_MK
	IS 'Make up Missing Keys ¨C the compensation inserts unique rows contained by the source table/view (select distinct supposed foreign key and coping values) but missing in the target table (by supposed primary key) originally.';

COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.ISTR_ID
	IS 'The ISTR_ID embodies the inheritance from the base WASH_ISTR.';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.SRC_VIEW
	IS 'The source table/view which references the universal set of supposed foreign key. Schema name is always required in the table or view name. (E.g. ABC.VIEW_SRC)';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.SRC_FILTER
	IS '(Optional)Specifies the search conditions used to limit the number of rows to be matched (E.g. ID_TYPE = ''ISIN''). If this column is NULL, all the rows from the source table/view will be taken as the universal set.';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.SRC_KEY_COLUMNS
	IS 'Specifies a column or a comma-separated list of columns which is supposed to be a foreign key and will be used to join with DST_KEY_COLUMNS (supposed primary key of target table).';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.DST_TABLE
	IS 'The target table to be checked and to be made up. Schema name is always required in the table name. (E.g. ABC.TABLE_DST)';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.DST_KEY_COLUMNS
	IS 'Specifies a column or a comma-separated list of columns which is supposed to be a primary key of target table and can be used to join with SRC_KEY_COLUMNS of SRC_VIEW.';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.DST_VAL_COLUMNS
	IS '(Optional) When insert a new compensating row into the target table, some non-key columns may need to be assigned as a special value (such as ¡®Dummy¡¯, ¡®Unknown¡¯, ¡®N/A¡¯, -1, ¡®1900-01-01¡¯¡­). DST_VAL_COLUMNS specifies a column or a comma-separated list of columns (E.g. GRP_ID, ROW_SRC) to be assigned. A column that is listed in DST_KEY_COLUMNS can not be included in the DST_VAL_COLUMNS.';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_MK.SRC_VALUES
	IS '(Optional) If DST_VAL_COLUMNS is specified, and then SRC_VALUES is required. SRC_VALUES specifies a value expression or a comma-separated list of value expressions which will be loaded into DST_VAL_COLUMNS while making up. An expression can be a constant (E.g. -1, ''Made-up'') or an expression references on SRC_VIEW (E.g. -1, LAST_UPD). It''s natural that only unique rows (by key columns) will be inserted into the target table if all expressions only contain constants. Otherwise, the SRC_VIEW is responsible for ensuring the uniqueness of result set if an expression references on a column(s) of SRC_VIEW.';
