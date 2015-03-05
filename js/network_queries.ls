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

export list_related_names_recursive = (name) ->
  list_related_recursive(name).map (.child)
