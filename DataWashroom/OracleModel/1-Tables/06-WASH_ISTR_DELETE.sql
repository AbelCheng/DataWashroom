CREATE TABLE VPI.WASH_ISTR_DELETE
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	DST_TABLE		VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)
	DST_FILTER		VARCHAR2(1024),

	CONSTRAINT PK_WASH_ISTR_DELETE PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_DELETE FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_DELETE_D CHECK (INSTR(DST_TABLE, '.') > 0)
);

COMMENT ON TABLE VPI.WASH_ISTR_DELETE
	IS 'Removes rows from a table. For instance, to refresh data from source system, a DELETE step could need to be operated before COPY.';

COMMENT ON COLUMN VPI.WASH_ISTR_DELETE.ISTR_ID
	IS 'The ISTR_ID embodies the inheritance from the base WASH_ISTR.';
COMMENT ON COLUMN VPI.WASH_ISTR_DELETE.DST_TABLE
	IS 'Specifies the table from which the rows are to be deleted. Schema name is always required in the table name. (E.g. ABC.WORK_TABLE)';
COMMENT ON COLUMN VPI.WASH_ISTR_DELETE.DST_FILTER
	IS '(Optional)Specifies the conditions used to limit the number of rows that are deleted (E.g. ID_TYPE = ''ISIN''). If this column is NULL, DELETE removes all the rows from the table.';
