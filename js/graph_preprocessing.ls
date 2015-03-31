export add_children_for_parents = (data) ->
  network = {[x,({} <<< y)] for x,y of data}
  for topic_name,topic_info of network
    {parents} = topic_info
    if parents?
      for parent in parents
        if not network[parent]?
          network[parent] = {}
        if not network[parent].children?
          network[parent].children = []
        network[parent].children.push topic_name
  return network

export add_parents_for_children = (data) ->
  network = {[x,({} <<< y)] for x,y of data}
  for topic_name,topic_info of network
    {children} = topic_info
    if children?
      for child in children
        if not network[child]?
          network[parent] = {}
        if not network[child].parents?
          network[child].parents = []
        network[child].parents.push topic_name
  return network

export convert_parents_to_children = (data) ->
  data = reverse_edge_direction 'parents', data
  data = rename_edge_type 'parents', 'children', data
  return data

export convert_children_to_parents = (data) ->
  data = reverse_edge_direction 'children', data
  data = rename_edge_type 'children', 'parents', data
  return data

export preprocessing_options = {
  convert_parents_to_children
  convert_children_to_parents
  add_children_for_parents
  add_parents_for_children
}

export rename_edge_type = (orig_name, new_name, data) ->
  output = {}
  for topic_name,topic_info of data
    topic_info = {} <<< topic_info
    if topic_info[orig_name]?
      if not topic_info[new_name]?
        topic_info[new_name] = []
      topic_info[new_name] = topic_info[new_name] ++ topic_info[orig_name]
      delete topic_info[orig_name]
    output[topic_name] = topic_info
  return output

export reverse_edge_direction = (edge_type, data) ->
  output = {}
  for topic_name,topic_info of data
    topic_info = {} <<< topic_info
    topic_info[edge_type] = []
    output[topic_name] = topic_info
  for topic_name,topic_info of data
    if topic_info[edge_type]?
      for child in topic_info[edge_type]
        if not output[child]?
          output[child] = {}
          output[child][edge_type] = []
        output[child][edge_type].push topic_name
  return output
