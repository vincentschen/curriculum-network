require! {
  yamlfile
  asyncblock
  bing_count
}

blacklist = ['relation_types']

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
        bing_count '"' + topic_name + '"', (count) ->
          topic_info['num bing results'] = count
          callback()
      addbingcount topic_name, topic_info, flow.add()
      console.log 'calling addbingcount on ' + topic_name
      flow.wait()
    yamlfile.write outfile, network
main()
