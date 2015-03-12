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
