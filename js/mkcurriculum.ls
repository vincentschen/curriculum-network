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

create_node_display = (name) ->
  output = $('<div>')
    .text(name)
    .addClass(toclassname(name))
    .addClass('needtooltip')
    .addClass('roundedbox')
    .attr({
      depth: -1
      'data-toggle': 'tooltip'
      'title': $('<div>').css('text-align', 'left').html((["importance: #{getnoderadius_percent(name).toPrecision(2)}"] ++ jsyaml.safeDump(root.rawdata[name]).split('\n')).join('<br>')).0.outerHTML
    })
  return output

insert_module_topic = (name) ->
  output = create_node_display(name)
    .attr({
      depth: -1
    })
    .css({
      'margin-left': '0px'
      'background-color': '#800000'
    })
  $('#curriculum').append $('<div>').append(output)

insert_root_topic = (name) ->
  output = create_node_display(name)
    .attr({
      depth: 0
    })
    .css({
      'margin-left': "20px"
      'background-color': 'black'
    })
  $('#curriculum').append $('<div>').append(output)

insert_child_topic = (name, relation, depth, parent) ->
  output = create_node_display(name)
    .attr({
      depth: depth
    })
    .css({
      'margin-left': "#{(depth+1)*20}px"
      'background-color': getcolorforrelation(relation)
    })
  #$('#curriculum').append $('<div>').append(output)
  $('<div>').append(output).insertAfter $('.' + toclassname(parent))

parent_dep_sorting_func_increasing = (a, b) ->
  relation_order = <[ parents depends ]>
  relation_diff = relation_order.indexOf(a.relation) - relation_order.indexOf(b.relation)
  if relation_diff != 0
    return relation_diff
  return getnoderadius_percent(a.name) - getnoderadius_percent(b.name)

parent_dep_sorting_func_decreasing = (a, b) ->
  return -parent_dep_sorting_func_increasing(a, b)

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
    for {name, relation, depth, parent} in parents_and_depends.filter((x) -> x.depth == cur_depth).sort(parent_dep_sorting_func_decreasing)
      insert_child_topic name, relation, depth, parent
    #for x in list_all_related_node_names_recursive topic
    #  output.push x
    #for item in output
    #  $('#curriculum').append $('<div>').text(item)
  $('.needtooltip').tooltip({html: true, placement: 'right'})
