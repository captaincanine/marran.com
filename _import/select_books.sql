SELECT

  parent.nid as 'parent_nid',
  parent.title as 'parent_title',
  child.nid as 'child_nid',
  child.title as 'child_title'

FROM
  node as parent
  inner join book on parent.nid = book.bid
  inner join node as child on child.nid = book.nid