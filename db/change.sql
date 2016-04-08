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
