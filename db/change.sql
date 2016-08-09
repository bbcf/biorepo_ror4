alter table "attrs" rename to attrs_old;
alter sequence "attrs_id_seq" rename to "attrs_old_id_seq";
alter index "attrs_pkey" rename to attrs_old_pkey;
--and all other keys of attrs_old
alter table attrs_old add column new_id int;

---------------------------------------
create table widgets (
    id serial not null primary key,
    name varchar(255),
    fixed_value boolean
);

insert into widgets (name, fixed_value) select distinct widget, fixed_value from attrs_old;
--checkbox and hiding checkbox have fixed value true/false
update widgets set fixed_value = true where id = 3 or id = 4;
insert into widgets (name, fixed_value) values ('integer', false);
insert into widgets (name, fixed_value) values ('year', true); 
insert into widgets (name, fixed_value) values ('radio', true); 
-----------------------------------------------------
create table attrs (
    id serial not null primary key, 
    name varchar(255),
    widget_id integer not null,
    owner varchar(255)
);

alter table attrs add foreign key (widget_id) references widgets;

insert into attrs (name, widget_id, owner) select distinct key, w.id, owner from attrs_old as a, widgets as w  where a.widget = w.name;
-- change for integer and year type fields 
update attrs set widget_id = 6 where id in (30, 35, 43);
update attrs set widget_id = 7 where id = 9;

--correspondance between old attr_id and new attr_id
update attrs_old set new_id = (select a.id from attrs as a, widgets as w, attrs_old as ao where w.id = a.widget_id and w.name = ao.widget and ao.key = a.name and ao.id = attrs_old.id);


--check correspondance between attrs and labs:
--select * from attrs as a, attrs_old as ao, widgets as w where a.name = ao.key and a.owner = ao.owner and ao.widget = w.name and w.id = a.widget_id order by a.name;

create table attrs_labs (
    attr_id integer not null,
    lab_id integer not null,
    owner varchar(255)
);
alter table attrs_labs add foreign key (lab_id) references labs on delete cascade;
alter table attrs_labs add foreign key (attr_id) references attrs on delete cascade;

insert into attrs_labs (select new_id, lab_id, owner from attrs_old);

----------------------------------------------------------------------------
-- deal with attribute values
alter table "attr_values" rename to attr_values_old;
alter sequence "attr_values_id_seq" rename to "attr_values_old_id_seq";
alter index "attr_values_pkey" rename to attr_values_old_pkey;


create table attr_values (
    id serial not null primary key,
    name varchar(255),
    attr_id integer not null
);

alter table attr_values add foreign key (attr_id) references attrs on delete cascade;

--select attrs id's
--select tmp.aoid from (select distinct ao.id as aoid, a.id as aid, a.name as name, w.id as wid, a.owner as owner from attrs_old as ao, attrs as a, widgets as w  where ao.widget = w.name and ao.fixed_value = w.fixed_value and a.name = ao.key and a.widget_id = w.id order by name) as tmp ;

--select different attr_values for 'organism'
--select distinct avo.value, tmp.aid, tmp.aoid from attr_values as avo, (select distinct ao.id as aoid, a.id as aid, a.name as name, w.id as wid, a.owner as owner from attrs_old as ao, attrs as a, widgets as w  where ao.widget = w.name and ao.fixed_value = w.fixed_value and a.name = ao.key and a.widget_id = w.id order by name) as tmp, widgets as ww  where tmp.wid = ww.id and ww.fixed_value is true and tmp.aid = 23 and avo.attr_id = tmp.aoid;


--dealing only with FIXED values for now and checkboxes as w.fixed_value = true for them
insert into attr_values (name, attr_id)  (select distinct avo.value,  ao.new_id as new_id  from attr_values_old as avo, attrs_old as ao, widgets as w  where ao.id = avo.attr_id and w.name = ao.widget and w.fixed_value = true and ( avo.value is not  null and avo.value  <> ''));

----------------------------------------------------
--add column with new attr_id and attr_value_id

alter table attr_values_old add column new_attr_id int;
alter table attr_values_old add column new_attr_value_id int;
alter table attr_values_old add foreign key (new_attr_id) references attrs;
alter table attr_values_old add foreign key (new_attr_value_id) references attr_values;

--update attr_values_old set new_attr_id = (select aid from (select distinct ao.id as aoid, a.id as aid, a.name as name, w.id as wid, a.owner as owner from attrs_old as ao, attrs as a, widgets as w  where ao.widget = w.name and ao.fixed_value = w.fixed_value and a.name = ao.key and a.widget_id = w.id order by name) as tmp where tmp.aoid = attr_values_old.attr_id);

-- for all
update attr_values_old set new_attr_id = (select ao.new_id from attrs_old as ao where ao.id = attr_values_old.attr_id);

--for fixed 
update attr_values_old set new_attr_value_id = (select av.id from attr_values as av, attr_values_old as avo, attrs_old as ao where av.attr_id = ao.new_id and av.name = avo.value and avo.new_attr_id = av.attr_id and ao.id = avo.attr_id and attr_values_old.id = avo.id);

--------------------------------------------------------------

--connection between values and labs. 
create table attr_values_labs (
    attr_value_id integer not null,
    lab_id integer not null
);
alter table attr_values_labs add foreign key (lab_id) references labs on delete cascade;
alter table attr_values_labs add foreign key (attr_value_id) references attr_values on delete cascade;

insert into attr_values_labs  (select new_attr_value_id, lab_id from attr_values_old as avo, attrs_old as ao where avo.new_attr_id = ao.new_id and avo.attr_id = ao.id and new_attr_value_id is not null);

--select * from attr_values_old as avo, attrs_old as ao where avo.old_attr_id  = ao.id and ao.new_id = 23;
--insert into attr_values_labs (select a.id, ao.lab_id, a.owner from attr_values as av, attr_values_old as avo, widgets as w where a.name = ao.key and a.owner = ao.owner and ao.widget = w.name and w.id = a.widget_id);
------------------------------------------------------------------------------
-- insert values for 'year' attribute
insert into attr_values (name, attr_id) select distinct value, new_attr_id from attr_values_old where attr_id in (49, 61, 76) and value is not null and value <> '';

update attr_values_old set new_attr_value_id = (select av.id from attr_values as av, attr_values_old as avo, attrs_old as ao where av.attr_id = ao.new_id and av.name = avo.value and avo.new_attr_id = av.attr_id and ao.id = avo.attr_id and attr_values_old.id = avo.id) where new_attr_id = 9;


insert into attr_values_labs (select new_attr_value_id, lab_id from attr_values_old as avo, attrs_old as ao where avo.new_attr_id = ao.new_id and avo.attr_id = ao.id and new_attr_value_id is not null and avo.new_attr_id = 9);
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--dealing only with NOT FIXED values for now (no checkboxes) 336
insert into attr_values (name, attr_id)  (select distinct avo.value,  ao.new_id as new_id  from attr_values_old as avo, attrs_old as ao, widgets as w  where ao.id = avo.attr_id and w.name = ao.widget and w.fixed_value = false and ( avo.value is not  null and avo.value  <> ''));

--now fills all the rest records 29545
update attr_values_old set new_attr_value_id = (select av.id from attr_values as av, attr_values_old as avo, attrs_old as ao where av.attr_id = ao.new_id and av.name = avo.value and avo.new_attr_id = av.attr_id and ao.id = avo.attr_id and attr_values_old.id = avo.id) where new_attr_value_id is null;

-- last "not in" to escape doubling 11295
insert into attr_values_labs  (select new_attr_value_id, lab_id from attr_values_old as avo, attrs_old as ao where avo.new_attr_id = ao.new_id and avo.attr_id = ao.id and new_attr_value_id is not null and new_attr_value_id not in (select attr_value_id from attr_values_labs));

----------------------------------------------------------------------------------
-- measurements and samples

alter table "attr_values_samples" rename to attr_values_samples_old;
alter table attr_values_samples_old add column new_attr_value_id int;
update attr_values_samples_old set new_attr_value_id = (select new_attr_value_id from attr_values_old as avo where avo.id = attr_values_samples_old.attr_value_id);

alter table "attr_values_measurements" rename to attr_values_measurements_old;
alter table attr_values_measurements add column new_attr_value_id int;
update attr_values_measurements_old set new_attr_value_id = (select new_attr_value_id from attr_values_old as avo where avo.id = attr_values_measurements_old.attr_value_id);

create table attr_values_samples (
    sample_id integer not null,
    attr_value_id integer not null
);

alter table attr_values_samples add foreign key (sample_id) references samples on delete cascade;
alter table attr_values_samples add foreign key (attr_value_id) references attr_values on delete cascade;
insert into attr_values_samples select sample_id, new_attr_value_id from attr_values_samples_old where new_attr_value_id is not null;

create table attr_values_measurements (
    measurement_id integer not null,
    attr_value_id integer not null
);

alter table attr_values_measurements add foreign key (measurement_id) references measurements on delete cascade;
alter table attr_values_measurements add foreign key (attr_value_id) references attr_values on delete cascade;
insert into attr_values_measurements select measurement_id, new_attr_value_id from attr_values_measurements_old where new_attr_value_id is not null;

-----------------------------------------------------------
-- create experiments

create table exp_types (
    id serial not null primary key,
    name varchar(255)
);

insert into exp_types (name) select distinct exp_type from samples;
------------------------------------------------------------------------------------
------- deal with redundant fields
alter table samples add column description text;

--biobackground 12
update samples set description = (select av.name from attr_values_samples as avs, attr_values as av where av.id  = avs.attr_value_id and avs.attr_value_id in (select id from attr_values where attr_id = 12) and samples.id = avs.sample_id);

--update samples set description = (select av.name || ', ' || description from attr_values_samples as avs, attr_values as av where av.id  = avs.attr_value_id and avs.attr_value_id in (select id from attr_values where attr_id = 48) and samples.id = avs.sample_id);

-- these 3 lines after each description update to remove extra comas
update samples set description = null where description = ', ';
update samples set description = (select rtrim(s.description, ', ') from samples as s where s.id = samples.id) where description like '%, ';
update samples set description = (select ltrim(s.description, ', ') from samples as s where s.id = samples.id) where description like ', %';


update samples set description = concat(description, ', ', (select av.name from attr_values_samples as avs, attr_values as av where av.id  = avs.attr_value_id and avs.attr_value_id in (select id from attr_values where attr_id = 32) and samples.id = avs.sample_id));

update samples set description = null where description = ', ';

update samples set description = concat(description, ', ', (select av.name from attr_values_samples as avs, attr_values as av where av.id  = avs.attr_value_id and avs.attr_value_id in (select id from attr_values where attr_id = 19) and samples.id = avs.sample_id));

update samples set description = null where description = ', ';

update samples set description = concat(description, ', ', (select av.name from attr_values_samples as avs, attr_values as av where av.id  = avs.attr_value_id and avs.attr_value_id in (select id from attr_values where attr_id = 13) and samples.id = avs.sample_id));

update samples set description = null where description = ', ';

update samples set description = concat(description, ', ', (select av.name from attr_values_samples as avs, attr_values as av where av.id  = avs.attr_value_id and avs.attr_value_id in (select id from attr_values where attr_id = 42) and samples.id = avs.sample_id));

update samples set description = null where description = ', ';

-----------------------------------------------------------
alter table attrs add column deprecated boolean; 
update attrs set deprecated = true where id in ( 13, 19, 32, 42);
update attrs set deprecated = true where id in (1, 7, 20, 22, 25, 26, 33, 34, 39, 40, 44);
update attrs set deprecated = true where id in (9, 31);
alter table attrs add column new boolean;

-- may be select field SE or PE paired_end id = 41

-- paired_end + sequence_length
insert into attrs (name, widget_id, owner, new) values ('sequence_length', 6, 'sample', true);

-- select old sample values with new one
--select s.id as sid, s.name as sname, av.id as avid, av.name as avname, av2.id, av2.name from samples as s, attr_values as av, attr_values as av2, attr_values_samples as avs where  avs.sample_id = s.id and avs.attr_value_id = av.id and av.id in (select id from attr_values where attr_id = 37) and av.id = 3 and av2.id = 502;


-- break values like '100bp SE' into pared_end = false and sequence_length = 100
insert into attr_values_samples select s.id, av2.id from samples as s, attr_values as av, attr_values as av2, attr_values_samples as avs where  avs.sample_id = s.id and avs.attr_value_id = av.id and av.id in (select id from attr_values where attr_id = 37) and av.id = 3 and av2.id = 99; --502;

insert into attr_values_samples select s.id, av2.id from samples as s, attr_values as av, attr_values as av2, attr_values_samples as avs where  avs.sample_id = s.id and avs.attr_value_id = av.id and av.id in (select id from attr_values where attr_id = 37) and av.id = 92 and av2.id = 102; --501;

insert into attr_values (name, attr_id) values(50, 50);
insert into attr_values_samples select s.id, av2.id from samples as s, attr_values as av, attr_values as av2, attr_values_samples as avs where  avs.sample_id = s.id and avs.attr_value_id = av.id and av.id in (select id from attr_values where attr_id = 37)  and av2.id = 503;

-- if neither PE nor SE - what is it?
insert into attr_values_samples select s.id, av2.id from samples as s, attr_values as av, attr_values as av2, attr_values_samples as avs where  avs.sample_id = s.id and avs.attr_value_id = av.id and av.id in (select id from attr_values where attr_id = 47) and av.name like '%SE%'  and av2.id = 99; --502;
insert into attr_values_samples select s.id, av2.id from samples as s, attr_values as av, attr_values as av2, attr_values_samples as avs where  avs.sample_id = s.id and avs.attr_value_id = av.id and av.id in (select id from attr_values where attr_id = 47) and av.name like '%PE%'  and av2.id = 102; --501;

insert into attr_values (name, attr_id) values (100, 50), (36, 50), (46, 50), (76, 50), (80, 50), (86, 50);
insert into attr_values_samples (sample_id, attr_value_id) (select s.id, av2.id from samples as s, attr_values as av, attr_values as av2, attr_values_samples as avs where  avs.sample_id = s.id and avs.attr_value_id = av.id and av.id in (select id from attr_values where attr_id = 47)  and split_part(av.name, 'bp', 1) = av2.name and av2.id > 500);

update attrs set deprecated = true where id in (37, 47);
----------------------------------------------------------------------------------------------
-- deal with 5 bio_background 12 bio_background 15 strain 48 genotype fields (attrs non-overlaping by labs)
insert into attrs (name, widget_id, owner, new) values ('background/genotype', 2, 'sample', true);
insert into attr_values (name, attr_id) select av.name, a.id from attr_values as av, attrs as a where av.attr_id in (5, 12,15,48) and a.name = 'background/genotype';
-- leave only one unique 'WT' value
delete from attr_values where name = 'WT' and attr_id = 51;
update attr_values set name = 'WT' where name = 'wt';
-- check 
--select avs.sample_id, av.id, av.name, av2.id, av2.name from attr_values_samples as avs, attr_values as av, attr_values as av2 where avs.attr_value_id = av.id and av.attr_id in (5, 12, 15, 48) and av.name = av2.name and av2.attr_id = 51;
-- insert values into cross-table
insert into attr_values_samples (select avs.sample_id, av2.id from attr_values_samples as avs, attr_values as av, attr_values as av2 where avs.attr_value_id = av.id and av.attr_id in (5, 12, 15, 48) and av.name = av2.name and av2.attr_id = 51);
update attrs set deprecated = true where id in (5, 12, 15, 48);
----------------------------------------------------------------------
-- (primary cell: tissue + cell_type) or cell_line
insert into attrs (name, widget_id, owner, new) values ('primaryORline', 8, 'sample', true);
insert into attrs (name, widget_id, owner, new) values ('tissue', 5, 'sample', true);
insert into attrs (name, widget_id, owner, new) values ('cell type', 5, 'sample', true);
insert into attrs (name, widget_id, owner, new) values ('cell line', 5, 'sample', true);
--radio priamry cell or cell line
insert into attr_values (name, attr_id) values ('primary cell', 52), ('cell line', 52);
-- tissue
insert into attr_values (name, attr_id) (select distinct name, 53 from attr_values where id in (34,150,136,9,32,11,25,85,50,54,46,139,4,35,6,60,156,30,105,134,119,113,148,44,159,101,82,114,77,138,47,127,5,117));
-- unify 2 same values
update attr_values set name = 'C2C12' where id in (21, 69);
--cell line
insert into attr_values (name, attr_id) (select distinct name, 55 from attr_values where id in (69,21,26,157,87,132,67,133,68,123,27,14,140,88));
-- cell type
insert into attr_values (name, attr_id) (select distinct name, 54 from attr_values where id in (153,111,41,75,98,45,142,56,2,33,78,51));
-- not known for sure. Classified as cell type
insert into attr_values (name, attr_id) (select distinct name, 54 from attr_values where id in (1, 8, 96, 100));

-- croos-table for tissue, cell line, cell type fields
insert into attr_values_samples select sample_id, av2.id from attr_values_samples as avs, attr_values as av, attr_values as av2 where avs.attr_value_id = av.id and av.name = av2.name and av2.attr_id in (53,54,55);

-- cross table for primaryORline field
insert into attr_values_samples select sample_id, 646 from attr_values_samples as avs, attr_values as av where avs.attr_value_id = av.id and av.attr_id in (55);
insert into attr_values_samples select sample_id, 645 from attr_values_samples as avs, attr_values as av where avs.attr_value_id = av.id and av.attr_id in (53, 54);
-- deprecate old fields
update attrs set deprecated = true where id in (4,6,8,16);
--check that "primary cell" do not intersect with "cell line"
select * from attr_values_samples where attr_value_id = 645 and sample_id in (select sample_id from attr_values_samples where attr_value_id = 646);
------------------------------------------------------------
-- update exp_types 'BioScript analysis'->MNase-seq and 'HTSstation/ChIP-seq analysis' -> ChIP-seq
-- sample_id 857
update samples set exp_type = 'MNase-seq' where id = 857; 
-- sample_id 424 425 1730 1731
update samples set exp_type = 'ChIP-seq' where exp_type  = 'HTSstation/ChIP-seq analysis';



----------------------------------------------------------------------------------------------
-- new schema
create table exps (
    id serial not null primary key,
    created_at timestamp not null,
    user_id integer not null,
    exp_type_id integer not null,
    project_id integer not null
);
alter table exps add foreign key (exp_type_id) references exp_types;-- on delete cascade;
alter table exps add foreign key (user_id) references users; -- on delete cascade;
alter table exps add foreign key (project_id) references projects;-- on delete cascade;

insert into exps (created_at, user_id, exp_type_id, project_id)  (select localtimestamp, p.user_id, et.id, project_id from samples as s join projects as p on p.id = s.project_id join exp_types as et on et.name = s.exp_type group by project_id, et.id, p.user_id);

-- created and fill cross-table
create table exps_projects (
    exp_id integer not null,
    project_id integer not null
);

alter table exps_projects add foreign key (exp_id) references exps on delete cascade;
alter table exps_projects add foreign key (project_id) references projects on delete cascade;
insert into exps_projects select id, project_id from exps;

-- add exp_id to samples
alter table samples add column exp_id integer;
alter table samples add foreign key (exp_id) references exps;

update samples set exp_id = (select e.id from exps as e, exp_types as et where e.exp_type_id = et.id and e.project_id = samples.project_id and samples.exp_type = et.name);
-- cross table attrs and exp_types for samples
insert into attrs_exp_types select a.id as aid, et.id as etid from exp_types as et, samples as s, attrs as a, attr_values as av, attr_values_samples as avs where et.name = s.exp_type and a.id = av.attr_id and av.id = avs.attr_value_id and avs.sample_id = s.id and a.owner = 'sample' and (deprecated is false or deprecated is null) group by et.id, s.exp_type, a.id, a.name order by exp_type, a.id;

-- cross table attrs and exp_types for measurements 
insert into attrs_exp_types select a.id, et.id from exp_types as et, measurements as m, samples as s, attrs as a, attr_values as av, attr_values_measurements as avm, measurements_samples as ms where a.id = av.attr_id and av.id = avm.attr_value_id and avm.measurement_id = m.id and m.id = ms.measurement_id and ms.sample_id = s.id and  (deprecated is false or deprecated is null) and a.owner = 'measurement' and s.exp_type = et.name group by et.id,s.exp_type,  a.id, a.name order by et.name, a.id;
-- add assembly for 4C and DNAse1
insert into attrs_exp_types values (38, 14), (38,7);

-----------------------------------------------
alter table projects add column key varchar(6);
alter table exps add column name text;



-------------------------------------------------
-- for batch upload separator symbol |
update attr_values set name = 'Anti-RNA polymerase II Antibody, clone CTD4H8; 05-623 (Millipore)' where id = 376;


alter table measurements add column fu_id integer;
alter table measurements add foreign key (fu_id) references fus;
