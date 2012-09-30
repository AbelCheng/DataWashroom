CREATE TABLE VPI.WASH_ISTR_MUP_NA
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	DST_TABLE		VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)
	DST_KEY_COLUMNS	VARCHAR2(256)		NOT NULL,
	DST_VAL_COLUMNS	VARCHAR2(512),
	MAKE_UP_KEYS	VARCHAR2(256)		NOT NULL,
	MAKE_UP_VALUES	VARCHAR2(512),

	CONSTRAINT PK_WASH_ISTR_MUP_NA PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_MUP_NA FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_MUP_NA_D CHECK (INSTR(DST_TABLE, '.') > 0)
);

COMMENT ON TABLE VPI.WASH_ISTR_MUP_NA
	IS 'Make up a N/A key иC insert a special primary key into the target table as a reserved row for substituting N/A cases (such as null-references, exception replacement бн) if it did not exist before.';

COMMENT ON COLUMN VPI.WASH_ISTR_MUP_NA.ISTR_ID
	IS 'The ISTR_ID embodies the inheritance from the base WASH_ISTR.';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_NA.DST_TABLE
	IS 'The target table to be made up. Schema name is always required in the table name. (E.g. ABC.TABLE_DST)';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_NA.DST_KEY_COLUMNS
	IS 'Specifies a column or a comma-separated list of columns which is the primary key of the target table. (E.g. REF_ID)';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_NA.DST_VAL_COLUMNS
	IS '(Optional) When insert a reserved row into the target table, some non-key columns may need to be assigned as special attributes (such as ''Dummy'', ''Unknown'', ''N/A'', -1, ''1900-01-01''...). DST_VAL_COLUMNS specifies a column or a comma-separated list of columns (E.g. GRP_ID, ROW_SRC) to be assigned. A column that is listed in DST_KEY_COLUMNS can not be included in the DST_VAL_COLUMNS.';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_NA.MAKE_UP_KEYS
	IS 'Introduces a constant or a comma-separated list of constants of primary key columns to be inserted if it did not exist (E.g. -1). There must be one data value for each column of DST_KEY_COLUMNS list in the same order. If the same key already exists, nothing will be updated on that row.';
COMMENT ON COLUMN VPI.WASH_ISTR_MUP_NA.MAKE_UP_VALUES
	IS '(Optional) If DST_VAL_COLUMNS is specified, and then MAKE_UP_VALUES is required. MAKE_UP_VALUES introduces a constant or a comma-separated list of constants which will be assigned to columns of DST_VAL_COLUMNS. The values in the MAKE_UP_VALUES must be in the same order as the columns in DST_VAL_COLUMNS list. (E.g. -1, ''N/A'')';
