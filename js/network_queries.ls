{unique} = require 'prelude-ls'

/*
export list_relation_recursive = (property, name) ->
  output = []
  if not rawdata[name]? or not rawdata[name][property]?
    return output
  for child in rawdata[name][property]
    output.push {
      child: child
      source: name
    }
    for descendant in list_relation_recursive(property, child)
      output.push descendant
  return output
*/

export list_relation_recursive = (property, name, output_set) ->
  if not output_set?
    output_set = {}
  if not rawdata[name]? or not rawdata[name][property]?
    return []
  #if output_set[name]?
  #  return []
  for child in rawdata[name][property]
    if not output_set[child]?
      output_set[child] = {
        child: child
        source: name
      }
      list_relation_recursive(property, child, output_set)
  return [v for k,v of output_set]

export list_parent_names = (name) ->
  output = []
  for topic_name,topic_info of rawdata
    {children} = topic_info
    if children?
      if children.indexOf(name) != -1
        output.push topic_name
  return output

export list_all_related_node_names_recursive = (name, output_set) ->
  #return (list_children_names_recursive(name) ++ list_depends_names_recursive(name) ++ list_suggests_names_recursive(name)) |> unique
  if not output_set?
    output_set = {}
  if not rawdata[name]?
    return []
  if output_set[name]?
    return []
  output_set[name] = true
  for property in ['children', 'depends', 'suggests']
    related_nodes = rawdata[name][property]
    if related_nodes?
      for child in related_nodes
        if not output_set[child]?
          list_all_related_node_names_recursive(child, output_set)
  return Object.keys(output_set)

export list_children_recursive = (name) ->
  list_relation_recursive 'children', name

export list_children_names_recursive = (name) ->
  list_children_recursive(name).map (.child)

export list_depends_recursive = (name) ->
  list_relation_recursive 'depends', name

export list_depends_names_recursive = (name) ->
  list_depends_recursive(name).map (.child)

export list_suggests_recursive = (name) ->
  list_relation_recursive 'suggests', name

export list_suggests_names_recursive = (name) ->
  list_suggests_recursive(name).map (.child)
