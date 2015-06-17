$(document).ready ->
  params = getUrlParameters()
  $('#vidview').on 'loadeddata', ->
    starttime = 0.0
    if params.start?
      starttime = params.start
      if starttime.indexOf(':') != -1
        [mins,secs] = starttime.split(':')
        mins = parseFloat mins
        secs = parseFloat secs
        starttime = mins * 60.0 + secs
      else
        starttime = parseFloat starttime
    $('#vidview')[0].currentTime = starttime
    $('#vidview')[0].play()
  srcvid = '1-1'
  if params.video?
    srcvid = params.video
  $('#vidview').attr 'src', '/videos/' + srcvid + '.mp4'
