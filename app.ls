require! {
  express
  'serve-static'
  bing_count
  async
  marked
  fs
  path
}

{exec} = require('child_process')

app = express()

app.use serveStatic '.'
app.set 'port', process.env.PORT ? 8080
app.listen app.get('port'), '0.0.0.0'

to-seconds = (timestamp) ->
  if typeof(timestamp) == typeof(0)
    return timestamp
  if timestamp.indexOf(':') == -1
    return parseFloat timestamp
  [minutes,seconds] = timestamp.split(':')
  minutes = parseFloat minutes
  seconds = parseFloat seconds
  return 60 * minutes + seconds

makeSnapshot = (video, time, thumbnail_path, width, height, callback) ->
  command = 'ffmpeg -ss ' + time + ' -i ./videos/' + video + '.mp4 -y -vframes 1 -s ' + width + 'x' + height + ' ' + thumbnail_path
  exec command, ->
    callback() if callback?

app.get '/thumbnail', (req, res) ->
  video = req.query.video
  time = toSeconds(req.query.time)
  width = parseInt(req.query.width)
  if not width? or isNaN(width)
    width = 960
  height = parseInt(req.query.height)
  if not height? or isNaN(height)
    height = 540
  if not video? or not time? or isNaN(time)
    res.send 'need video and time parameters'
  thumbnail_file = video + '_' + time + '_' + width + 'x' + height + '.png'
  thumbnail_path = 'thumbnails/' + thumbnail_file
  console.log thumbnail_path
  if fs.existsSync(thumbnail_path)
    res.sendFile path.join(__dirname, thumbnail_path)
  else
    makeSnapshot video, time, thumbnail_path, width, height, ->
      res.sendFile path.join(__dirname, thumbnail_path)

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

app.get /^\/qmd\/(.+)/, (req, res) ->
  name = req.params[0]
  if name.indexOf('..') != -1
    res.send 'cannot have .. in path'
    return
  page_html name + '.md', (data) ->
    if not data?
      res.send 'article does not exist: ' + name
    else
      ndata = []
      ndata.push '<link rel="stylesheet" type="text/css" href="/css/questions.css"/>'
      ndata.push '<script src="/bower_components/jquery/dist/jquery.min.js"></script>'
      ndata.push data
      res.send ndata.join('\n')

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
