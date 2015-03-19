root = exports ? this

export color_map = {}

export edge_color_map = {}

#export colors = d3.scale.category10()
export colors = (idx) ->
  switch idx
  | 0 => \#1f77b4
  | 1 => \#ff7f0e
  | 2 => \#2ca02c
  | 3 => \#d62728
  | 4 => \#9467bd
  | 5 => \#8c564b
  | 6 => \#e377c2
  | 7 => \#7f7f7f
  | 8 => \#bcbd22
  | 9 => \#17becf
  | _ => \#999999

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

export getcolorforrelation = (relation) ->
  relation_idx = relation_types.indexOf(relation)
  if relation_idx == -1
    return '#999999'
  else
    return colors(relation_idx)

export getedgecolor = (source, target) ->
  if edge_color_map[source]?
    if edge_color_map[source][target]?
      return edge_color_map[source][target]
  if Object.keys(edge_color_map).length == 0
    edge_relation = getedgerelation source, target
    return getcolorforrelation edge_relation
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

export getnoderadius_bing = (name) ->
  #Math.log rawdata[name]['num bing results']
  radius = getnoderadius_bing_raw(name)
  if radius?
    return Math.log radius
  return null

export getnoderadius_bing_raw = (name) ->
  output = rawdata[name]['num bing results']
  if output?
    return output
  return root.topic_to_bing_count[name]

export getnoderadius_stackoverflow = (name) ->
  radius = getnoderadius_stackoverflow_raw(name)
  if radius?
    return Math.log radius
  return null

export getnoderadius_stackoverflow_raw = (name) ->
  return rawdata[name]['num stackoverflow results']

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
