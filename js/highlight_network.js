// Generated by LiveScript 1.3.1
(function(){
  var root, color_map, edge_color_map, colors, getedgerelation, setedgecolor, getcolorforrelation, getedgecolor, getnodecolor, getnoderadius_bing, getnoderadius_bing_raw, getnoderadius_stackoverflow, getnoderadius_stackoverflow_raw, getnoderadius_not_normalized, getnoderadius_percent, getnoderadius, getnode, recolor_all_edges, recolor_all_nodes, node_highlighted, reset_coloring, out$ = typeof exports != 'undefined' && exports || this;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  out$.color_map = color_map = {};
  out$.edge_color_map = edge_color_map = {};
  out$.colors = colors = function(idx){
    switch (idx) {
    case 0:
      return '#1f77b4';
    case 1:
      return '#ff7f0e';
    case 2:
      return '#2ca02c';
    case 3:
      return '#d62728';
    case 4:
      return '#9467bd';
    case 5:
      return '#8c564b';
    case 6:
      return '#e377c2';
    case 7:
      return '#7f7f7f';
    case 8:
      return '#bcbd22';
    case 9:
      return '#17becf';
    default:
      return '#999999';
    }
  };
  /*
  export getedgerelation = (source, target) ->
    if not rawdata[source]?
      return 'doesnotexist'
    {children, depends, suggests} = rawdata[source]
    if children? and children.indexOf(target) != -1
      return 'children'
    if depends? and depends.indexOf(target) != -1
      return 'depends'
    if suggests? and suggests.indexOf(target) != -1
      return 'suggests'
  */
  out$.getedgerelation = getedgerelation = function(source, target){
    var i$, ref$, len$, relation_type, relations;
    if (rawdata[source] == null) {
      return 'doesnotexist';
    }
    for (i$ = 0, len$ = (ref$ = relation_types).length; i$ < len$; ++i$) {
      relation_type = ref$[i$];
      relations = rawdata[source][relation_type];
      if (relations != null && relations.indexOf(target) !== -1) {
        return relation_type;
      }
    }
    return 'doesnotexist';
  };
  out$.setedgecolor = setedgecolor = function(source, target, color){
    if (edge_color_map[source] == null) {
      edge_color_map[source] = {};
    }
    return edge_color_map[source][target] = color;
  };
  out$.getcolorforrelation = getcolorforrelation = function(relation){
    var relation_idx;
    relation_idx = relation_types.indexOf(relation);
    if (relation_idx === -1) {
      return '#999999';
    } else {
      return colors(relation_idx);
    }
  };
  out$.getedgecolor = getedgecolor = function(source, target){
    var edge_relation;
    if (edge_color_map[source] != null) {
      if (edge_color_map[source][target] != null) {
        return edge_color_map[source][target];
      }
    }
    if (Object.keys(edge_color_map).length === 0) {
      edge_relation = getedgerelation(source, target);
      return getcolorforrelation(edge_relation);
    } else {
      return '#999999';
    }
  };
  out$.getnodecolor = getnodecolor = function(name){
    var ref$;
    return (ref$ = color_map[name]) != null ? ref$ : '#333333';
  };
  root.max_node_radius = null;
  out$.getnoderadius_bing = getnoderadius_bing = function(name){
    var radius;
    radius = getnoderadius_bing_raw(name);
    if (radius != null) {
      return Math.log(radius);
    }
    return null;
  };
  out$.getnoderadius_bing_raw = getnoderadius_bing_raw = function(name){
    var output;
    output = rawdata[name]['num bing results'];
    if (output != null) {
      return output;
    }
    return root.topic_to_bing_count[name];
  };
  out$.getnoderadius_stackoverflow = getnoderadius_stackoverflow = function(name){
    var radius;
    radius = getnoderadius_stackoverflow_raw(name);
    if (radius != null) {
      return Math.log(radius);
    }
    return null;
  };
  out$.getnoderadius_stackoverflow_raw = getnoderadius_stackoverflow_raw = function(name){
    return rawdata[name]['num stackoverflow results'];
  };
  getnoderadius_not_normalized = function(name){
    switch (params.radius_function) {
    case 'bing':
      return getnoderadius_bing(name);
    case 'stackoverflow':
      return getnoderadius_stackoverflow(name);
    default:
      return getnoderadius_bing(name);
    }
  };
  out$.getnoderadius_percent = getnoderadius_percent = function(name){
    var nodename, ref$, nodeinfo, cur_radius, ref1$;
    if (root.max_node_radius === null) {
      for (nodename in ref$ = rawdata) {
        nodeinfo = ref$[nodename];
        cur_radius = getnoderadius_not_normalized(nodename);
        if (cur_radius != null && isFinite(cur_radius)) {
          root.max_node_radius = (ref1$ = root.max_node_radius) > cur_radius ? ref1$ : cur_radius;
        }
      }
    }
    return getnoderadius_not_normalized(name) / root.max_node_radius;
  };
  out$.getnoderadius = getnoderadius = function(name){
    var radius_percent;
    if (rawdata[name] == null) {
      console.log('do not have radius for: ' + name);
      return 5;
    }
    radius_percent = getnoderadius_percent(name);
    if (!isFinite(radius_percent)) {
      console.log('do not have radius for: ' + name);
      return 5;
    }
    return 10 * radius_percent;
  };
  out$.getnode = getnode = function(name){
    var i$, ref$, len$, x, node;
    for (i$ = 0, len$ = (ref$ = $('.node')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      node = $(x);
      name = node.find('text').text();
      return node;
    }
  };
  out$.recolor_all_edges = recolor_all_edges = function(){
    var i$, ref$, len$, x, edge, source, target, results$ = [];
    for (i$ = 0, len$ = (ref$ = $('.link')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      edge = $(x);
      source = edge.attr('source');
      target = edge.attr('target');
      results$.push(edge.css('stroke', getedgecolor(source, target)));
    }
    return results$;
  };
  out$.recolor_all_nodes = recolor_all_nodes = function(){
    var i$, ref$, len$, x, node, name, circle, results$ = [];
    for (i$ = 0, len$ = (ref$ = $('.node')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      node = $(x);
      name = node.find('text').text();
      circle = node.find('circle');
      results$.push(circle.css('fill', getnodecolor(name)));
    }
    return results$;
  };
  out$.node_highlighted = node_highlighted = function(name){
    var i$, ref$, len$, relation_idx, relation_type, j$, ref1$, len1$, ref2$, child, source;
    color_map = {};
    edge_color_map = {};
    color_map[name] = colors(8);
    /*
    # highlight children as blue
    for {child,source} in list_children_recursive(name)
      color_map[child] = colors(0)#'#0000ff'
      setedgecolor source, child, colors(0) #'#0000ff'
    # highlight dependents as green
    for {child,source} in list_depends_recursive(name)
      color_map[child] = colors(1) #'#00ff00'
      setedgecolor source, child, colors(1)#'#00ff00'
    # highlight suggests as purple
    for {child,source} in list_suggests_recursive(name)
      color_map[child] = colors(2) #'#ff00ff'
      setedgecolor source, child, colors(2)#'#ff00ff'
    */
    for (i$ = 0, len$ = (ref$ = relation_types).length; i$ < len$; ++i$) {
      relation_idx = i$;
      relation_type = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = list_relation_recursive(relation_type, name)).length; j$ < len1$; ++j$) {
        ref2$ = ref1$[j$], child = ref2$.child, source = ref2$.source;
        color_map[child] = colors(relation_idx);
        setedgecolor(source, child, colors(relation_idx));
      }
    }
    recolor_all_nodes();
    return recolor_all_edges();
  };
  out$.reset_coloring = reset_coloring = function(){
    color_map = {};
    edge_color_map = {};
    recolor_all_nodes();
    return recolor_all_edges();
  };
}).call(this);
