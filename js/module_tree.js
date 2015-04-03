// Generated by LiveScript 1.3.1
(function(){
  var root, maximum, parent_dep_sorting_func, parent_dep_sorting_func_simple, parent_dep_sorting_func_real, is_learnable, repaint_nodes, next_topic, topicfinished, set_topic, initialize, makeTreeDataRec, makeTreeData, computeMaxDepth, out$ = typeof exports != 'undefined' && exports || this;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  maximum = require('prelude-ls').maximum;
  parent_dep_sorting_func = function(a, b){
    return -parent_dep_sorting_func_simple(a, b);
    if (root.visformat === 1 || root.visformat === 2) {
      return -parent_dep_sorting_func_real(a, b);
    }
    return parent_dep_sorting_func_real(a, b);
  };
  parent_dep_sorting_func_simple = function(a, b){
    var bradius, aradius;
    bradius = getnoderadius_percent(b.name);
    aradius = getnoderadius_percent(a.name);
    if (aradius > bradius) {
      return 1;
    }
    if (bradius > aradius) {
      return -1;
    }
    return 0;
  };
  parent_dep_sorting_func_real = function(a, b){
    var relation_order, relation_diff, bradius, aradius;
    relation_order = ['parents', 'depends'];
    relation_diff = relation_order.indexOf(a.relation) - relation_order.indexOf(b.relation);
    if (relation_diff !== 0) {
      return -relation_diff;
    }
    bradius = getnoderadius_percent(b.name);
    aradius = getnoderadius_percent(a.name);
    if (aradius > bradius) {
      return 1;
    }
    if (bradius > aradius) {
      return -1;
    }
    return 0;
  };
  root.viewed_topic = '';
  root.learned_topics = {};
  out$.is_learnable = is_learnable = function(topic_name){
    var ref$, parents, depends, i$, len$, x;
    ref$ = rawdata[topic_name], parents = ref$.parents, depends = ref$.depends;
    if (parents != null) {
      for (i$ = 0, len$ = parents.length; i$ < len$; ++i$) {
        x = parents[i$];
        if (root.learned_topics[x] == null) {
          return false;
        }
      }
    }
    if (depends != null) {
      for (i$ = 0, len$ = depends.length; i$ < len$; ++i$) {
        x = depends[i$];
        if (root.learned_topics[x] == null) {
          return false;
        }
      }
    }
    return true;
  };
  out$.repaint_nodes = repaint_nodes = function(){
    var topic_name, i$, ref$, len$, x, curname, results$ = [];
    topic_name = root.viewed_topic;
    for (i$ = 0, len$ = (ref$ = $('.topicname')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      curname = $(x).text();
      if (curname === topic_name) {
        $(x).css('font-weight', 'bold');
      } else {
        $(x).css('font-weight', 'normal');
      }
    }
    for (i$ = 0, len$ = (ref$ = $('.topicnode')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      curname = $(x).attr('data-topicname');
      if (root.learned_topics[curname] != null) {
        results$.push($(x).css('fill', 'green'));
      } else if (is_learnable(curname)) {
        results$.push($(x).css('fill', 'blue'));
      }
    }
    return results$;
  };
  out$.next_topic = next_topic = function(){
    var available_topics, i$, ref$, len$, x, curname;
    available_topics = [];
    for (i$ = 0, len$ = (ref$ = $('.topicname')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      curname = $(x).text();
      if (!root.learned_topics[curname] && is_learnable(curname)) {
        available_topics.push(curname);
      }
    }
    available_topics.sort(function(a, b){
      var bradius, aradius;
      bradius = getnoderadius_percent(b);
      aradius = getnoderadius_percent(a);
      if (aradius > bradius) {
        return 1;
      }
      if (bradius > aradius) {
        return -1;
      }
      return 0;
    });
    if (available_topics.length > 0) {
      return set_topic(available_topics[available_topics.length - 1]);
    } else {
      return repaint_nodes();
    }
  };
  out$.topicfinished = topicfinished = function(){
    root.learned_topics[root.viewed_topic] = true;
    return next_topic();
  };
  out$.set_topic = set_topic = function(topic_name){
    $('#topicdisplay').text(topic_name);
    $('#finishedbutton').text('Finished Learning ' + topic_name);
    $('#finishedbutton').show();
    root.viewed_topic = topic_name;
    return repaint_nodes();
  };
  initialize = function(treeData, max_depth){
    var canvas_width, canvas_height, vis, tree, diagonal, nodes, links, link, node;
    canvas_width = max_depth * 250;
    canvas_height = 80;
    vis = d3.select('#curriculum').append('svg:svg').attr('width', canvas_width + 300).attr('height', canvas_height).append('svg:g').attr('transform', 'translate(10, 0)');
    tree = d3.layout.tree().size([canvas_height, canvas_width]);
    diagonal = d3.svg.diagonal().projection(function(d){
      return [d.y, d.x];
    });
    nodes = tree.nodes(treeData);
    links = tree.links(nodes);
    link = vis.selectAll('pathlink').data(links).enter().append('svg:path').attr('class', 'link').attr('d', diagonal).style('stroke', function(d){
      /*
      source_name = d.source.name
      target_name = d.target.name
      console.log source_name + ',' + target_name
      target_children = root.rawdata[target_name].children
      if target_children?
        if target_children.indexOf(source_name) != -1
          return colors(1)
      source_depends = root.rawdata[source_name].depends
      if source_depends?
        if source_depends.indexOf(target_name) != -1
          return colors(2)
      */
      return 'black';
    }).style('stroke-opacity', function(d){
      return 0.2;
    });
    node = vis.selectAll('g.node').data(nodes).enter().append('svg:g').attr('transform', function(d){
      return 'translate(' + d.y + ',' + d.x + ')';
    });
    node.append('svg:circle').attr('r', 3.5).attr('class', 'topicnode').attr('data-topicname', function(d){
      return d.name;
    }).style('cursor', 'pointer').on('click', function(d){
      return set_topic(d.name);
    });
    node.append('svg:text').attr('dx', function(d){
      return 8;
    }).attr('dy', 3).attr('text-anchor', function(d){
      return 'start';
    }).text(function(d){
      return d.name;
    }).style('cursor', 'pointer').attr('class', 'topicname').on('click', function(d){
      return set_topic(d.name);
    });
    return next_topic();
  };
  makeTreeDataRec = function(topic){
    var children, ref$, x;
    children = (ref$ = root.rawdata[topic].children) != null
      ? ref$
      : [];
    return {
      name: topic,
      children: (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = children).length; i$ < len$; ++i$) {
          x = ref$[i$];
          results$.push(makeTreeData(x));
        }
        return results$;
      }())
    };
  };
  makeTreeData = function(topic){
    var treeData, name_to_treedata, agenda, i$, ref$, len$, child, curtopic, parent, parent_tree;
    treeData = {
      name: topic,
      children: []
    };
    name_to_treedata = {};
    name_to_treedata[topic] = treeData;
    agenda = [];
    if (root.rawdata[topic] && root.rawdata[topic].children != null) {
      for (i$ = 0, len$ = (ref$ = root.rawdata[topic].children).length; i$ < len$; ++i$) {
        child = ref$[i$];
        agenda.push([child, topic]);
      }
    }
    while (agenda.length > 0) {
      ref$ = agenda.shift(), curtopic = ref$[0], parent = ref$[1];
      if (name_to_treedata[curtopic] != null) {
        continue;
      }
      parent_tree = name_to_treedata[parent];
      parent_tree.children.push({
        name: curtopic,
        children: []
      });
      name_to_treedata[curtopic] = (ref$ = parent_tree.children)[ref$.length - 1];
      if (root.rawdata[curtopic].children != null) {
        for (i$ = 0, len$ = (ref$ = root.rawdata[curtopic].children).length; i$ < len$; ++i$) {
          child = ref$[i$];
          agenda.push([child, curtopic]);
        }
      }
    }
    return treeData;
  };
  computeMaxDepth = function(treeData){
    var x;
    if (treeData.children.length === 0) {
      return 0;
    }
    return 1 + maximum((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = treeData.children).length; i$ < len$; ++i$) {
        x = ref$[i$];
        results$.push(computeMaxDepth(x));
      }
      return results$;
    }()));
  };
  $(document).ready(function(){
    var params, topic, output, graph_file, ref$;
    root.params = params = getUrlParameters();
    topic = params.topic;
    if (topic == null) {
      $('#curriculum').text('need to provide topic');
      return;
    }
    output = [];
    graph_file = (ref$ = params.graph_file) != null ? ref$ : 'graph.yaml';
    return $.get(graph_file, function(yamltxt){
      var data;
      root.rawdata = data = preprocess_data(jsyaml.safeLoad(yamltxt));
      return get_bing_counts(data, function(counts){
        var topic_name, count, treeData, max_depth;
        for (topic_name in counts) {
          count = counts[topic_name];
          root.topic_to_bing_count[topic_name] = count;
        }
        if (data[topic] == null) {
          $('#curriculum').text('topic does not exist: ' + topic);
          return;
        }
        out$.treeData = treeData = makeTreeData(topic);
        max_depth = computeMaxDepth(treeData);
        /*
        root.all_parent_names = list_parent_names_recursive topic
        parents_and_depends = list_parents_and_depends_recursive topic
        if parents_and_depends.length == 0
          root.max_depth = max_depth = 0
        else
          root.max_depth = max_depth = parents_and_depends.map (.depth) |> maximum
        #parents_and_depends = list_parents_and_depends_recursive topic
        #console.log parents_and_depends
        export treeData = {
          name: topic
          children: []
        }
        export name_to_treedata = {}
        name_to_treedata[topic] = treeData
        for cur_depth in [0 to max_depth]
          for {name, relation, depth, parent} in parents_and_depends.filter((x) -> x.depth == cur_depth).sort(parent_dep_sorting_func)
            if name_to_treedata[name]?
              continue
            parent_node = name_to_treedata[parent]
            parent_node.children.push {
              name: name
              children: []
            }
            name_to_treedata[name] = parent_node.children[*-1]
            #insert_child_topic name, relation, depth, parent
        #JSON object with the data
        */
        /*
        treeData = 
          'name': 'A654'
          'children': [
            { 'name': 'A1' }
            { 'name': 'A2' }
            { 'name': 'A2B' }
            {
              'name': 'A3'
              'children': [ {
                'name': 'A31'
                'children': [
                  { 'name': 'A311' }
                  { 'name': 'A312' }
                ]
              } ]
            }
          ]
        */
        return initialize(treeData, max_depth);
      });
    });
  });
}).call(this);
