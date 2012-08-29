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
