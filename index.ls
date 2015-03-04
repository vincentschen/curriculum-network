$(document).ready ->
  $.get 'graph.yaml', (yamltxt) ->
    data = jsyaml.safeLoad(yamltxt)
    links = []
    for topic_name,topic_info of data
      for {name,value} in topic_info.children
        links.push {
          source: topic_name
          target: name
          value: value
        }
    renderLinks(links)
