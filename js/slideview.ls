root = exports ? this

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

make-video-preview = (video, vstart, vend) ->
  output = make-video-snapshot(video, vstart, vend, 960, 540)
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
  output.append $('<img>').attr('src', snapshot_url).css({width: width + 'px', height: height + 'px', 'border-radius': border_radius, 'border': border_style})
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
  {video, vstart, vend, image, frame, parents, children, depends} = topic_info
  if video? and vstart? and vend?
    output.append make-video-preview(video, vstart, vend)
  else if frame?
    output.append make-frame-section(frame)
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
