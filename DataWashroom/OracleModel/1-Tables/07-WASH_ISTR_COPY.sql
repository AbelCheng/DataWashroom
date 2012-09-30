CREATE TABLE VPI.WASH_ISTR_COPY
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	SRC_VIEW		VARCHAR2(61)		NOT NULL,	-- Source View (must include schema.view/table)
	SRC_FILTER		VARCHAR2(1024),
	DST_TABLE		VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)

	CONSTRAINT PK_WASH_ISTR_COPY PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_COPY FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_COPY_S CHECK (INSTR(SRC_VIEW, '.') > 0),
	CONSTRAINT CK_WASH_ISTR_COPY_D CHECK (INSTR(DST_TABLE, '.') > 0)
);

COMMENT ON TABLE VPI.WASH_ISTR_COPY
	IS 'Copies all matching columns (by column name) of data from a source table or view to a destination table.';

COMMENT ON COLUMN VPI.WASH_ISTR_COPY.ISTR_ID
	IS 'The ISTR_ID embodies the inheritance from the base WASH_ISTR.';
COMMENT ON COLUMN VPI.WASH_ISTR_COPY.SRC_VIEW
	IS 'Specifies the source table or view to be copied from. Schema name is always required in the table or view name. (E.g. ABC.VIEW_SRC)';
COMMENT ON COLUMN VPI.WASH_ISTR_COPY.SRC_FILTER
	IS '(Optional)Specifies the search conditions used to limit the number of rows to be copied (E.g. ID_TYPE = ''ISIN''). If this column is NULL, all the rows from the source will be copied.';
COMMENT ON COLUMN VPI.WASH_ISTR_COPY.DST_TABLE
	IS 'Specifies the destination table from which the rows are to be copied to. Schema name is always required in the table name. (E.g. ABC.TABLE_DST)';
