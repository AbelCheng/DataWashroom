CREATE TABLE VPI.WASH_ISTR
(
	ISTR_ID			VARCHAR2(32)		NOT NULL,
	CYCLE_ID		VARCHAR2(32)		NOT NULL,
	ISTR_TYPE		VARCHAR2(16)		NOT NULL,
	ISTR_ORDER		NUMBER(4) DEFAULT 0	NOT NULL,
	DESCRIPTION_	VARCHAR2(1024),

	CONSTRAINT PK_WASH_ISTR PRIMARY KEY (ISTR_ID),
	CONSTRAINT FK_WASH_ISTR_C FOREIGN KEY (CYCLE_ID) REFERENCES VPI.WASH_CYCLE (CYCLE_ID) ON DELETE CASCADE,
	CONSTRAINT FK_WASH_ISTR_T FOREIGN KEY (ISTR_TYPE) REFERENCES VPI.WASH_ISTR_TYPE (ISTR_TYPE)
);

CREATE INDEX VPI.IX_WASH_ISTR_ODR ON VPI.WASH_ISTR (CYCLE_ID, ISTR_ORDER);
CREATE INDEX VPI.IX_WASH_ISTR_T ON VPI.WASH_ISTR (CYCLE_ID, ISTR_TYPE);

COMMENT ON TABLE VPI.WASH_ISTR
	IS 'This is the base table of all 7 wash-instruction tables. Each row of this table is a wash instruction declaration. For a top-down design, this table can also be used for storing requirement or outline design with every wash step of a wash cycle. For the compiler, this base table is treated like a header file to C++.';

COMMENT ON COLUMN VPI.WASH_ISTR.ISTR_ID
	IS 'Defines the unique mnemonic identifier for a wash instruction, consider a naming convention within the enterprise.';
COMMENT ON COLUMN VPI.WASH_ISTR.CYCLE_ID
	IS 'Which wash cycle does the wash instruction belong to.';
COMMENT ON COLUMN VPI.WASH_ISTR.ISTR_TYPE
	IS 'The type of instruction can be one of: DELETE, COPY, MERGE, CHK_UK, RNK_DK, MUP_MK, MUP_NA. It indicates the definition of the instruction is located in which derived instruction table.';
COMMENT ON COLUMN VPI.WASH_ISTR.ISTR_ORDER
	IS 'The step ordinal of the instruction within its wash cycle.';
COMMENT ON COLUMN VPI.WASH_ISTR.DESCRIPTION_
	IS 'The brief introduction of what is this step going to do. This is an optional info, but it can be useful for generating the progress status for every step and documentation-generation.';
