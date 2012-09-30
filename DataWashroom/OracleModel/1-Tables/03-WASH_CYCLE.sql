CREATE TABLE VPI.WASH_CYCLE
(
	CYCLE_ID		VARCHAR2(32)		NOT NULL,	-- Globel name
	PROCEDURE_NAME	VARCHAR2(61)		NOT NULL,
	DESCRIPTION_	VARCHAR2(512),
	OWNER_			VARCHAR2(32),
	LATEST_VERSION	NUMBER(4) DEFAULT 0	NOT NULL,

	CONSTRAINT PK_WASH_CYCLE PRIMARY KEY (CYCLE_ID),
	CONSTRAINT UK_WASH_CYCLE_SP UNIQUE (PROCEDURE_NAME),
	CONSTRAINT CK_WASH_CYCLE_VER CHECK (LATEST_VERSION >= 0)
)	STORAGE (INITIAL 16K NEXT 16K);

COMMENT ON TABLE VPI.WASH_CYCLE
	IS 'A wash cycle is a sequential workflow of wash instructions.';

COMMENT ON COLUMN VPI.WASH_CYCLE.CYCLE_ID
	IS 'The unique mnemonic identifier for a wash cycle, consider a naming convention within the enterprise (like a short namespace).';
COMMENT ON COLUMN VPI.WASH_CYCLE.PROCEDURE_NAME
	IS 'Define the stored procedure name of the wash cycle to be generated, just as the executable file name to an application. The schema name must be included in the stored procedure name (e.g. ABC.PRETREATMENT).';
COMMENT ON COLUMN VPI.WASH_CYCLE.DESCRIPTION_
	IS 'Arbitrary introduction of the wash cycle, it can be brief like an application name.';
COMMENT ON COLUMN VPI.WASH_CYCLE.OWNER_
	IS 'The owner of the wash cycle.';
COMMENT ON COLUMN VPI.WASH_CYCLE.LATEST_VERSION
	IS 'This is a free maintenance column with initialization 0. It''s used inside version control.';
