root = exports ? this

srt-to-seconds = (timestamp) ->
  timestamp.split(',').join('.')
  [hours,minutes,seconds] = timestamp.split(':')
  hours = parseFloat hours
  minutes = parseFloat minutes
  seconds = parseFloat seconds
  return hours * 3600 + minutes * 60 + seconds

to-seconds = (timestamp) ->
  if typeof(timestamp) == typeof(0)
    return timestamp
  if timestamp.indexOf(':') == -1
    return parseFloat timestamp
  [minutes,seconds] = timestamp.split(':')
  minutes = parseFloat minutes
  seconds = parseFloat seconds
  return 60 * minutes + seconds

get-snapshot-url = (video, snapshot_time, width, height) ->
  if not width?
    width = 960
  if not height?
    height = 540
  return '/thumbnail?' + $.param({video, time: snapshot_time, width, height})

get-video-tag = ->
  vtag = $('video')
  if vtag.length == 0
    vtag = $('<video controls="controls">')
    vtag.css {width: '960px', height: '540px'}
    vtag.css {position: 'absolute', top: '0px', left: '0px'}
    #vtag.hide()
    vtag.on 'timeupdate', ->
      curtime = this.currentTime
      subtitle_section = $('.activeslide').find('.subtitle')
      activesub = subtitle_section.find '.activesub'
      if activesub.length > 0 and (activesub.data('start') <= curtime <= activesub.data('end'))
        return
      activesub.removeClass 'activesub'
      for x in subtitle_section.find('.subline')
        subtitle_span = $(x)
        if subtitle_span.data('start') <= curtime <= subtitle_span.data('end')
          subtitle_span.addClass 'activesub'
    $('body').append vtag
  return vtag

clean-active-slide = ->
  activeslide = $('.activeslide')
  activeslide.find('.activesub').removeClass('activesub')
  activeslide.removeClass('activeslide')


make-video-preview = (video, vstart, vend) ->
  output = make-video-snapshot(video, vstart, vend, 960, 540)
  output.css 'cursor', 'pointer'
  subtitle_section = $('<div>').addClass('subtitle').css({'margin-bottom': '10px'})
  output.append subtitle_section
  $.get ('/subtitles/' + video + '.srt'), (raw_srt) ->
    subtitle_section.css {'max-height': '80px', 'overflow': 'scroll'}
    #subtitle_section.text data
    subtitle_data = parser.fromSrt raw_srt
    for subtitle_line in subtitle_data
      srtStart = srt-to-seconds subtitle_line.startTime
      srtEnd = srt-to-seconds subtitle_line.endTime
      if not (srtStart + 2.5 > to-seconds(vstart))
        continue
      if not (srtEnd - 2.5 < to-seconds(vend))
        continue
      subtitle_section.append $('<span>').text(subtitle_line.text).data({start: srtStart, end: srtEnd}).addClass('subline')
      subtitle_section.append ' '
  output.click ->
    vtag = get-video-tag()
    vtag.attr 'src', '/videos/' + video + '.mp4#t=' + to-seconds(vstart) + ',' + to-seconds(vend)
    vidpreview = output.find('.vidpreview')
    vtag.offset(vidpreview.offset())
    #console.log vidpreview.offset()
    clean-active-slide()
    output.addClass 'activeslide'
    vtag.show()
    vtag[0].currentTime = 0
    vtag[0].play()
  return output

make-video-snapshot = (video, vstart, vend, width, height, border_radius, border_style) ->
  if not border_radius?
    border_radius = '0px'
  if not border_style?
    border_style = ''
  vstart = to-seconds vstart
  vend = to-seconds vend
  snapshot_time = vend - 3
  snapshot_url = get-snapshot-url(video, snapshot_time, width, height)
  output = $('<div>').css({position: 'relative'})
  output.append $('<img>').addClass('vidpreview').attr('src', snapshot_url).css({width: width + 'px', height: height + 'px', 'border-radius': border_radius, 'border': border_style})
  return output

make-empty-preview = (width, height, border_radius, border_style) ->
  if not border_radius?
    border_radius = '0px'
  if not border_style?
    border_style = ''
  #snapshot_url = '/blank_' + width + '_' + height + '.png'
  output = $('<div>').css({position: 'relative'})
  output.append $('<img>').css({width: width + 'px', height: height + 'px', 'border-radius': border_radius, 'border': border_style})
  return output

add_text_to_top = (output, text) ->
  top = $('<div>').css({'font-size': '20px', 'background-color': 'black', 'color': 'white', 'position': 'absolute', 'top': '0px', 'text-align': 'center', 'width': '320px', 'border-radius': '15px 15px 0 0'})
  top.text text
  output.append top

sanitize-name = (name) ->
  output = []
  alphabet = [\A to \Z] ++ [\a to \z] ++ [\0 to \9]
  for c in name
    if alphabet.indexOf(c) != -1
      output.push c
  return output.join('')

scroll-to-topic = (topic_name) ->
  topic_name_sanitized = sanitize-name topic_name
  position = $('#' + topic_name_sanitized).offset().top
  #window.scrollTo 0, position
  $('html,body').animate {scrollTop: position}, 500

make-preview = (topic_name) ->
  topic_info = root.rawdata[topic_name]
  {video, vstart, vend} = topic_info
  output = $('<div>').css({display: 'inline-block', 'margin-right': '5px', 'cursor': 'pointer'})
  output.click ->
    scroll-to-topic topic_name
  if video? and vstart? and vend?
    output.append add_text_to_top(make-video-snapshot(video, vstart, vend, 320, 180, '15px', '1px solid black'), topic_name)
  else
    output.append add_text_to_top(make-empty-preview(320, 180, '15px', '1px solid black'), topic_name)
  return output

make-image-section = (image) ->
  #output = $('<img>').css({width: '960px', 'height': '540px'}).attr('src', image)
  output = $('<img>').attr('src', image)
  return output

make-frame-section = (frame) ->
  output = $('<iframe>').css({width: '960px', 'height': '540px', 'border': '0px', 'margin': '0px'}).attr('src', frame)
  return output

make-section = (topic_name, topic_info) ->
  output = $('<div>').css({'margin-bottom': '50px'})
  topic_name_sanitized = sanitize-name topic_name
  output.append $('<div>').css({'font-size': '24px'}).text(topic_name).attr('id', topic_name_sanitized)
  {video, vstart, vend, image, frame, html, parents, children, depends} = topic_info
  if video? and vstart? and vend?
    output.append make-video-preview(video, vstart, vend)
  else if frame?
    output.append make-frame-section(frame)
  else if html?
    html_container = $('<div>')
    output.append html_container
    $.get html, (data) ->
      html_container.html data
  else if image?
    output.append make-image-section(image)
  if parents?
    output.append $('<div>').css({'font-size': '18px'}).text('Parents')
    for parent in parents
      output.append make-preview(parent)
  if children?
    output.append $('<div>').css({'font-size': '18px'}).text('Children')
    for child in children
      output.append make-preview(child)
  if depends?
    output.append $('<div>').css({'font-size': '18px'}).text('Depends')
    for dependency in depends
      output.append make-preview(dependency)
  return output

$(document).ready ->
  root.params = params = getUrlParameters()
  graph_file = params.graph_file ? 'neuralnets_slides.yaml'
  yamltxt <- $.get graph_file
  root.rawdata = data = preprocess_data jsyaml.safeLoad(yamltxt)
  #console.log data
  for topic_name,topic_info of data
    $('#curriculum').append make-section(topic_name, topic_info)
