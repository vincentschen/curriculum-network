// Generated by LiveScript 1.3.1
(function(){
  var root, relation_types, topic_to_bing_count, getUrlParameters, preprocess_data, create_terminal_nodes, get_bing_counts, out$ = typeof exports != 'undefined' && exports || this;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  out$.relation_types = relation_types = ['depends', 'parents'];
  out$.topic_to_bing_count = topic_to_bing_count = {};
  out$.getUrlParameters = getUrlParameters = function(){
    var url, hash, map, parts;
    url = window.location.href;
    hash = url.lastIndexOf('#');
    if (hash !== -1) {
      url = url.slice(0, hash);
    }
    map = {};
    parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value){
      return map[key] = decodeURIComponent(value).split('+').join(' ');
    });
    return map;
  };
  out$.preprocess_data = preprocess_data = function(data){
    var graph_metadata, preprocessing_steps, i$, len$, preprocessing_step;
    graph_metadata = data.graph_metadata;
    if (graph_metadata != null) {
      preprocessing_steps = graph_metadata.preprocessing_steps;
      if (graph_metadata.relation_types != null) {
        root.relation_types = relation_types = graph_metadata.relation_types;
        delete data.graph_metadata.relation_types;
      }
      if (preprocessing_steps != null) {
        for (i$ = 0, len$ = preprocessing_steps.length; i$ < len$; ++i$) {
          preprocessing_step = preprocessing_steps[i$];
          data = root.preprocessing_options[preprocessing_step](data);
        }
        delete data.graph_metadata.preprocessing_steps;
      }
      delete data.graph_metadata;
    }
    data = create_terminal_nodes(data);
    return data;
  };
  out$.create_terminal_nodes = create_terminal_nodes = function(data){
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
  out$.get_bing_counts = get_bing_counts = function(data, callback){
    var topic_to_query, topic_to_counts, add_query_for_topic, topic_name, topic_info, i$, ref$, len$, relation_type, children, j$, len1$, child, query_list, res$, k, v;
    topic_to_query = {};
    topic_to_counts = {};
    add_query_for_topic = function(topic_name){
      var query, topic_info, tags, x;
      if (topic_to_query[topic_name] != null) {
        return;
      }
      query = '"' + topic_name + '"';
      topic_info = data[topic_name];
      if (topic_info != null) {
        tags = topic_info.tags;
        if (tags != null) {
          query = (function(){
            var i$, ref$, len$, results$ = [];
            for (i$ = 0, len$ = (ref$ = tags).length; i$ < len$; ++i$) {
              x = ref$[i$];
              results$.push('"' + x + '"');
            }
            return results$;
          }()).join(' ');
        }
      }
      return topic_to_query[topic_name] = query;
    };
    for (topic_name in data) {
      topic_info = data[topic_name];
      add_query_for_topic(topic_name);
      for (i$ = 0, len$ = (ref$ = relation_types).length; i$ < len$; ++i$) {
        relation_type = ref$[i$];
        children = topic_name[relation_type];
        if (children != null) {
          for (j$ = 0, len1$ = children.length; j$ < len1$; ++j$) {
            child = children[j$];
            add_query_for_topic(child);
          }
        }
      }
    }
    res$ = [];
    for (k in topic_to_query) {
      v = topic_to_query[k];
      res$.push(v);
    }
    query_list = res$;
    return $.getJSON('/bingcounts?' + $.param({
      words: JSON.stringify(query_list)
    }), function(results){
      var topic_name, ref$, query, count;
      for (topic_name in ref$ = topic_to_query) {
        query = ref$[topic_name];
        count = results[query];
        topic_to_counts[topic_name] = count;
      }
      return callback(topic_to_counts);
    });
  };
}).call(this);
