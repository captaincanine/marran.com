select tn.nid, td.tid, td.name,
(select tp.name from term_hierarchy inner join term_data tp on tp.tid = term_hierarchy.parent where td.tid = term_hierarchy.tid) as parent
from term_data td 
inner join term_node tn on td.tid = tn.tid;

--select * from node where title like '%chicken%';

--select * from term_hierarchy where tid in (513, 519);