CREATE TABLE VPI.WASH_ISTR_RNK_DK
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	DST_TABLE		VARCHAR2(61)		NOT NULL,	-- Destination Table (must include schema.table)
	DST_FILTER		VARCHAR2(1024),
	KEY_COLUMNS		VARCHAR2(256)		NOT NULL,
	ORDER_BY		VARCHAR2(256)		NOT NULL,
	RN_COLUMN		VARCHAR2(30)		NOT NULL,

	CONSTRAINT PK_WASH_ISTR_RNK_DK PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_RNK_DK FOREIGN KEY (ISTR_ID) REFERENCES VPI.WASH_ISTR (ISTR_ID) ON DELETE CASCADE,
	CONSTRAINT CK_WASH_ISTR_RNK_DK_DT CHECK (INSTR(DST_TABLE, '.') > 0)
);

COMMENT ON TABLE VPI.WASH_ISTR_RNK_DK
	IS 'Rank Duplicate Key ¨C Checks the uniqueness by a supposed business key, ranks every row within their partition of the supposed key, and assigns a sequential number of every row, starting at 1 for the first row in each partition.';

COMMENT ON COLUMN VPI.WASH_ISTR_RNK_DK.ISTR_ID
	IS 'The ISTR_ID embodies the inheritance from the base WASH_ISTR.';
COMMENT ON COLUMN VPI.WASH_ISTR_RNK_DK.DST_TABLE
	IS 'Specifies the target table to be checked. Schema name is always required in the table name. (E.g. ABC.TABLE_DST)';
COMMENT ON COLUMN VPI.WASH_ISTR_RNK_DK.DST_FILTER
	IS '(Optional)Specifies the search conditions used to limit the number of rows to be checked (E.g. ID_TYPE = ''ISIN''). If this column is NULL, all the rows from the table will be checked.';
COMMENT ON COLUMN VPI.WASH_ISTR_RNK_DK.KEY_COLUMNS
	IS 'Specifies a column or a list of columns which is supposed to be a unique key. A composite key (includes two or more columns) must be delimited by commas (E.g. DATE_, POS_ID).';
COMMENT ON COLUMN VPI.WASH_ISTR_RNK_DK.ORDER_BY
	IS 'The ORDER_BY clause determines the sequence in which the rows are assigned their unique ROW_NUMBER within a specified partition (E.g. TRAN_NO DESC, PRICE). It is required.';
COMMENT ON COLUMN VPI.WASH_ISTR_RNK_DK.RN_COLUMN
	IS 'Specifies the column for filling the ROW_NUMBER. It is required, the column type must be NUMBER or compatible types.';
