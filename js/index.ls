root = exports ? this

filter_nodes_by_topic = (focus_topic) ->
  data = root.rawdata
  output = {}
  whitelist = {}
  for x in list_all_related_node_names_recursive(focus_topic)
    whitelist[x] = true
  whitelist[focus_topic] = true
  for topic_name,topic_info of data
    if whitelist[topic_name]?
      output[topic_name] = topic_info
  return output

create_legend = ->
  for relation,idx in root.relation_types
    edgelegend = $('<div>')
    edgelegend.css {
      'background-color': colors(idx)
      width: '10px'
      height: '10px'
      'border-radius': '10px'
      float: 'left'
      'margin-right': '5px'
    }
    $('#edgetypes').append $('<div>').text(relation).append(edgelegend)

$(document).ready ->
  root.params = params = getUrlParameters()
  if params.relation_types?
    root.relation_types = jsyaml.safeLoad params.relation_types
  graph_file = params.graph_file ? 'graph.yaml'
  root.focus_topic = focus_topic = params.topic
  prev_topic = params.prevtopic
  $.get graph_file, (yamltxt) ->
    data = jsyaml.safeLoad(yamltxt)
    data = preprocess_data data
    root.rawdata = data
    #console.log data
    create_legend()
    if focus_topic? and focus_topic.length > 0
      parent_names = list_parent_names(focus_topic)
      root.rawdata = data = filter_nodes_by_topic(focus_topic)
      $('#focustopic').text(focus_topic)
      $('#parentslist').html('')
      if parent_names.length > 0
        for parent_name in parent_names
          $('#parentslist').append $('<a>').attr({
            href: '/?' + $.param({topic: parent_name})
          }).text(parent_name)
          $('#parentslist').append ' '
    nodes = {}
    for topic_name,topic_info of data
      if not nodes[topic_name]?
        nodes[topic_name] = {
          name: topic_name
        }
      for relation in root.relation_types
        connected_nodes = topic_info[relation]
        if connected_nodes?
          for name in connected_nodes
            if not nodes[name]?
              nodes[name] = {
                name: name
              }
    links = []
    for topic_name,topic_info of data
      for relation in root.relation_types
        connected_nodes = topic_info[relation]
        if connected_nodes?
          for name in connected_nodes
            links.push {
              source: nodes[topic_name]
              target: nodes[name]
              relation: relation
            }
    root.rawdata = data
    root.nodes = nodes
    root.links = links
    get_bing_counts data, (counts) ->
      for topic_name,count of counts
        root.topic_to_bing_count[topic_name] = count
      renderLinks(nodes, links)
