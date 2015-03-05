root = exports ? this

export relation_types = ['children', 'depends', 'suggests']

export getUrlParameters = ->
  url = window.location.href
  hash = url.lastIndexOf('#')
  if hash != -1
    url = url.slice(0, hash)
  map = {}
  parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    map[key] = decodeURI(value).split('+').join(' ') # for whatever reason this seems necessary?
  )
  return map

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

create_terminal_nodes = (data) ->
  output = {}
  for topic_name,topic_info of data
    output[topic_name] = topic_info
  for topic_name,topic_info of data
    for relation in relation_types
      connected_nodes = topic_info[relation]
      if connected_nodes?
        for name in connected_nodes
          if not output[name]?
            output[name] = {}
  return output

$(document).ready ->
  params = getUrlParameters()
  root.focus_topic = focus_topic = params.topic
  prev_topic = params.prevtopic
  $.get 'graph.yaml', (yamltxt) ->
    data = create_terminal_nodes jsyaml.safeLoad(yamltxt)
    root.rawdata = data
    if focus_topic? and focus_topic.length > 0
      parent_names = list_parent_names(focus_topic)
      root.rawdata = data = filter_nodes_by_topic(focus_topic)
      toptext = $('<span>').css {
        position: 'fixed'
        left: '0px'
        top: '0px'
        'z-index'
        'font-size': '20px'
      }
      toptext.append $('<span>').text 'Focus topic: ' + focus_topic
      toptext.append '<br>'
      if parent_names.length > 0
        toptext.append 'Parents: '
        for parent_name in parent_names
          toptext.append $('<a>').attr({
            href: '/?' + $.param({topic: parent_name})
          }).text(parent_name)
          toptext.append ' '
        toptext.append '<br>'
      toptext.append $('<a>').attr({
        href: '/'
      }).text('View the full network')
      $('body').append toptext
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
