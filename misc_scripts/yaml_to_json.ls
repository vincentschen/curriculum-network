require! {
  fs
  'js-yaml'
  'jsonfile'
}

jsonfile.writeFileSync 'graph.json', jsYaml.safeLoad(fs.readFileSync('graph.yaml', 'utf-8'))
