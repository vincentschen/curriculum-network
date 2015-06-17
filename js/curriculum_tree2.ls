root = exports ? this

{maximum} = require('prelude-ls')

export showquizzes = ->
  $('.showlessonbutton').removeClass 'active'
  $('#showquizzesbutton').addClass 'active'
  name = root.viewed_topic
  if root.rawdata[name]?
    {quiz, quizlink} = root.rawdata[name]
    if quizlink?
      $('#lessondiv').hide()
      $('#lessonframe').show()
      $('#lessonframe').attr('src', quizlink)
      return
    if quiz?
      $('#lessonframe').hide()
      $('#lessondiv').show()
      $('#lessondiv').html quiz
      return
  $('#lessonframe').hide()
  $('#lessondiv').show()
  $('#lessondiv').text("Sorry, we don't yet have quizzes for #{name}")

export showsummary = ->
  $('.showlessonbutton').removeClass 'active'
  $('#showsummarybutton').addClass 'active'
  name = root.viewed_topic
  $('#topicname').text name
  $('#makefocustopic').attr 'href', '/mkcurriculum.html?' + $.param({topic: name})
  $('#viewnetwork').attr 'href', '/?' + $.param({topic: name})
  if root.rawdata[name]?
    {summary, summarylink, link} = root.rawdata[name]
    if summary?
      $('#lessonframe').hide()
      $('#lessondiv').show()
      $('#lessondiv').text summary
      return
    if summarylink?
      $('#lessondiv').hide()
      $('#lessonframe').show()
      $('#lessonframe').attr('src', summarylink)
      return
    if link?
      $('#lessondiv').hide()
      $('#lessonframe').show()
      $('#lessonframe').attr('src', link)
      return
    #if lesson?
    #  $('#lessonframe').hide()
    #  $('#lessondiv').show()
    #  $('#lessondiv').text lesson
    #  return
  $('#lessonframe').hide()
  $('#lessondiv').show()
  $('#lessondiv').text("Sorry, we don't yet have a lesson for #{name}")

export showwikipedia = ->
  $('.showlessonbutton').removeClass 'active'
  $('#showwikipediabutton').addClass 'active'
  name = root.viewed_topic
  $('#topicname').text name
  $('#makefocustopic').attr 'href', '/mkcurriculum.html?' + $.param({topic: name})
  $('#viewnetwork').attr 'href', '/?' + $.param({topic: name})
  if root.rawdata[name]?
    {link} = root.rawdata[name]
    if link?
      $('#lessondiv').hide()
      $('#lessonframe').show()
      $('#lessonframe').attr('src', link)
      return
    #if lesson?
    #  $('#lessonframe').hide()
    #  $('#lessondiv').show()
    #  $('#lessondiv').text lesson
    #  return
  $('#lessonframe').hide()
  $('#lessondiv').show()
  $('#lessondiv').text("Sorry, we don't yet have a lesson for #{name}")

export nodehovered = (name) ->
  if name?
    root.viewed_topic = name
  showsummary()

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
  $('#moduleviewbutton').text('View Module for ' + topic_name)
  if root.rawdata[topic_name].children?
    $('#moduleviewbutton').show()
  else
    $('#moduleviewbutton').hide()
  $('#curriculumviewbutton').text('View Prerequisites for ' + topic_name)
  $('#curriculumviewbutton').show()
  root.viewed_topic = topic_name
  repaint_nodes()
  #showwikipedia()
  showsummary()

initialize = (treeData, max_depth, is_module) ->
  if not is_module?
    is_module = false
  # Create a svg canvas
  $('#curriculum').html('')
  canvas_width = max_depth * 250
  canvas_height = 100
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
      if is_module then d.y else (canvas_width - d.y)
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
        return colors(0)
    #colors(2)
    #null
    */
    'black'
  ).style('stroke-opacity', (d) ->
    0.2
  )
  node = vis.selectAll('g.node').data(nodes).enter().append('svg:g').attr('transform', (d) ->
    'translate(' + (if is_module then d.y else (canvas_width - d.y)) + ',' + d.x + ')'
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

export show_curriculum_view = (topic) ->
  if not topic?
    topic = root.viewed_topic
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
    for {name, relation, depth, parent} in parents_and_depends.filter((x) -> x.depth == cur_depth)#.sort(parent_dep_sorting_func)
      if name_to_treedata[name]?
        continue
      parent_node = name_to_treedata[parent]
      parent_node.children.push {
        name: name
        children: []
      }
      name_to_treedata[name] = parent_node.children[*-1]
  initialize treeData, max_depth
  set_topic topic
  next_topic()
  new_url = location.href
  if new_url.indexOf('?') != -1
    new_url = new_url.slice(0, new_url.indexOf('?'))
  new_url = new_url + '?' + $.param({view: 'curriculum', topic: topic, graph_file: root.params.graph_file})
  if new_url != history.state
    history.pushState new_url, null, new_url

makeModuleTreeData = (topic) ->
  treeData = {
    name: topic
    children: []
  }
  name_to_treedata = {}
  name_to_treedata[topic] = treeData
  agenda = []
  if root.rawdata[topic] and root.rawdata[topic].children?
    for child in root.rawdata[topic].children
      agenda.push [child, topic]
  while agenda.length > 0
    [curtopic, parent] = agenda.shift() # shift() gets first element (breadth-first), pop() gets last element (depth-first)
    if name_to_treedata[curtopic]?
      continue
    parent_tree = name_to_treedata[parent]
    parent_tree.children.push {
      name: curtopic
      children: []
    }
    name_to_treedata[curtopic] = parent_tree.children[*-1]
    if root.rawdata[curtopic].children?
      for child in root.rawdata[curtopic].children
        agenda.push [child, curtopic]
  return treeData

computeMaxDepth = (treeData) ->
  if treeData.children.length == 0
    return 0
  return 1 + maximum([computeMaxDepth(x) for x in treeData.children])

export show_module_view = (topic) ->
  if not topic?
    topic = root.viewed_topic
  export treeData = makeModuleTreeData(topic)
  max_depth = computeMaxDepth treeData
  initialize treeData, max_depth, true
  set_topic topic
  next_topic()
  new_url = location.href
  if new_url.indexOf('?') != -1
    new_url = new_url.slice(0, new_url.indexOf('?'))
  new_url = new_url + '?' + $.param({view: 'module', topic: topic})
  if new_url != history.state
    history.pushState new_url, null, new_url

window.addEventListener 'popstate', (e) ->
  console.log location.pathname
  load_page()

load_page = ->
  root.params = params = getUrlParameters()
  #topic = 'Mergesort'
  topic = params.topic
  view = params.view
  if not view?
    view = 'curriculum'
  if not topic?
    $('#curriculum').text 'need to provide topic'
    return
  if not root.rawdata[topic]?
    $('#curriculum').text 'topic does not exist: ' + topic
    return
  if view == 'module'
    show_module_view topic
  else
    show_curriculum_view topic

$(document).ready ->
  console.log 'document ready'
  root.params = params = getUrlParameters()
  #topic = 'Mergesort'
  topic = params.topic
  if not topic?
    $('#curriculum').text 'need to provide topic'
    return
  output = []
  graph_file = params.graph_file ? 'graph.yaml'
  yamltxt <- $.get graph_file
  console.log 'preprocess'
  root.rawdata = data = preprocess_data jsyaml.safeLoad(yamltxt)
  console.log 'rawdata fininshed'
  counts <- get_bing_counts data
  for topic_name,count of counts
    root.topic_to_bing_count[topic_name] = count
  load_page()

