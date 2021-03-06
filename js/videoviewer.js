// Generated by LiveScript 1.3.1
(function(){
  $(document).ready(function(){
    var params, srcvid;
    params = getUrlParameters();
    $('#vidview').on('loadeddata', function(){
      var starttime, ref$, mins, secs;
      starttime = 0.0;
      if (params.start != null) {
        starttime = params.start;
        if (starttime.indexOf(':') !== -1) {
          ref$ = starttime.split(':'), mins = ref$[0], secs = ref$[1];
          mins = parseFloat(mins);
          secs = parseFloat(secs);
          starttime = mins * 60.0 + secs;
        } else {
          starttime = parseFloat(starttime);
        }
      }
      $('#vidview')[0].currentTime = starttime;
      return $('#vidview')[0].play();
    });
    srcvid = '1-1';
    if (params.video != null) {
      srcvid = params.video;
    }
    return $('#vidview').attr('src', '/videos/' + srcvid + '.mp4');
  });
}).call(this);
