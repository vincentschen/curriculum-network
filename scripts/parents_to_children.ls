require! {
  yamlfile
}

blacklist = ['graph_metadata']

main = ->
  infile = process.argv[2]
  outfile = process.argv[3]
  if not infile?
    console.log 'need infile'
    return
  if not outfile?
    console.log 'need outfile'
    return
  network = yamlfile.read process.argv[2]
  for topic_name,topic_info of network
    {parents} = topic_info
    if parents?
      for parent in parents
        if not network[parent]?
          network[parent] = {}
        if not network[parent].children?
          network[parent].children = []
        network[parent].children.push topic_name
  for topic_name,topic_info of network
    if topic_info.parents?
      delete topic_info.parents
  yamlfile.write outfile, network

main()