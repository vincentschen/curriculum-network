root = exports ? this

{maximum} = require('prelude-ls')

alphabet = [\a to \z] ++ [\A to \Z]
alphabet_set = {}
do ->
  for c in alphabet
    alphabet_set[c] = true

isalpha = (c) ->
  alphabet_set[c]?

toclassname = (name) ->
  return name.split('').filter(isalpha).join('')

export showquizzes = ->
  $('.showlessonbutton').removeClass 'active'
  $('#showquizzesbutton').addClass 'active'
  name = root.curnode_shown
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

export showwikipedia = ->
  $('.showlessonbutton').removeClass 'active'
  $('#showwikipediabutton').addClass 'active'
  name = root.curnode_shown
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
    if lesson?
      $('#lessonframe').hide()
      $('#lessondiv').show()
      $('#lessondiv').text lesson
      return
  $('#lessonframe').hide()
  $('#lessondiv').show()
  $('#lessondiv').text("Sorry, we don't yet have a lesson for #{name}")

export nodehovered = (name) ->
  if name?
    root.curnode_shown = name
  showwikipedia()


create_node_display = (name) ->
  tooltip_info = {importance: getnoderadius_percent(name).toPrecision(2)} <<< root.rawdata[name]
  tooltip_html = jsyaml.safeDump(tooltip_info).split('\n').join('<br>')
  output = $('<div>')
    .text(name)
    .addClass(toclassname(name))
    .addClass('needtooltip')
    .addClass('roundedbox')
    .attr({
      depth: -1
      'data-toggle': 'tooltip'
      'title': $('<div>').css('text-align', 'left').html(tooltip_html).0.outerHTML
      #'onclick': "nodehovered('#{name}')"
    })
    .click ->
      nodehovered(name)
  return output

insert_module_topic = (name) ->
  marginleft = 0
  if root.visformat == 2
    marginleft = 20 * (root.max_depth + 1)
  output = create_node_display(name)
    .css({
      'margin-left': "#{marginleft}px"
      'background-color': '#800000'
    })
  $('#curriculum').append $('<div>').append(output)

insert_root_topic = (name) ->
  marginleft = 20
  if root.visformat == 2
    marginleft = 20 * root.max_depth
  output = create_node_display(name)
    .data({
      depth: 0
    })
    .css({
      'margin-left': "#{marginleft}px"
      'background-color': 'black'
    })
  $('#curriculum').append $('<div>').append(output)

insert_child_topic = (name, relation, depth, parent) ->
  marginleft = (depth+1) * 20
  if root.visformat == 2
    marginleft = 20 * (root.max_depth - depth)
  relation_color = getcolorforrelation('depends')
  if root.all_parent_names.indexOf(name) != -1
    relation_color = getcolorforrelation('parents')
  output = create_node_display(name)
    .data({
      depth: depth
      parentname: parent
    })
    .css({
      'margin-left': "#{marginleft}px"
      'background-color': relation_color
    })
  #$('#curriculum').append $('<div>').append(output)
  if root.visformat == 1 or root.visformat == 2
    $('<div>').append(output).insertBefore $('.' + toclassname(parent))
  else
    $('<div>').append(output).insertAfter $('.' + toclassname(parent))

parent_dep_sorting_func = (a, b) ->
  if root.visformat == 1 or root.visformat == 2
    return -parent_dep_sorting_func_real(a, b)
  return parent_dep_sorting_func_real(a, b)

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

$(document).ready ->
  root.params = params = getUrlParameters()
  root.visformat = 0
  if root.params.visformat?
    new_visformat = parseInt root.params.visformat
    if isFinite new_visformat
      root.visformat = new_visformat
      localStorage.setItem 'visformat', new_visformat
  else
    stored_visformat = parseInt localStorage.getItem('visformat')
    if isFinite stored_visformat
      root.visformat = stored_visformat
  topic = params.topic
  if not topic?
    $('#curriculum').text 'need to provide topic'
    return
  output = []
  graph_file = params.graph_file ? 'graph.yaml'
  yamltxt <- $.get graph_file
  root.rawdata = data = create_terminal_nodes jsyaml.safeLoad(yamltxt)
  counts <- get_bing_counts data
  for topic_name,count of counts
    root.topic_to_bing_count[topic_name] = count
  if not data[topic]?
    $('#curriculum').text 'topic does not exist: ' + topic
    return
  root.all_parent_names = list_parent_names_recursive topic
  parents_and_depends = list_parents_and_depends_recursive topic
  root.max_depth = max_depth = parents_and_depends.map (.depth) |> maximum
  if root.visformat == 1 or root.visformat == 2
    insert_root_topic topic
    for module_name in list_modules_node_is_part_of(topic)
      insert_module_topic module_name
  else
    for module_name in list_modules_node_is_part_of(topic)
      insert_module_topic module_name
    insert_root_topic topic
  for cur_depth in [0 to max_depth]
    for {name, relation, depth, parent} in parents_and_depends.filter((x) -> x.depth == cur_depth).sort(parent_dep_sorting_func)
      insert_child_topic name, relation, depth, parent
    #for x in list_all_related_node_names_recursive topic
    #  output.push x
    #for item in output
    #  $('#curriculum').append $('<div>').text(item)
  seen_nodes = {}
  dup_nodes = {}
  for x in $('.roundedbox')
    curname = $(x).text()
    if seen_nodes[curname]?
      #$(x).hide() # hide duplicate nodes
      $(x).css 'background-color', '#666666'
      dup_nodes[curname] = true
      if dup_nodes[$(x).data('parentname')]?
        $(x).hide()
    seen_nodes[curname] = true
  $('.needtooltip').tooltip({html: true, placement: 'bottom'})
  nodehovered topic
