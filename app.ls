require! {
  express
  'serve-static'
}

app = express()

app.use serveStatic '.'
app.set 'port', process.env.PORT ? 5000
app.listen app.get('port'), '0.0.0.0'
