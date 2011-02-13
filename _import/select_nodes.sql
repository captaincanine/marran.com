SELECT 
  node.nid, 
  node.title, 
  node_revisions.body, 
  node_revisions.teaser,
  node.created, 
  node.status, 
  (select dst from url_alias where src = CONCAT('node/', node.nid)) as 'path', 
  (select field_teaser_image_url from content_field_teaser_image where nid = node.nid and vid = node.vid) as 'image' 
FROM node, node_revisions WHERE (node.type = 'blog' OR node.type = 'story') AND node.vid = node_revisions.vid
