# From c.l.r SNIP IT: bond TkCanvas with RubyGraphLibrary
# author: Phlip (see also
# http://www.rubygarden.org/ruby?RubyAlgorithmPackage/TkCanvasSample) 
# 
# put a GraphViz graph into a TkCanvas, and make nodes
# selectable. Illustrates a bug in GraphViz

require 'rgl/graphxml'
require 'rgl/adjacency'
require 'rgl/dot'
require 'tk'

include RGL
filename = ARGV[0]
puts 'Displaying ' + filename

# ruby canvas.rb north/g.10.8.graphml &
# ruby canvas.rb north/g.12.8.graphml &
# ruby canvas.rb north/g.14.9.graphml &

File.open(filename) { |file|
  graph = DirectedAdjacencyGraph.from_graphxml(file)      
  graph.write_to_graphic_file('gif', filename)
  graph.write_to_graphic_file('plain', filename)
  root = TkRoot.new{title "Ex1"}
  
  canvas = TkCanvas.new(root)  {
	width  400
	height 600
  }
  canvas.pack()
  ovals = []

  TkcImage.new(canvas, 0, 0) {
	anchor 'nw'
	
	image TkPhotoImage.new() {
	  file filename + '.gif'
	}
  }

  #  read the 'plain' file, and for each node put an invisible
  #  oval over its image
  
  File.open(filename + '.plain')  {  |f|
	graphLine = f.readline()
	graphStats = graphLine.split()
	graphHeight = graphStats[3].to_f()
	nodeLine = f.readline()
	fields = nodeLine.split()
	
	while fields[0] == 'node' 
	  namer = fields[1]

	  #  the following crud is because GraphViz has no system to 
	  #  emit a "plain" format in pixels that exactly match the
	  #  locations of objects in dot's raster output

	  #  furtherless, the current GraphViz seems to be centering
	  #  the raster output but not the 'plain' output. Hence on
	  #  g.10.8.graphml the X fudge factor must be 45. >sigh<
	  
	  #  YMMV, based on your system's opinion of the size of an inch

	  exx  = fields[2].to_f * 96 - 20 # 45
	  why  = (graphHeight - fields[3].to_f()) * 96 - 20
	  widt = fields[4].to_f() * 90
	  hite = fields[5].to_f() * 90
	  
	  ov = TkcOval.new(canvas, exx, why, 
					   exx + widt, why + hite)  {
		state 'hidden'
		width 4
		outline 'green'
		tags namer
	  }
	  ovals.push(ov)
	  nodeLine = f.readline()
	  fields = nodeLine.split()
	end
  }
  lastOval = ovals[0]

  #  at click time, search for an oval in range and display it
  
  canvas.bind('Button-1')  do |event|
	x,y = canvas.canvasx(event.x), canvas.canvasy(event.y)
	
	ovals.each { |r|
	  x1,y1,x2,y2 = r.coords()
	  
	  if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
		lastOval.configure('state' => 'hidden')
		lastOval = r
		lastOval.configure('state' => 'normal')
		break
	  end
	}
  end

  Tk.mainloop
}

