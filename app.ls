require! {
  express
  'serve-static'
  bing_count
  async
}

app = express()

app.use serveStatic '.'
app.set 'port', process.env.PORT ? 5000
app.listen app.get('port'), '0.0.0.0'

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
