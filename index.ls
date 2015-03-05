root = exports ? this

export relation_types = ['children', 'depends', 'suggests']

$(document).ready ->
  $.get 'graph.yaml', (yamltxt) ->
    data = jsyaml.safeLoad(yamltxt)
    nodes = {}
    for topic_name,topic_info of data
      if not nodes[topic_name]?
        nodes[topic_name] = {
          name: topic_name
        }
      for relation in relation_types
        connected_nodes = topic_info[relation]
        if connected_nodes?
          for name in connected_nodes
            if not nodes[name]?
              nodes[name] = {
                name: name
              }
    links = []
    for topic_name,topic_info of data
      {children, depends} = topic_info
      for relation in relation_types
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
    renderLinks(nodes, links)
