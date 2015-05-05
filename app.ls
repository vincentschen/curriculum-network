require! {
  express
  'serve-static'
  bing_count
  async
  marked
  fs
}

app = express()

app.use serveStatic '.'
app.set 'port', process.env.PORT ? 8080
app.listen app.get('port'), '0.0.0.0'

page_markdown = (name, callback) ->
  fs.exists name, (exists) ->
    if exists
      fs.readFile name, 'utf8', (err, results) -> callback(results)
    else
      callback null

page_html = (name, callback) ->
  page_markdown name, (mdata) ->
    if mdata == null
      callback(null)
    else
      callback marked(mdata)

app.get /^\/md\/(.+)/, (req, res) ->
  name = req.params[0]
  if name.indexOf('..') != -1
    res.send 'cannot have .. in path'
    return
  page_html name + '.md', (data) ->
    if not data?
      res.send 'article does not exist: ' + name
    else
      res.send data

app.get '/bingcounts', (req, res) ->
  {words} = req.query
  output = {}
  tasks = []
  if not words?
    res.json []
  words = JSON.parse words
  for let word in words
    tasks.push (callback) ->
      bing_count word, (count) ->
        output[word] = count
        callback(null, null)
  async.series tasks, ->
    res.json output
