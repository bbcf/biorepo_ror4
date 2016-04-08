alter table "Attributs" RENAME to attrs;
alter table "Attributs_values" RENAME to attr_values;
alter table "Cross_meas_attributvalues" rename  to attr_values_measurements;
alter table "Cross_meas_fu" rename to "fus_measurements";
alter table "Cross_measurements" rename to measurement_rels;
alter table "Cross_measurement_attribut" rename to attrs_measurements;
alter table "Cross_projects_lab" rename to labs_projects;
alter table "Cross_sample_attribut" rename to attrs_samples;
alter table "Cross_sample_attributvalues" rename to attr_values_samples;
alter table "Cross_sample_measurement" rename to measurements_samples;
alter table "Cross_user_lab" rename to labs_users;
alter table "Files_up" rename to fus;
alter table "Group" rename to groups;
alter table "GroupPermissions" rename to group_permissions;
alter table "Labs" rename to labs;
alter table "Measurements" rename to measurements;
alter table "Permission" rename to permissions;
alter table "Projects" rename to projects;
alter table "Samples" rename to samples;
alter table "User" rename to users;
alter table "UserGroup" rename to groups_users;

alter sequence "Attributs_id_seq" rename to attrs_id_seq;
alter sequence "Attributs_values_id_seq" rename to attr_values_id_seq;
alter sequence "Files_up_id_seq" rename to fus_id_seq;
alter sequence "Group_id_seq" rename to groups_id_seq;
alter sequence "Labs_id_seq" rename to labs_id_seq;
alter sequence "Measurements_id_seq" rename to measurements_id_seq;
alter sequence "Permission_id_seq" rename to permissions_id_seq;
alter sequence "Projects_id_seq" rename to projects_id_seq;
alter sequence "User_id_seq" rename to users_id_seq;
alter sequence "Samples_id_seq" rename to samples_id_seq;

alter table samples rename type to exp_type;
alter table samples rename date to created_at;
alter table projects rename project_name to name;
alter table projects rename date to created_at;
alter table measurements rename date to created_at;
alter table attr_values rename attribut_id to attr_id;
alter table attrs_samples rename attribut_id to attr_id;
alter table attrs_measurements rename attribut_id to attr_id;
alter table attr_values_measurements rename attributvalues_id to attr_value_id;
alter table attr_values_samples rename attributvalues_id to attr_value_id;

ALTER INDEX "Attributs_pkey" RENAME TO attrs_pkey;
ALTER INDEX "Attributs_values_pkey" RENAME TO attr_values_pkey;
ALTER INDEX "Cross_meas_attributvalues_pkey" RENAME TO attr_values_measurements_pkey;
ALTER INDEX "Cross_meas_fu_pkey" RENAME TO fus_measurements_pkey;
ALTER INDEX "Cross_measurement_attribut_pkey" RENAME TO attrs_measurements_pkey;
ALTER INDEX "Cross_measurements_pkey" RENAME TO measurement_rels_pkey;
ALTER INDEX "Cross_projects_lab_pkey" RENAME TO labs_projects_pkey;
ALTER INDEX "Cross_sample_attribut_pkey" RENAME TO attrs_samples_pkey;
ALTER INDEX "Cross_sample_attributvalues_pkey" RENAME TO attr_values_samples_pkey;
ALTER INDEX "Cross_sample_measurement_pkey" RENAME TO measurements_samples_pkey;
ALTER INDEX "Cross_user_lab_pkey" RENAME TO labs_users_pkey;
ALTER INDEX "Files_up_pkey" RENAME TO fus_pkey;
ALTER INDEX "GroupPermissions_pkey" RENAME TO group_permissions_pkey;
ALTER INDEX "Group_pkey" RENAME TO groups_pkey;
ALTER INDEX "Labs_pkey" RENAME TO labs_pkey;
ALTER INDEX "Measurements_pkey" RENAME TO measurements_pkey;
ALTER INDEX "Permission_name_key" RENAME TO permissions_name_key;
ALTER INDEX "Permission_pkey" RENAME TO permissions_pkey;
ALTER INDEX "Projects_pkey" RENAME TO projects_pkey;
ALTER INDEX "Samples_pkey" RENAME TO samples_pkey;
ALTER INDEX "User_pkey" RENAME TO users_pkey;
ALTER INDEX "UserGroup_pkey" RENAME TO groups_users_pkey;
ALTER INDEX "User_key_key" RENAME TO users_key_key;
ALTER INDEX "User__email_key" RENAME TO users_email_key;

alter table users rename _email to email;
alter table users rename _created to created_at;
alter table groups rename _created to created_at;


-- alter table measurement_rels drop constraint measurement_rels_pkey;
-- alter table measurement_rels add column id serial;

alter table measurements rename type to raw;
alter table measurements rename status_type to public;


-- create new tables and columns

--alter table labs add column attr_list text;


