root = exports ? this

$(document).ready ->
  params = getUrlParameters()
  topic = params.topic
  if not topic?
    $('#curriculum').text 'need to provide topic'
    return
  output = []
  graph_file = params.graph_file ? 'graph.yaml'
  $.get graph_file, (yamltxt) ->
    root.rawdata = data = create_terminal_nodes jsyaml.safeLoad(yamltxt)
    for x in list_all_related_node_names_recursive topic
      output.push x
    for item in output
      $('#curriculum').append $('<div>').text(item)
