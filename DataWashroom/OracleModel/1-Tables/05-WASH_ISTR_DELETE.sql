CREATE TABLE VPI.WASH_ISTR_DELETE
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	DST_TABLE		VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)
	DST_FILTER		VARCHAR2(1024),

	CONSTRAINT PK_WASH_ISTR_DELETE PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_DELETE FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_DELETE_D CHECK (INSTR(DST_TABLE, '.') > 0)
);
