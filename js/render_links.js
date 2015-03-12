// get the data
//d3.csv("graph.csv", function(error, links) {
function renderLinks(nodes, links) {
//get json data
// var data; // a global

// d3.json("graph.json", function(error, json) {
//   if (error) return console.warn(error);
//   data = json;

/*
nodes = {};

// Compute the distinct nodes from the links.
links.forEach(function(link) {
    link.source = nodes[link.source] ||
        (nodes[link.source] = {name: link.source});
    link.target = nodes[link.target] ||
        (nodes[link.target] = {name: link.target});
    link.value = +link.value;
});
*/

var width = $(window).width(),
    height = $(window).height();

var force = d3.layout.force()
    .nodes(d3.values(nodes))
    .links(links)
    .size([width, height])
    .linkDistance(120)
    .charge(-400)
    .on("tick", tick)
    //.start();

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

tip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([-10, 0])
  .html(function(d) {
    var name = d.name
    var info = rawdata[name]
    console.log(info)
    var output = $('<div>')
    output.append($('<div>').text(name))
    if (info != null) {
      if (info.summary != null) {
        output.append($('<div>').text(info.summary))
      }
      if (info['num bing results'] != null) {
        var importance_stats = $('<div>')
        importance_stats.append('importance: ' + getnoderadius_percent(name).toPrecision(2) + ' ')
        importance_stats.append(' (bing: ' + info['num bing results'] + ', ')
        importance_stats.append(' SO: ' + info['num stackoverflow results'] + ')')
        output.append(importance_stats)
        //output.append($('<div>').text('num bing results: ' + info['num bing results']))
      }
    }
    if (tip.showtype == 'click') {
      if (info.link != null) {
        output.append($('<a>').css('color', 'yellow').text(info.link).attr('href', '#').attr('onclick', 'openlink("' + info.link + '")'))
        output.append('<br>')
      }
      if (name != focus_topic) {
        output.append($('<a>').css('color', 'yellow').text('View graph for topic').attr('href', '#').attr('onclick', 'changetopic("' + name + '")'))
      }
    }
    return output.html()
  })

svg.call(tip)

// build the arrow.
svg.append("svg:defs").selectAll("marker")
    .data(["end"])      // Different link/path types can be defined here
  .enter().append("svg:marker")    // This section adds in the arrows
    .attr("id", String)
    .attr("viewBox", "0 -5 10 10")
    .attr("refX", 15)
    .attr("refY", -1.5)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("orient", "auto")
  .append("svg:path")
    .attr("d", "M0,-5L10,0L0,5");

// add the links and the arrows
var path = svg.append("svg:g").selectAll("path")
    .data(force.links())
  .enter().append("svg:path")
//    .attr("class", function(d) { return "link " + d.type; })
    .attr("class", "link")
    .attr("marker-end", "url(#end)")
    .attr('source', function(d) { return d.source.name })
    .attr('target', function(d) { return d.target.name })
    .attr('relation', function(d) { return d.type })
    .style('stroke', function(d) {
      return getedgecolor(d.source.name, d.target.name)
    })

color = d3.scale.category20()

// define the nodes
var node = svg.selectAll(".node")
    .data(force.nodes())
  .enter().append("g")
    .attr("class", "node")
    .call(force.drag)

// add the nodes
node.append("circle")
    .attr("r", function(d) {
      return getnoderadius(d.name)
    })
    .style('fill', function(d) {
      return getnodecolor(d.name)
    })


circle_clicked_time = 0

svg.selectAll('circle')
  .on('mouseover', function(nodeinfo, nodeidx, a3) {
    node_highlighted(nodeinfo.name)
    tip.showtype = 'mouseover'
    tip.show(nodeinfo, nodeidx, a3)
  }).on('mouseout', function(nodeinfo, nodeidx, a3) {
    if (tip.showtype == 'mouseover') {
      reset_coloring()
      tip.hide(nodeinfo, nodeidx, a3)
    }
  }).on('click', function(nodeinfo, nodeidx, a3) {
    node_highlighted(nodeinfo.name)
    tip.showtype = 'click'
    tip.show(nodeinfo, nodeidx, a3)
    circle_clicked_time = Date.now()
    /*
    var newparams = getUrlParameters()
    newparams.topic = nodeinfo.name
    if (nodeinfo.name == focus_topic) return
    window.location.href = '/?' + $.param(newparams)
    */
  })

$(document).click(function(evt) {
  if (Date.now() > circle_clicked_time + 500) {
    tip.hide()
    reset_coloring()
  }
})

//svg.selectAll('circle')
//    .data(data)
//    .style("fill", function(d) {return color(d.group)})

// add the text
node.append("text")
    .attr("x", 12)
    .attr("dy", ".35em")
    .text(function(d) { return d.name; });

update()

function update() {

  force.start()
}

// add the curvy lines
function tick() {
    path.attr("d", function(d) {
        var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
            dr = Math.sqrt(dx * dx + dy * dy);
        return "M" +
            d.source.x + "," +
            d.source.y + "A" +
            dr + "," + dr + " 0 0,1 " +
            d.target.x + "," +
            d.target.y;
    });

    node
        .attr("transform", function(d) {
  	    return "translate(" + d.x + "," + d.y + ")"; });
}

}

function openlink(target) {
  circle_clicked_time = Date.now()
  window.open(target)
}

function gotolink(target) {
  window.location.href = target
}

function changetopic(target) {
  var newparams = getUrlParameters()
  if (target == '' || target == null) {
    if (newparams.topic != null) {
      delete newparams.topic
    }
  } else {
    newparams.topic = target
  }
  gotolink('/?' + $.param(newparams))
}
