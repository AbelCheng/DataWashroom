CREATE TABLE VPI.CACHE_CONTROL
(
	CACHE_ID		VARCHAR2(32)			NOT NULL,
	CACHE_EXPIRY	NUMBER(4) DEFAULT 240	NOT NULL,
	LOCK_ORDINAL	NUMBER(9)				NOT NULL,
	DESCRIPTION_	VARCHAR2(128),

	REFRESH_START	DATE,
	PROGRESS_ID		NUMBER(9),
	REFRESH_END		DATE,

	CONSTRAINT PK_CACHE_CONTROL PRIMARY KEY (CACHE_ID),
	CONSTRAINT CK_CACHE_CONTROL_EXPIRY CHECK (CACHE_EXPIRY >= 10),
	CONSTRAINT FK_CACHE_CONTROL_PROGRESS FOREIGN KEY (PROGRESS_ID) REFERENCES VPI.PROGRESS_STATUS (PROGRESS_ID) ON DELETE SET NULL,
	CONSTRAINT UK_CACHE_CONTROL_LOCK_ORDINAL UNIQUE (LOCK_ORDINAL)
)	ORGANIZATION INDEX;

COMMENT ON TABLE VPI.CACHE_CONTROL
	IS 'Global Cache Controller';

COMMENT ON COLUMN VPI.CACHE_CONTROL.CACHE_ID
	IS 'A database-wide unique identifier; This ID is also used as a global lock name (with prefix CACHE$).';
COMMENT ON COLUMN VPI.CACHE_CONTROL.CACHE_EXPIRY
	IS 'Number of minutes to keep the cached data acceptable.';

COMMENT ON COLUMN VPI.CACHE_CONTROL.REFRESH_START
	IS 'The start time of last refreshing.';
COMMENT ON COLUMN VPI.CACHE_CONTROL.REFRESH_END
	IS 'The end time of last refreshing.';
COMMENT ON COLUMN VPI.CACHE_CONTROL.PROGRESS_ID
	IS 'The refreshing progress ties to PROGRESS_STATUS table.';

COMMENT ON COLUMN VPI.CACHE_CONTROL.LOCK_ORDINAL
	IS 'Auto-assign a unique sequence number for each cache, so that multiple caches can always be locked in the same order to avoid deadlock. This number is generated by a trigger, do not manually change it.';
