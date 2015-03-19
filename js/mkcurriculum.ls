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

export nodehovered = (name) ->
  $('#topicname').text name
  $('#makefocustopic').attr 'href', '/mkcurriculum.html?' + $.param({topic: name})
  $('#viewnetwork').attr 'href', '/?' + $.param({topic: name})
  if root.rawdata[name]?
    {link, lesson} = root.rawdata[name]
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
  output = create_node_display(name)
    .data({
      depth: -1
    })
    .css({
      'margin-left': '0px'
      'background-color': '#800000'
    })
  $('#curriculum').append $('<div>').append(output)

insert_root_topic = (name) ->
  output = create_node_display(name)
    .data({
      depth: 0
    })
    .css({
      'margin-left': "20px"
      'background-color': 'black'
    })
  $('#curriculum').append $('<div>').append(output)

insert_child_topic = (name, relation, depth, parent) ->
  output = create_node_display(name)
    .data({
      depth: depth
      parentname: parent
    })
    .css({
      'margin-left': "#{(depth+1)*20}px"
      'background-color': getcolorforrelation(relation)
    })
  #$('#curriculum').append $('<div>').append(output)
  $('<div>').append(output).insertAfter $('.' + toclassname(parent))

parent_dep_sorting_func = (a, b) ->
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
  for module_name in list_modules_node_is_part_of(topic)
    insert_module_topic module_name
  insert_root_topic topic
  parents_and_depends = list_parents_and_depends_recursive topic
  max_depth = parents_and_depends.map (.depth) |> maximum
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
