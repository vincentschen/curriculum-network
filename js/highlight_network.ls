root = exports ? this

export color_map = {}

export edge_color_map = {}

export colors = d3.scale.category10()

/*
export getedgerelation = (source, target) ->
  if not rawdata[source]?
    return 'doesnotexist'
  {children, depends, suggests} = rawdata[source]
  if children? and children.indexOf(target) != -1
    return 'children'
  if depends? and depends.indexOf(target) != -1
    return 'depends'
  if suggests? and suggests.indexOf(target) != -1
    return 'suggests'
*/

export getedgerelation = (source, target) ->
  if not rawdata[source]?
    return 'doesnotexist'
  for relation_type in relation_types
    relations = rawdata[source][relation_type]
    if relations? and relations.indexOf(target) != -1
      return relation_type
  return 'doesnotexist'

export setedgecolor = (source, target, color) ->
  if not edge_color_map[source]?
    edge_color_map[source] = {}
  edge_color_map[source][target] = color

export getedgecolor = (source, target) ->
  if edge_color_map[source]?
    if edge_color_map[source][target]?
      return edge_color_map[source][target]
  if Object.keys(edge_color_map).length == 0
    edge_relation = getedgerelation source, target
    edge_relation_idx = relation_types.indexOf(edge_relation)
    if edge_relation_idx == -1
      return '#999999'
    else
      return colors(edge_relation_idx)
    /*
    switch getedgerelation(source, target)
    | 'children' => '#0000aa'
    | 'depends' => '#00aa00'
    | 'suggests' => '#aa00aa'
    | _ => '#999999'
    */
  else
    '#999999'

export getnodecolor = (name) ->
  return color_map[name] ? '#333333'

root.max_node_radius = null

getnoderadius_bing = (name) ->
  Math.log rawdata[name]['num bing results']

getnoderadius_stackoverflow = (name) ->
  Math.log rawdata[name]['num stackoverflow results']

getnoderadius_not_normalized = (name) ->
  switch params.radius_function
  | 'bing' => getnoderadius_bing(name)
  | 'stackoverflow' => getnoderadius_stackoverflow(name)
  | _ => getnoderadius_bing(name)

export getnoderadius_percent = (name) ->
  if root.max_node_radius == null
    for nodename,nodeinfo of rawdata
      cur_radius = getnoderadius_not_normalized(nodename)
      if cur_radius? and isFinite(cur_radius)
        root.max_node_radius = root.max_node_radius >? cur_radius
  return getnoderadius_not_normalized(name) / root.max_node_radius

export getnoderadius = (name) ->
  if not rawdata[name]?
    console.log 'do not have radius for: ' + name
    return 5
  radius_percent = getnoderadius_percent(name)
  if not isFinite(radius_percent)
    console.log 'do not have radius for: ' + name
    return 5
  return 10 * radius_percent

export getnode = (name) ->
  for x in $('.node')
    node = $(x)
    name = node.find('text').text()
    return node

export recolor_all_edges = ->
  for x in $('.link')
    edge = $(x)
    source = edge.attr 'source'
    target = edge.attr 'target'
    edge.css 'stroke', getedgecolor(source, target)

export recolor_all_nodes = ->
  for x in $('.node')
    node = $(x)
    name = node.find('text').text()
    circle = node.find('circle')
    circle.css 'fill', getnodecolor(name)

export node_highlighted = (name) ->
  color_map := {}
  edge_color_map := {}
  color_map[name] = colors(8) #'#ff0000'
  /*
  # highlight children as blue
  for {child,source} in list_children_recursive(name)
    color_map[child] = colors(0)#'#0000ff'
    setedgecolor source, child, colors(0) #'#0000ff'
  # highlight dependents as green
  for {child,source} in list_depends_recursive(name)
    color_map[child] = colors(1) #'#00ff00'
    setedgecolor source, child, colors(1)#'#00ff00'
  # highlight suggests as purple
  for {child,source} in list_suggests_recursive(name)
    color_map[child] = colors(2) #'#ff00ff'
    setedgecolor source, child, colors(2)#'#ff00ff'
  */
  for relation_type,relation_idx in relation_types
    for {child,source} in list_relation_recursive(relation_type, name)
      color_map[child] = colors(relation_idx)
      setedgecolor source, child, colors(relation_idx)
  recolor_all_nodes()
  recolor_all_edges()

export reset_coloring = ->
  color_map := {}
  edge_color_map := {}
  recolor_all_nodes()
  recolor_all_edges()
