require! {
  yamlfile
  asyncblock
  bing_count
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
  asyncblock (flow) ->
    for let topic_name,topic_info of network
      #if topic_info['num bing results']?
      #  return
      if blacklist.indexOf(topic_name) != -1
        return
      addbingcount = (topic_name, topic_info, callback) ->
        query = '"' + topic_name + '"'
        if topic_info.tags?
          query = [('"' + x + '"') for x in topic_info.tags].join(' ')
        bing_count query, (count) ->
          topic_info['num bing results'] = count
          callback()
      addbingcount topic_name, topic_info, flow.add()
      console.log 'calling addbingcount on ' + topic_name
      flow.wait()
    yamlfile.write outfile, network
main()
