prompt Importing table WASH_ISTR_TYPE...
set feedback off
set define off
insert into WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
values ('DELETE', 'WASH_ISTR_DELETE', 'Delete', 'Delete');

insert into WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
values ('COPY', 'WASH_ISTR_COPY', 'Copy', 'Copy matched columns (by column names)');

insert into WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
values ('MERGE', 'WASH_ISTR_MERGE', 'Merge', 'Merge(update and/or insert) data by matched columns');

insert into WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
values ('CHK_UK', 'WASH_ISTR_CHK_UK', 'Check unique key', 'Check supposed unique key');

insert into WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
values ('RNK_DK', 'WASH_ISTR_RNK_DK', 'Sort duplicated key', 'Sort duplicated key - for taking top 1');

insert into WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
values ('MUP_MK', 'WASH_ISTR_MUP_MK', 'Make up missing keys', 'Make up missing keys in accordance with supposed foreign table');

insert into WASH_ISTR_TYPE (ISTR_TYPE, DERIVED_TABLE, TYPE_BRIEF, DESCRIPTION_)
values ('MUP_NA', 'WASH_ISTR_MUP_NA', 'Make up a N/A key', 'Make up a N/A key (e.g. UNKNOWN, OTHER, DUMMY, -1, ...)');

prompt Done.
