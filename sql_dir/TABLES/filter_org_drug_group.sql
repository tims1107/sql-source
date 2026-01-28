
-- organism and drug filter
select * from micro_organism_filter
where regexp_like(organismname,'baci','i')
and valuetype = 'ORG';

-- group identified and CRE
select * from micro_organism_group;