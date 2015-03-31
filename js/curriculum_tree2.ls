root = exports ? this

{maximum} = require('prelude-ls')

parent_dep_sorting_func = (a, b) ->
  return -parent_dep_sorting_func_simple(a, b)
  if root.visformat == 1 or root.visformat == 2
    return -parent_dep_sorting_func_real(a, b)
  return parent_dep_sorting_func_real(a, b)

parent_dep_sorting_func_simple = (a, b) ->
  bradius = getnoderadius_percent(b.name)
  aradius = getnoderadius_percent(a.name)
  if aradius > bradius
    return 1
  if bradius > aradius
    return -1
  return 0

parent_dep_sorting_func_real = (a, b) ->
  relation_order = <[ parents depends ]>
  relation_diff = relation_order.indexOf(a.relation) - relation_order.indexOf(b.relation)
  if relation_diff != 0
    return -relation_diff
  bradius = getnoderadius_percent(b.name)
  aradius = getnoderadius_percent(a.name)
  if aradius > bradius
    return 1
  if bradius > aradius
    return -1
  return 0

root.viewed_topic = ''
root.learned_topics = {}

export is_learnable = (topic_name) ->
  {parents, depends} = rawdata[topic_name]
  if parents?
    for x in parents
      if not root.learned_topics[x]?
        return false
  if depends?
    for x in depends
      if not root.learned_topics[x]?
        return false
  return true

export repaint_nodes = ->
  topic_name = root.viewed_topic
  for x in $('.topicname')
    curname = $(x).text()
    if curname == topic_name
      $(x).css('font-weight', 'bold')
    else
      $(x).css('font-weight', 'normal')
  for x in $('.topicnode')
    curname = $(x).attr('data-topicname')
    if root.learned_topics[curname]?
      $(x).css('fill', 'green')
    else if is_learnable(curname)
      $(x).css('fill', 'blue')

export next_topic = ->
  available_topics = []
  for x in $('.topicname')
    curname = $(x).text()
    if not root.learned_topics[curname] and is_learnable(curname)
      available_topics.push curname
  available_topics.sort (a, b) ->
    bradius = getnoderadius_percent(b)
    aradius = getnoderadius_percent(a)
    if aradius > bradius
      return 1
    if bradius > aradius
      return -1
    return 0
  if available_topics.length > 0
    set_topic available_topics[*-1]
  else
    repaint_nodes()

export topicfinished = ->
  root.learned_topics[root.viewed_topic] = true
  next_topic()

export set_topic = (topic_name) ->
  $('#topicdisplay').text topic_name
  $('#finishedbutton').text('Finished Learning ' + topic_name)
  $('#finishedbutton').show()
  root.viewed_topic = topic_name
  repaint_nodes()

initialize = (treeData, max_depth) ->
  # Create a svg canvas
  canvas_width = max_depth * 250
  canvas_height = 80
  vis = d3.select('#curriculum').append('svg:svg').attr('width', (canvas_width + 300)).attr('height', (canvas_height)).append('svg:g').attr('transform', 'translate(10, 0)')
  # shift everything to the right
  #.attr("transform", "scale(1, -1)")
  #.attr("transform", "rotate(-180deg)")
  # Create a tree "canvas"
  tree = d3.layout.tree().size([
    canvas_height
    canvas_width
  ])
  diagonal = d3.svg.diagonal().projection((d) ->
    [
      canvas_width - d.y
      d.x
    ]
  )
  # Preparing the data for the tree layout, convert data into an array of nodes
  nodes = tree.nodes(treeData)
  # Create an array with all the links
  links = tree.links(nodes)
  #console.log treeData
  #console.log nodes
  #console.log links
  link = vis.selectAll('pathlink').data(links).enter().append('svg:path').attr('class', 'link').attr('d', diagonal).style('stroke', (d) ->
    #null
    /*
    source_name = d.source.name
    target_name = d.target.name
    console.log source_name + ',' + target_name
    target_children = root.rawdata[target_name].children
    if target_children?
      if target_children.indexOf(source_name) != -1
        return colors(1)
    source_depends = root.rawdata[source_name].depends
    if source_depends?
      if source_depends.indexOf(target_name) != -1
        return colors(2)
    */
    #colors(2)
    #null
    'black'
  ).style('stroke-opacity', (d) ->
    0.2
  )
  node = vis.selectAll('g.node').data(nodes).enter().append('svg:g').attr('transform', (d) ->
    'translate(' + (canvas_width - d.y) + ',' + d.x + ')'
  )
  # Add the dot at every node
  node.append('svg:circle').attr('r', 3.5).attr('class', 'topicnode').attr('data-topicname', (d) -> d.name).style('cursor', 'pointer').on('click', (d) ->
    set_topic d.name
  )
  # place the name atribute left or right depending if children
  node.append('svg:text').attr('dx', (d) ->
    #if d.children then 8 else -8
    8
  ).attr('dy', 3).attr('text-anchor', (d) ->
    #if d.children then 'start' else 'end'
    'start'
  ).text((d) ->
    d.name
  ).style('cursor', 'pointer').attr('class', 'topicname').on('click', (d) ->
    set_topic d.name
  )
  #repaint_nodes()
  next_topic()

$(document).ready ->
  root.params = params = getUrlParameters()
  #topic = 'Mergesort'
  topic = params.topic
  if not topic?
    $('#curriculum').text 'need to provide topic'
    return
  output = []
  graph_file = params.graph_file ? 'graph.yaml'
  yamltxt <- $.get graph_file
  root.rawdata = data = preprocess_data jsyaml.safeLoad(yamltxt)
  counts <- get_bing_counts data
  for topic_name,count of counts
    root.topic_to_bing_count[topic_name] = count
  if not data[topic]?
    $('#curriculum').text 'topic does not exist: ' + topic
    return
  root.all_parent_names = list_parent_names_recursive topic
  parents_and_depends = list_parents_and_depends_recursive topic
  if parents_and_depends.length == 0
    root.max_depth = max_depth = 0
  else
    root.max_depth = max_depth = parents_and_depends.map (.depth) |> maximum
  #parents_and_depends = list_parents_and_depends_recursive topic
  #console.log parents_and_depends
  export treeData = {
    name: topic
    children: []
  }
  export name_to_treedata = {}
  name_to_treedata[topic] = treeData
  for cur_depth in [0 to max_depth]
    for {name, relation, depth, parent} in parents_and_depends.filter((x) -> x.depth == cur_depth).sort(parent_dep_sorting_func)
      if name_to_treedata[name]?
        continue
      parent_node = name_to_treedata[parent]
      parent_node.children.push {
        name: name
        children: []
      }
      name_to_treedata[name] = parent_node.children[*-1]
      #insert_child_topic name, relation, depth, parent
  #JSON object with the data
  /*
  treeData = 
    'name': 'A654'
    'children': [
      { 'name': 'A1' }
      { 'name': 'A2' }
      { 'name': 'A2B' }
      {
        'name': 'A3'
        'children': [ {
          'name': 'A31'
          'children': [
            { 'name': 'A311' }
            { 'name': 'A312' }
          ]
        } ]
      }
    ]
  */
  initialize treeData, max_depth
