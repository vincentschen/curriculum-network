root = exports ? this

export relation_types = ['depends', 'parents']

export topic_to_bing_count = {}

export getUrlParameters = ->
  url = window.location.href
  hash = url.lastIndexOf('#')
  if hash != -1
    url = url.slice(0, hash)
  map = {}
  parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    #map[key] = decodeURI(value).split('+').join(' ').split('%2C').join(',') # for whatever reason this seems necessary?
    map[key] = decodeURIComponent(value).split('+').join(' ') # for whatever reason this seems necessary?
  )
  return map

export preprocess_data = (data) ->
  {graph_metadata} = data
  if graph_metadata?
    {preprocessing_steps} = graph_metadata
    if graph_metadata.relation_types?
      root.relation_types = relation_types := graph_metadata.relation_types
      delete data.graph_metadata.relation_types
    if preprocessing_steps?
      for preprocessing_step in preprocessing_steps
        data = root.preprocessing_options[preprocessing_step](data)
      delete data.graph_metadata.preprocessing_steps
    delete data.graph_metadata
  #console.log data
  data = create_terminal_nodes data
  return data

export create_terminal_nodes = (data) ->
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

export get_bing_counts = (data, callback) ->
  topic_to_query = {}
  topic_to_counts = {}
  add_query_for_topic = (topic_name) ->
    if topic_to_query[topic_name]?
      return
    query = '"' + topic_name + '"'
    topic_info = data[topic_name]
    if topic_info?
      {tags} = topic_info
      if tags?
        query = [('"' + x + '"') for x in tags].join(' ')
    topic_to_query[topic_name] = query
  for topic_name,topic_info of data
    add_query_for_topic topic_name
    for relation_type in relation_types
      children = topic_name[relation_type]
      if children?
        for child in children
          add_query_for_topic child
  query_list = [v for k,v of topic_to_query]
  $.getJSON '/bingcounts?' + $.param({words: JSON.stringify(query_list)}), (results) ->
    for topic_name,query of topic_to_query
      count = results[query]
      topic_to_counts[topic_name] = count
    callback topic_to_counts
