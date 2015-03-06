export color_map = {}

export edge_color_map = {}

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

export setedgecolor = (source, target, color) ->
  if not edge_color_map[source]?
    edge_color_map[source] = {}
  edge_color_map[source][target] = color

export getedgecolor = (source, target) ->
  if edge_color_map[source]?
    if edge_color_map[source][target]?
      return edge_color_map[source][target]
  if Object.keys(edge_color_map).length == 0
    switch getedgerelation(source, target)
    | 'children' => '#0000aa'
    | 'depends' => '#00aa00'
    | 'suggests' => '#aa00aa'
    | _ => '#999999'
  else
    '#999999'

export getnodecolor = (name) ->
  return color_map[name] ? '#333333'

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
  color_map[name] = '#ff0000'
  # highlight children as blue
  for {child,source} in list_children_recursive(name)
    color_map[child] = '#0000ff'
    setedgecolor source, child, '#0000ff'
  # highlight dependents as green
  for {child,source} in list_depends_recursive(name)
    color_map[child] = '#00ff00'
    setedgecolor source, child, '#00ff00'
  # highlight suggests as purple
  for {child,source} in list_suggests_recursive(name)
    color_map[child] = '#ff00ff'
    setedgecolor source, child, '#ff00ff'
  recolor_all_nodes()
  recolor_all_edges()

export reset_coloring = ->
  color_map := {}
  edge_color_map := {}
  recolor_all_nodes()
  recolor_all_edges()
