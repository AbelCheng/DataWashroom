
INSERT INTO WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
VALUES ('DELETE', 'WASH_ISTR_DELETE', 'Delete', 'Delete');

INSERT INTO WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
VALUES ('COPY', 'WASH_ISTR_COPY', 'Copy', 'Copy matched columns (by column names)');

INSERT INTO WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
VALUES ('MERGE', 'WASH_ISTR_MERGE', 'Merge', 'Merge(update and/or insert) data by matched columns');

INSERT INTO WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
VALUES ('CHK_UK', 'WASH_ISTR_CHK_UK', 'Check unique key', 'Check supposed unique key');

INSERT INTO WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
VALUES ('RNK_DK', 'WASH_ISTR_RNK_DK', 'Sort duplicated key', 'Sort duplicated key - for taking top 1');

INSERT INTO WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
VALUES ('MUP_MK', 'WASH_ISTR_MUP_MK', 'Make up missing keys', 'Make up missing keys in accordance with supposed foreign table');

INSERT INTO WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
VALUES ('MUP_NA', 'WASH_ISTR_MUP_NA', 'Make up a N/A key', 'Make up a N/A key (e.g. UNKNOWN, OTHER, DUMMY, -1, ...)');

COMMIT;
