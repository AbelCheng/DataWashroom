CREATE TABLE VPI.WASH_ISTR_MERGE
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	SRC_VIEW		VARCHAR2(61)		NOT NULL,	-- Source View (must include schema.view/table)
	SRC_FILTER		VARCHAR2(1024),
	DST_TABLE		VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)
	JOIN_COLUMNS	VARCHAR2(1024)		NOT NULL,
	UPDATE_COLUMNS	VARCHAR2(1024),
	INSERT_COLUMNS	VARCHAR2(1024),

	CONSTRAINT PK_WASH_ISTR_MERGE PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_MERGE FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_MERGE_S CHECK (INSTR(SRC_VIEW, '.') > 0),
	CONSTRAINT CK_WASH_ISTR_MERGE_D CHECK (INSTR(DST_TABLE, '.') > 0),
	CONSTRAINT CK_WASH_ISTR_MERGE_M CHECK (UPDATE_COLUMNS IS NOT NULL OR INSERT_COLUMNS IS NOT NULL)
);

COMMENT ON TABLE VPI.WASH_ISTR_MERGE
	IS 'Merges specified matching columns (by column name) of data from a source table or view to a target table - Updating specified columns in a target table if a matching row exists, or inserting the data as a new row if a matching row does not exist.';

COMMENT ON COLUMN VPI.WASH_ISTR_MERGE.ISTR_ID
	IS 'The ISTR_ID embodies the inheritance from the base WASH_ISTR.';
COMMENT ON COLUMN VPI.WASH_ISTR_MERGE.SRC_VIEW
	IS 'Specifies the source table or view to be merged from. Schema name is always required in the table or view name. (E.g. ABC.VIEW_SRC)';
COMMENT ON COLUMN VPI.WASH_ISTR_MERGE.SRC_FILTER
	IS '(Optional)Specifies the search conditions used to limit the number of rows to be merged (E.g. ID_TYPE = ''ISIN''). If this column is NULL, all the rows from the source will be consumed as the source data.';
COMMENT ON COLUMN VPI.WASH_ISTR_MERGE.DST_TABLE
	IS 'Specifies the destination table to which the rows are to be copied. Schema name is always required in the table name. (E.g. ABC.TABLE_DST)';
COMMENT ON COLUMN VPI.WASH_ISTR_MERGE.JOIN_COLUMNS
	IS 'Specifies the list of columns on which source table/view is joined with the target table to determine where they match. Multiple columns must be delimited by commas. (E.g. POS_ID, GRP_ID, DATE_) The column names must exist in both source table/view and destination table.';
COMMENT ON COLUMN VPI.WASH_ISTR_MERGE.UPDATE_COLUMNS
	IS 'Specifies a comma-separated list of columns to be updated in the destination table by matching rows from the source table/view (matched by JOIN_COLUMNS). A column that is referenced in JOIN_COLUMNS list can not be included in the UPDATE_COLUMNS list.';
COMMENT ON COLUMN VPI.WASH_ISTR_MERGE.INSERT_COLUMNS
	IS 'Specifies a comma-separated list of columns which will be copied from the source table/view to the destination table when matching rows did not exist. A column in JOIN_COLUMNS list can also be included in the INSERT_COLUMNS list.';
