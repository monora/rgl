require 'test_helper'

require 'rgl/dot'
require 'rgl/adjacency'

class TestDotOptions < Test::Unit::TestCase
  def test_vertex_options
    graph = RGL::DirectedAdjacencyGraph.new
    graph.add_vertex('NODE_OPTS')
    RGL::DOT::NODE_OPTS.each do |opt|
      # Omitting shapefile for now because I don't have a proper file to test this with
      next if opt == 'shapefile'

      graph.add_vertex(opt)
      graph.add_edge('NODE_OPTS', opt)
      graph.set_edge_options('NODE_OPTS', opt, label: "Node Options", penwidth: 2)
    end

    graph.set_vertex_options('color', label: "color: green", color: "green")
    graph.set_vertex_options('colorscheme', colorscheme: "accent8", color: 6, label: "colorscheme\naccent8\/6")
    graph.set_vertex_options('comment', label: "comment\n(SVG source)", comment: "My Comment")
    graph.set_vertex_options('distortion', label: "distortion: 0.6", shape: "polygon", distortion: "0.6")
    graph.set_vertex_options('fillcolor', label: "fillcolor: lightblue", fillcolor: "lightblue", style: "filled")
    graph.set_vertex_options('fixedsize', label: "fixedsize\nheight: 4.0\nwidth: 2.5", fixedsize: "true", width: 4.0, height: 2.5)
    graph.set_vertex_options('fontcolor', label: "fontcolor: red", fontcolor: "red")
    graph.set_vertex_options('fontname', label: "fontname: Courier", fontname: "Courier")
    graph.set_vertex_options('fontsize', label: "fontsize: 34", fontsize: "34")
    graph.set_vertex_options('group', group: "opts")
    graph.set_vertex_options('height', height: "1.5")
    graph.set_vertex_options('id', label: "id\n(SVG ID)", id: "MyID")
    graph.set_vertex_options('label', label: "node label")
    graph.set_vertex_options('labelloc', height: 2, label: "labelloc b", labelloc: "b")
    graph.set_vertex_options('layer', layer: "overlay range")
    graph.set_vertex_options('margin', margin: "0.25,0.25")
    graph.set_vertex_options('nojustify', label: "The first line is longer\nnojustify=false\\l", nojustify: "false", shape: "box", width: 3)
    graph.set_vertex_options('orientation', label: "orientation: 71", shape: "polygon", orientation: "71")
    graph.set_vertex_options('penwidth', penwidth: "5.0")
    graph.set_vertex_options('peripheries', peripheries: "4")
    graph.set_vertex_options('regular', shape: "hexagon", regular: "true")
    graph.set_vertex_options('samplepoints', samplepoints: "20")
    graph.set_vertex_options('shape', label: "shape: box3d", shape: "box3d")
    # graph.set_vertex_options('shapefile', shapefile: example_shapefile)
    graph.set_vertex_options('sides', label: "sides: 8",shape: "polygon", sides: "8")
    graph.set_vertex_options('skew', label: "skew 0.5", shape: "polygon", sides: "8", skew: "0.5")
    graph.set_vertex_options('style', label: "style: dashed", style: "dashed")
    graph.set_vertex_options('target', label: "target: _blank", URL: "https://graphviz.org/docs/attrs/target/", target: "_blank")
    graph.set_vertex_options('tooltip', label: "tooltip: FOO", tooltip: "FOO")
    graph.set_vertex_options('URL', label: "URL: http://www.example.org", URL: "http://www.example.org")
    graph.set_vertex_options('width', label: "width: 4.25", width: "4.25")

    get_vertex_setting = proc { |v| graph.vertex_options[v] }

    vertex_options = {
      'color' => get_vertex_setting,
      'colorscheme' => get_vertex_setting,
      'comment' => get_vertex_setting,
      'distortion' => get_vertex_setting,
      'fillcolor' => get_vertex_setting,
      'fixedsize' => get_vertex_setting,
      'fontcolor' => get_vertex_setting,
      'fontname' => get_vertex_setting,
      'fontsize' => get_vertex_setting,
      'group' => get_vertex_setting,
      'height' => get_vertex_setting,
      'id' => get_vertex_setting,
      'label' => get_vertex_setting,
      'labelloc' => get_vertex_setting,
      'layer' => get_vertex_setting,
      'margin' => get_vertex_setting,
      'nojustify' => get_vertex_setting,
      'orientation' => get_vertex_setting,
      'penwidth' => get_vertex_setting,
      'peripheries' => get_vertex_setting,
      'regular' => get_vertex_setting,
      'samplepoints' => get_vertex_setting,
      'shape' => get_vertex_setting,
      # 'shapefile' => get_vertex_setting,
      'sides' => get_vertex_setting,
      'skew' => get_vertex_setting,
      'style' => get_vertex_setting,
      'target' => get_vertex_setting,
      'tooltip' => get_vertex_setting,
      'URL' => get_vertex_setting,
      'width' => get_vertex_setting,
    }

    dot_options = { 'rankdir' => 'LR', 'vertex' => vertex_options }

    # pp graph.vertex_options
    dot = graph.to_dot_graph(dot_options).to_s
    graph.write_to_graphic_file('svg', 'node-opts-graph', dot_options)

    assert_match(dot, /color \[\n\s*color = green,\n\s*label = "color: green"*/)
    assert_match(dot, /colorscheme \[\n\s*color = 6,\n\s*colorscheme = accent8,\n\s*label = "colorscheme\\naccent8\/6"*/)
    assert_match(dot, /comment \[\n\s*comment = "My Comment",\n\s*label = "comment\\n\(SVG source\)"*/)
    assert_match(dot, /distortion \[\n\s*distortion = 0.6,\n\s*shape = polygon,\n\s*label = "distortion: 0.6"*/)
    assert_match(dot, /fillcolor \[\n\s*fillcolor = lightblue,\n\s*style = filled,\n\s*label = "fillcolor: lightblue"*/)
    assert_match(dot, /fixedsize \[\n\s*fixedsize = true,\n\s*height = 2.5,\n\s*width = 4.0,\n\s*label = "fixedsize\\nheight: 4.0\\nwidth: 2.5"*/)
    assert_match(dot, /fontcolor \[\n\s*fontcolor = red,\n\s*label = "fontcolor: red"*/)
    assert_match(dot, /fontname \[\n\s*fontname = Courier,\n\s*label = "fontname: Courier"*/)
    assert_match(dot, /fontsize \[\n\s*fontsize = 34,\n\s*label = "fontsize: 34"*/)
    assert_match(dot, /group \[\n\s*group = opts*/)
    assert_match(dot, /height \[\n\s*height = 1.5*/)
    assert_match(dot, /id \[\n\s*id = MyID,\n\s*label = "id\\n\(SVG ID\)"*/)
    assert_match(dot, /label \[\n\s*label = "node label"*/)
    assert_match(dot, /labelloc \[\n\s*height = 2,\n\s*labelloc = b,\n\s*label = "labelloc b"*/)
    assert_match(dot, /layer \[\n\s*layer = "overlay range"*/)
    assert_match(dot, /margin \[\n\s*margin = "0.25,0.25"*/)
    assert_match(dot, /nojustify \[\n\s*nojustify = false,\n\s*shape = box,\n\s*width = 3,\n\s*label = "The first line is longer\\nnojustify=false\\l"*/)
    assert_match(dot, /orientation \[\n\s*orientation = 71,\n\s*shape = polygon,\n\s*label = "orientation: 71"*/)
    assert_match(dot, /penwidth \[\n\s*penwidth = 5.0*/)
    assert_match(dot, /peripheries \[\n\s*peripheries = 4*/)
    assert_match(dot, /regular \[\n\s*regular = true,\n\s*shape = hexagon*/)
    assert_match(dot, /samplepoints \[\n\s*samplepoints = 20*/)
    assert_match(dot, /shape \[\n\s*shape = box3d,\n\s*label = "shape: box3d"*/)
    # assert_match(dot, /shapefile \[\n\s*shapefile = example_shapefile*/)
    assert_match(dot, /sides \[\n\s*shape = polygon,\n\s*sides = 8,\n\s*label = "sides: 8"*/)
    assert_match(dot, /skew \[\n\s*shape = polygon,\n\s*sides = 8,\n\s*skew = 0.5,\n\s*label = "skew 0.5"*/)
    assert_match(dot, /style \[\n\s*style = dashed,\n\s*label = "style: dashed"*/)
    assert_match(dot, /target \[\n\s*target = _blank,\n\s*URL = "https:\/\/graphviz.org\/docs\/attrs\/target\/",\n\s*label = "target: _blank"*/)
    assert_match(dot, /tooltip \[\n\s*tooltip = FOO,\n\s*label = "tooltip: FOO"*/)
    assert_match(dot, /URL \[\n\s*URL = "http:\/\/www.example.org",\n\s*label = "URL: http:\/\/www.example.org"*/)
    assert_match(dot, /width \[\n\s*width = 4.25,\n\s*label = "width: 4.25"*/)
  end

  def test_edge_options
    graph = RGL::DirectedAdjacencyGraph.new
    graph.add_vertex('EDGE_OPTS')
    RGL::DOT::EDGE_OPTS.each do |opt|
      graph.add_edge('EDGE_OPTS', opt)
      # graph.set_edge_options('EDGE_OPTS', opt, )
    end

    graph.set_edge_options('EDGE_OPTS', 'arrowhead', arrowhead: "empty", label: "arrowhead: empty")
    graph.set_edge_options('EDGE_OPTS', 'arrowsize', arrowsize: 3, label: "arrowsize: 3")
    # graph.set_edge_options('EDGE_OPTS', 'arrowtail', arrowtail:, label: "arrowtail: ") # default: normal; style of arrowhead at tail end
    # graph.set_edge_options('EDGE_OPTS', 'color', color:, label: "color: ") # default: black; edge stroke color
    # graph.set_edge_options('EDGE_OPTS', 'colorscheme', colorscheme:, label: "colorscheme: ") # default: X11; scheme for interpreting color names
    # graph.set_edge_options('EDGE_OPTS', 'comment', comment:, label: "comment: ") # any string (format-dependent)
    # graph.set_edge_options('EDGE_OPTS', 'constraint', constraint:, label: "constraint: ") # default: true use edge to affect node ranking
    # graph.set_edge_options('EDGE_OPTS', 'decorate', decorate:, label: "decorate: ") # if set, draws a line connecting labels with their edges
    # graph.set_edge_options('EDGE_OPTS', 'dir', dir:, label: "dir: ") # default: forward; forward, back, both, or none
    # graph.set_edge_options('EDGE_OPTS', 'edgeURL', edgeURL:, label: "edgeURL: ") # URL attached to non-label part of edge
    # graph.set_edge_options('EDGE_OPTS', 'edgehref', edgehref:, label: "edgehref: ") # synonym for edgeURL
    # graph.set_edge_options('EDGE_OPTS', 'edgetarget', edgetarget:, label: "edgetarget: ") # if URL is set, determines browser window for URL
    # graph.set_edge_options('EDGE_OPTS', 'edgetooltip', edgetooltip:, label: "edgetooltip: ") # default: label; tooltip annotation for non-label part of edge
    # graph.set_edge_options('EDGE_OPTS', 'fontcolor', fontcolor:, label: "fontcolor: ") # default: black type face color
    # graph.set_edge_options('EDGE_OPTS', 'fontname', fontname:, label: "fontname: ") # default: Times-Roman; font family
    # graph.set_edge_options('EDGE_OPTS', 'fontsize', fontsize:, label: "fontsize: ") # default: 14; point size of label
    # graph.set_edge_options('EDGE_OPTS', 'headclip', headclip:, label: "headclip: ") # default: true; if false, edge is not clipped to head node boundary
    # graph.set_edge_options('EDGE_OPTS', 'headhref', headhref:, label: "headhref: ") # synonym for headURL
    # graph.set_edge_options('EDGE_OPTS', 'headlabel', headlabel:, label: "headlabel: ") # default: label; placed near head of edge
    # graph.set_edge_options('EDGE_OPTS', 'headport', headport:, label: "headport: ") # n,ne,e,se,s,sw,w,nw
    # graph.set_edge_options('EDGE_OPTS', 'headtarget', headtarget:, label: "headtarget: ") # if headURL is set, determines browser window for URL
    # graph.set_edge_options('EDGE_OPTS', 'headtooltip', headtooltip:, label: "headtooltip: ") # default: label; tooltip annotation near head of edge
    # graph.set_edge_options('EDGE_OPTS', 'headURL', headURL:, label: "headURL: ") # URL attached to head label if output format is ismap
    # graph.set_edge_options('EDGE_OPTS', 'href', href:, label: "href: ") # alias for URL
    # graph.set_edge_options('EDGE_OPTS', 'id', id:, label: "id: ") # any string (user-defined output object tags)
    # graph.set_edge_options('EDGE_OPTS', 'label', label:, label: "label: ") # edge label
    # graph.set_edge_options('EDGE_OPTS', 'labelangle', labelangle:, label: "labelangle: ") # default: -25.0; angle in degrees which head or tail label is rotated off edge
    # graph.set_edge_options('EDGE_OPTS', 'labeldistance', labeldistance:, label: "labeldistance: ") # default: 1.0; scaling factor for distance of head or tail label from node
    # graph.set_edge_options('EDGE_OPTS', 'labelfloat', labelfloat:, label: "labelfloat: ") # default: false; lessen constraints on edge label placement
    # graph.set_edge_options('EDGE_OPTS', 'labelfontcolor', labelfontcolor:, label: "labelfontcolor: ") # default: black; type face color for head and tail labels
    # graph.set_edge_options('EDGE_OPTS', 'labelfontname', labelfontname:, label: "labelfontname: ") # default: Times-Roman; font family for head and tail labels
    # graph.set_edge_options('EDGE_OPTS', 'labelfontsize', labelfontsize:, label: "labelfontsize: ") # default: 14 point size for head and tail labels
    # graph.set_edge_options('EDGE_OPTS', 'labelhref', labelhref:, label: "labelhref: ") # synonym for labelURL
    # graph.set_edge_options('EDGE_OPTS', 'labelURL', labelURL:, label: "labelURL: ") # URL for label, overrides edge URL
    # graph.set_edge_options('EDGE_OPTS', 'labeltarget', labeltarget:, label: "labeltarget: ") # if URL or labelURL is set, determines browser window for URL
    # graph.set_edge_options('EDGE_OPTS', 'labeltooltip', labeltooltip:, label: "labeltooltip: ") # default: label; tooltip annotation near label
    # graph.set_edge_options('EDGE_OPTS', 'layer', layer:, label: "layer: ") # default: overlay range; all, id or id:id
    # graph.set_edge_options('EDGE_OPTS', 'lhead', lhead:, label: "lhead: ") # name of cluster to use as head of edge
    # graph.set_edge_options('EDGE_OPTS', 'ltail', ltail:, label: "ltail: ") # name of cluster to use as tail of edge
    # graph.set_edge_options('EDGE_OPTS', 'minlen', minlen:, label: "minlen: ") # default: 1 minimum rank distance between head and tail
    # graph.set_edge_options('EDGE_OPTS', 'penwidth', penwidth:, label: "penwidth: ") # default: 1.0; width of pen for drawing boundaries, in points
    # graph.set_edge_options('EDGE_OPTS', 'samehead', samehead:, label: "samehead: ") # tag for head node; edge heads with the same tag are merged onto the same port
    # graph.set_edge_options('EDGE_OPTS', 'sametail', sametail:, label: "sametail: ") # tag for tail node; edge tails with the same tag are merged onto the same port
    # graph.set_edge_options('EDGE_OPTS', 'style', style:, label: "style: ") # graphics options, e.g. bold, dotted, filled; cf. Section 2.3
    # graph.set_edge_options('EDGE_OPTS', 'taillabel', taillabel:, label: "taillabel: ") # label placed near tail of edge
    # graph.set_edge_options('EDGE_OPTS', 'weight', weight:, label: "weight: ") # default: 1; integer cost of stretching an edge
    # graph.set_edge_options('EDGE_OPTS', 'tailclip', tailclip:, label: "tailclip: ") # default: true; if false, edge is not clipped to tail node boundary
    # graph.set_edge_options('EDGE_OPTS', 'tailhref', tailhref:, label: "tailhref: ") # synonym for tailURL
    # graph.set_edge_options('EDGE_OPTS', 'tailport', tailport:, label: "tailport: ") # n,ne,e,se,s,sw,w,nw
    # graph.set_edge_options('EDGE_OPTS', 'tailtarget', tailtarget:, label: "tailtarget: ") # if tailURL is set, determines browser window for URL
    # graph.set_edge_options('EDGE_OPTS', 'tailtooltip', tailtooltip:, label: "tailtooltip: ") # default: label; tooltip annotation near tail of edge
    # graph.set_edge_options('EDGE_OPTS', 'tailURL', tailURL:, label: "tailURL: ") # URL attached to tail label if output format is ismap
    # graph.set_edge_options('EDGE_OPTS', 'target', target:, label: "target: ") # if URL is set, determines browser window for URL
    # graph.set_edge_options('EDGE_OPTS', 'tooltip', 'tooltip: label: "'tooltip ")

    get_edge_setting = proc { |u, v| graph.edge_options[graph.edge_class.new(u, v)] }

    edge_options = {
      'arrowhead' => get_edge_setting,
      'arrowsize' => get_edge_setting,
      # 'arrowtail' => get_edge_setting,
      # 'color' => get_edge_setting,
      # 'colorscheme' => get_edge_setting,
      # 'comment' => get_edge_setting,
      # 'constraint' => get_edge_setting,
      # 'decorate' => get_edge_setting,
      # 'dir' => get_edge_setting,
      # 'edgeURL' => get_edge_setting,
      # 'edgehref' => get_edge_setting,
      # 'edgetarget' => get_edge_setting,
      # 'edgetooltip' => get_edge_setting,
      # 'fontcolor' => get_edge_setting,
      # 'fontname' => get_edge_setting,
      # 'fontsize' => get_edge_setting,
      # 'headclip' => get_edge_setting,
      # 'headhref' => get_edge_setting,
      # 'headlabel' => get_edge_setting,
      # 'headport' => get_edge_setting,
      # 'headtarget' => get_edge_setting,
      # 'headtooltip' => get_edge_setting,
      # 'headURL' => get_edge_setting,
      # 'href' => get_edge_setting,
      # 'id' => get_edge_setting,
      'label' => get_edge_setting,
      # 'labelangle' => get_edge_setting,
      # 'labeldistance' => get_edge_setting,
      # 'labelfloat' => get_edge_setting,
      # 'labelfontcolor' => get_edge_setting,
      # 'labelfontname' => get_edge_setting,
      # 'labelfontsize' => get_edge_setting,
      # 'labelhref' => get_edge_setting,
      # 'labelURL' => get_edge_setting,
      # 'labeltarget' => get_edge_setting,
      # 'labeltooltip' => get_edge_setting,
      # 'layer' => get_edge_setting,
      # 'lhead' => get_edge_setting,
      # 'ltail' => get_edge_setting,
      # 'minlen' => get_edge_setting,
      # 'penwidth' => get_edge_setting,
      # 'samehead' => get_edge_setting,
      # 'sametail' => get_edge_setting,
      # 'style' => get_edge_setting,
      # 'weight' => get_edge_setting,
      # 'tailclip' => get_edge_setting,
      # 'tailhref' => get_edge_setting,
      # 'taillabel' => get_edge_setting,
      # 'tailport' => get_edge_setting,
      # 'tailtarget' => get_edge_setting,
      # 'tailtooltip' => get_edge_setting,
      # 'tailURL' => get_edge_setting,
      # 'target' => get_edge_setting,
      # 'tooltip' => get_edge_setting,
    }

    dot_options = { 'rankdir' => 'LR', 'edge' => edge_options }

    dot = graph.to_dot_graph(dot_options).to_s
    graph.write_to_graphic_file('svg', 'edge-opts-graph', dot_options)

    assert_match(dot, /arrowhead \[\n\s*arrowhead = empty,\n\s*fontsize = 8,\n\s*label = "arrowhead: empty"*/)
    assert_match(dot, /arrowsize \[\n\s*arrowsize = 3,\n\s*fontsize = 8,\n\s*label = "arrowsize: 3"*/)
  end
end