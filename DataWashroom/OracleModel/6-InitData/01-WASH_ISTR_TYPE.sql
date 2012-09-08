prompt Importing table WASH_ISTR_TYPE...
set feedback off
set define off
insert into WASH_ISTR_TYPE (ISTR_TYPE, ISTR_BRIEF, DESCRIPTION_)
values ('DELETE', 'Delete', 'Delete');

insert into WASH_ISTR_TYPE (ISTR_TYPE, ISTR_BRIEF, DESCRIPTION_)
values ('COPY', 'Copy', 'Copy');

insert into WASH_ISTR_TYPE (ISTR_TYPE, ISTR_BRIEF, DESCRIPTION_)
values ('MERGE', 'Merge', 'Merge');

insert into WASH_ISTR_TYPE (ISTR_TYPE, ISTR_BRIEF, DESCRIPTION_)
values ('CHK_UK', 'Check unique key', 'Check unique key, ');

insert into WASH_ISTR_TYPE (ISTR_TYPE, ISTR_BRIEF, DESCRIPTION_)
values ('RNK_DK', 'Sort duplicated key', 'Sort duplicated key - take top 1');

insert into WASH_ISTR_TYPE (ISTR_TYPE, ISTR_BRIEF, DESCRIPTION_)
values ('MUP_MK', 'Make up missing keys', null);

insert into WASH_ISTR_TYPE (ISTR_TYPE, ISTR_BRIEF, DESCRIPTION_)
values ('MUP_NA', 'Make up a N/A key', null);

prompt Done.
