// Generated by LiveScript 1.3.1
(function(){
  var root, relation_types, getUrlParameters, filter_nodes_by_topic, create_terminal_nodes, out$ = typeof exports != 'undefined' && exports || this;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  out$.relation_types = relation_types = ['children', 'depends', 'suggests'];
  out$.getUrlParameters = getUrlParameters = function(){
    var url, hash, map, parts;
    url = window.location.href;
    hash = url.lastIndexOf('#');
    if (hash !== -1) {
      url = url.slice(0, hash);
    }
    map = {};
    parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value){
      return map[key] = decodeURI(value).split('+').join(' ');
    });
    return map;
  };
  filter_nodes_by_topic = function(focus_topic){
    var data, output, whitelist, i$, ref$, len$, x, topic_name, topic_info;
    data = root.rawdata;
    output = {};
    whitelist = {};
    for (i$ = 0, len$ = (ref$ = list_all_related_node_names_recursive(focus_topic)).length; i$ < len$; ++i$) {
      x = ref$[i$];
      whitelist[x] = true;
    }
    whitelist[focus_topic] = true;
    for (topic_name in data) {
      topic_info = data[topic_name];
      if (whitelist[topic_name] != null) {
        output[topic_name] = topic_info;
      }
    }
    return output;
  };
  create_terminal_nodes = function(data){
    var output, topic_name, topic_info, i$, ref$, len$, relation, connected_nodes, j$, len1$, name;
    output = {};
    for (topic_name in data) {
      topic_info = data[topic_name];
      output[topic_name] = topic_info;
    }
    for (topic_name in data) {
      topic_info = data[topic_name];
      for (i$ = 0, len$ = (ref$ = relation_types).length; i$ < len$; ++i$) {
        relation = ref$[i$];
        connected_nodes = topic_info[relation];
        if (connected_nodes != null) {
          for (j$ = 0, len1$ = connected_nodes.length; j$ < len1$; ++j$) {
            name = connected_nodes[j$];
            if (output[name] == null) {
              output[name] = {};
            }
          }
        }
      }
    }
    return output;
  };
  $(document).ready(function(){
    var params, focus_topic, prev_topic;
    params = getUrlParameters();
    root.focus_topic = focus_topic = params.topic;
    prev_topic = params.prevtopic;
    return $.get('graph.yaml', function(yamltxt){
      var data, parent_names, toptext, i$, len$, parent_name, nodes, topic_name, topic_info, ref$, relation, connected_nodes, j$, len1$, name, links, children, depends;
      data = create_terminal_nodes(jsyaml.safeLoad(yamltxt));
      root.rawdata = data;
      if (focus_topic != null && focus_topic.length > 0) {
        parent_names = list_parent_names(focus_topic);
        root.rawdata = data = filter_nodes_by_topic(focus_topic);
        toptext = $('<span>').css({
          position: 'fixed',
          left: '0px',
          top: '0px',
          'z-index': 'z-index',
          'font-size': '20px'
        });
        toptext.append($('<span>').text('Focus topic: ' + focus_topic + ' '));
        if (parent_names.length > 0) {
          toptext.append('Parents: ');
          for (i$ = 0, len$ = parent_names.length; i$ < len$; ++i$) {
            parent_name = parent_names[i$];
            toptext.append($('<a>').attr({
              href: '/?' + $.param({
                topic: parent_name
              })
            }).text(parent_name));
            toptext.append(' ');
          }
        }
        toptext.append($('<a>').attr({
          href: '/'
        }).text('View the full network'));
        $('body').append(toptext);
      }
      nodes = {};
      for (topic_name in data) {
        topic_info = data[topic_name];
        if (nodes[topic_name] == null) {
          nodes[topic_name] = {
            name: topic_name
          };
        }
        for (i$ = 0, len$ = (ref$ = relation_types).length; i$ < len$; ++i$) {
          relation = ref$[i$];
          connected_nodes = topic_info[relation];
          if (connected_nodes != null) {
            for (j$ = 0, len1$ = connected_nodes.length; j$ < len1$; ++j$) {
              name = connected_nodes[j$];
              if (nodes[name] == null) {
                nodes[name] = {
                  name: name
                };
              }
            }
          }
        }
      }
      links = [];
      for (topic_name in data) {
        topic_info = data[topic_name];
        children = topic_info.children, depends = topic_info.depends;
        for (i$ = 0, len$ = (ref$ = relation_types).length; i$ < len$; ++i$) {
          relation = ref$[i$];
          connected_nodes = topic_info[relation];
          if (connected_nodes != null) {
            for (j$ = 0, len1$ = connected_nodes.length; j$ < len1$; ++j$) {
              name = connected_nodes[j$];
              links.push({
                source: nodes[topic_name],
                target: nodes[name],
                relation: relation
              });
            }
          }
        }
      }
      root.rawdata = data;
      root.nodes = nodes;
      root.links = links;
      return renderLinks(nodes, links);
    });
  });
}).call(this);
