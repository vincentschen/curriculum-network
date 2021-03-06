// Generated by LiveScript 1.3.1
(function(){
  var express, serveStatic, bing_count, async, marked, fs, path, exec, app, ref$, toSeconds, makeSnapshot, page_markdown, page_html;
  express = require('express');
  serveStatic = require('serve-static');
  bing_count = require('bing_count');
  async = require('async');
  marked = require('marked');
  fs = require('fs');
  path = require('path');
  exec = require('child_process').exec;
  app = express();
  app.use(serveStatic('.'));
  app.set('port', (ref$ = process.env.PORT) != null ? ref$ : 8080);
  app.listen(app.get('port'), '0.0.0.0');
  toSeconds = function(timestamp){
    var ref$, minutes, seconds;
    if (typeof timestamp === typeof 0) {
      return timestamp;
    }
    if (timestamp.indexOf(':') === -1) {
      return parseFloat(timestamp);
    }
    ref$ = timestamp.split(':'), minutes = ref$[0], seconds = ref$[1];
    minutes = parseFloat(minutes);
    seconds = parseFloat(seconds);
    return 60 * minutes + seconds;
  };
  makeSnapshot = function(video, time, thumbnail_path, width, height, callback){
    var command;
    command = 'ffmpeg -ss ' + time + ' -i ./videos/' + video + '.mp4 -y -vframes 1 -s ' + width + 'x' + height + ' ' + thumbnail_path;
    return exec(command, function(){
      if (callback != null) {
        return callback();
      }
    });
  };
  app.get('/thumbnail', function(req, res){
    var video, time, width, height, thumbnail_file, thumbnail_path;
    video = req.query.video;
    time = toSeconds(req.query.time);
    width = parseInt(req.query.width);
    if (width == null || isNaN(width)) {
      width = 960;
    }
    height = parseInt(req.query.height);
    if (height == null || isNaN(height)) {
      height = 540;
    }
    if (video == null || time == null || isNaN(time)) {
      res.send('need video and time parameters');
    }
    thumbnail_file = video + '_' + time + '_' + width + 'x' + height + '.png';
    thumbnail_path = 'thumbnails/' + thumbnail_file;
    console.log(thumbnail_path);
    if (fs.existsSync(thumbnail_path)) {
      return res.sendFile(path.join(__dirname, thumbnail_path));
    } else {
      return makeSnapshot(video, time, thumbnail_path, width, height, function(){
        return res.sendFile(path.join(__dirname, thumbnail_path));
      });
    }
  });
  page_markdown = function(name, callback){
    return fs.exists(name, function(exists){
      if (exists) {
        return fs.readFile(name, 'utf8', function(err, results){
          return callback(results);
        });
      } else {
        return callback(null);
      }
    });
  };
  page_html = function(name, callback){
    return page_markdown(name, function(mdata){
      if (mdata === null) {
        return callback(null);
      } else {
        return callback(marked(mdata));
      }
    });
  };
  app.get(/^\/qmd\/(.+)/, function(req, res){
    var name;
    name = req.params[0];
    if (name.indexOf('..') !== -1) {
      res.send('cannot have .. in path');
      return;
    }
    return page_html(name + '.md', function(data){
      var ndata;
      if (data == null) {
        return res.send('article does not exist: ' + name);
      } else {
        ndata = [];
        ndata.push('<link rel="stylesheet" type="text/css" href="/css/questions.css"/>');
        ndata.push('<script src="/bower_components/jquery/dist/jquery.min.js"></script>');
        ndata.push(data);
        return res.send(ndata.join('\n'));
      }
    });
  });
  app.get(/^\/md\/(.+)/, function(req, res){
    var name;
    name = req.params[0];
    if (name.indexOf('..') !== -1) {
      res.send('cannot have .. in path');
      return;
    }
    return page_html(name + '.md', function(data){
      if (data == null) {
        return res.send('article does not exist: ' + name);
      } else {
        return res.send(data);
      }
    });
  });
  app.get('/bingcounts', function(req, res){
    var words, output, tasks, i$, len$;
    words = req.query.words;
    output = {};
    tasks = [];
    if (words == null) {
      res.json([]);
    }
    words = JSON.parse(words);
    for (i$ = 0, len$ = words.length; i$ < len$; ++i$) {
      (fn$.call(this, words[i$]));
    }
    return async.series(tasks, function(){
      return res.json(output);
    });
    function fn$(word){
      tasks.push(function(callback){
        return bing_count(word, function(count){
          output[word] = count;
          return callback(null, null);
        });
      });
    }
  });
}).call(this);
