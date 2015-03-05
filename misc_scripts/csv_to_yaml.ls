require! {
  fs
  'read-each-line'
  'js-yaml'
}

output = {}

readEachLine 'graph.csv', (line) ->
  line = line.trim()
  if line == 'source,target,value'
    return
  [source,target,value] = line.split(',')
  value = parseFloat value
  if output[source]?
    output[source].children.push target
  else
    output[source] = {
      children: [target]
    }

fs.writeFileSync 'graph.yaml', jsYaml.safeDump(output)
