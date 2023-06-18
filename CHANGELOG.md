# Changelog

## Changelog from 0.5.10 to 0.6.3

See [Releaselist in GitHub](https://github.com/monora/rgl/releases). From v0.6.4
on the Changelog is updated by
[release-please](https://github.com/googleapis/release-please#release-please)
GitHub Action (Issue #101)

## Changelog prior 0.5.9

### 2022-08 Release 0.5.9

Dan Čermák
 * Drop lazy priority queue (#64) (3b1db1)

### 2022-06 Release 0.5.8

Horst Duchene
 * switch to github actions (56030d)

### 2020-12 Release 0.5.7

Horst Duchene
 * Fully automate dev setup with Gitpod (41dd00)
 * Add Dockerfile to install graphviz (2bd738)
 * Examples do not call dotty (6bba96)
 * Add ruby license file (a21aa5)
ujihisa <ujihisa@users.noreply.github.com>
 * Test against Ruby 2.6 and 2.7 as well (50ac7c)
 * Fix dead links (9184f3)
Harry Lascelles <hlascelles@users.noreply.github.com>
 * Update .travis.yml (45b9a2)
 * Make the links more explicit (95dc3b)
Harry Lascelles
 * Add explicit license to gemspec (de3647)

### 2019-01 Release 0.5.6

Artemy Kirienko
 * PR #42 Add method Graph#path?(u, v) to check if a path exists between two vertices
Horst Duchene
 * Fix #47 set_to_begin for graph iterator (881aa8)

### 2019-01 Release 0.5.4

Lia Skalkos
 * Enable options to be passed to #write_to_graphic_file (4ca972). For details see PR #41
Horst Duchene
 * Fix travis-ci errors
 * Add new ruby versions
 * Fix gemspec errors
 * Fix lint warnings
 * Use version stream 0.5.2

### 2017-04 Release 0.5.3

Horst Duchene
 * Issue #38: Add error handling or dot functions. (719e38, 5a3423)
Thomas Orozco
 * Remove Enumerable Extension (fde8a5)
 * Update to codeclimate-test-reporter 1.x (25fdb5)
Mario Daskalov
 * Clarify that you need graphviz in the README (35a4b4)

### 2016-05 Release 0.5.2

Horst Duchene
 * Issue #21: Use new method vertex_id instead of object_id to identify vertices in dot export. (fa7592)
 * Integrate Code Climate's test coverage reporting (0ab722)
 * Clarify traversal order of DFS search (see #20). (afa788)
Chase Gilliam
 * drop 1.9.3 add newer jruby and rubinius (fad333)
Matías Battocchia
 * Switched to a different heap implementation. (bd7c13)
gorn
 * Adding failing test for issue #24 (1f6204)

### 2015-12 Release 0.5.1

Horst Duchene
 * Changed edge sequence to match example picture (daa88e)

Chase
 * updated algorithms to 6.1 and added test unit to support newer rubies (fbd874)

Louis Rose
 * Fix #15. Use object IDs rather than labels to identify vertexs in DOT graph
   to ensure that distinct nodes that share a label are shown. (33206f, 4fc455)

### 2014-12 Release 0.5.0

Horst Duchene
  * Changed edge sequence to match example picture (daa88e)
  * Fixed comment (6a6c93)
  * Fixed spelling (7ca281)
Horst Duchêne
Chase
  * updated algorithms to 6.1 and added test unit to support newer rubies (fbd874)
Louis Rose
  * Fix #15. Use object IDs rather than labels to identify vertexs in DOT graph to ensure that distinct nodes that share a label are shown. (33206f)
  * Issue #15. Fix tests. (4fc455)

### 2014-12 Release 0.5.0

Horst Duchene
  * Changed edge sequence to match example picture (daa88e)
  * Fixed comment (6a6c93)
  * Fixed spelling (7ca281)
Chase
  * updated algorithms to 6.1 and added test unit to support newer rubies (fbd874)
Louis Rose
  * Fix #15. Use object IDs rather than labels to identify vertexs
	in DOT graph to ensure that distinct nodes that share a label are
	shown. (33206f)
  * Issue #15. Fix tests. (4fc455)

### 2014-12 Release 0.5.0

This release mainly contains the contributions of Kirill, who added many algorithms to the library. Thank you Kirill!

 * @matiaskorhonen: Fixes the image paths in the README (#14)
 * @monora: Implicit graph example fails (#13)
 * @KL-7: Implement Graph#bipartite_sets. (#12)
 * @monora:  syntax error in dot file for undirected graph (#11)
 * @KL-7: Edmonds-Karp algorithm for maximum flow (#10)
 * @KL-7: Prim's algorithm for minimum spanning tree (#9)
 * @carlosantoniodasilva: Run tests on Ruby 2.0 and remove deprecation warning (#8)
 * @KL-7: Bellman-Ford shortest paths algorithm (#7)
 * @KL-7: Minor improvements (asserts) for Dijkstra algorithm (#6)
 * @KL-7: Add Dijkstra shortest path algorithm. (#5)
 * @KL-7: Indentation and whitespaces clean up of examples (#4)
 * @KL-7: Travis configuration and README updates (#3)
 * @KL-7: Code clean up and configuration updates (#2)
 * @aschoerk: Renamed test-directory, (includes Rakefile), fixed TestComponents (#1)

### 2008-08-27 23:30  javanthropus

* lib/rgl/base.rb: Preparing for 0.4.0 release

### 2008-08-26 20:07  javanthropus

 * lib/rgl/dot.rb, lib/rgl/rdot.rb, tests/TestRdot.rb: Move the DOT
	  module into the RGL module

	  * This eliminates a class conflict with the DOT module from rdoc
	  when building RGL's documentation * Also remove the superfluous
	  DOT prefixes from class names in the DOT module

### 2008-08-24 06:16  javanthropus

 * Rakefile: Remove some comments I accidentally left in while
	  testing rdoc functionality

### 2008-08-24 06:03  javanthropus

 * Rakefile, lib/rgl/transitiv_closure.rb, lib/rgl/transitivity.rb,
	  tests/TestTransitiveClosure.rb, tests/TestTransitivity.rb:
	  Feature 21641: Added transitive reduction functionality

	  * Updated the gem description to announce this functionality *
	  Moved the transitive closure functionality into the
	  transitivity.rb file along with the transitive reduction
	  funtionality * Modifed the transitiv_closure.rb file to simply
	  load the transitivity.rb file for backward compatibility * Moved
	  all transitivity tests into TestTransitivity.rb

### 2008-08-23 15:45  javanthropus

 * lib/rgl/condensation.rb, lib/rgl/transitiv_closure.rb,
	  tests/TestTransitiveClosure.rb: Defect 21630: Fixed transitive
	  closure

	  * The fix is based on the algorithm described in the
	  documentation for the implementation of transitive closure in
	  Boost * Along with the fix, performance is improved to O(|V||E|)
	  * This implementation needs graph condensation, so that function
	  was added as well * More tests were added to cover more corner
	  cases

### 2008-08-23 05:40  javanthropus

 * tests/TestGraph.rb: Update basic graph tests to account for
	  graphs with edgeless vertices Also clean up some minor formatting
	  and assertion issues

### 2008-08-23 05:37  javanthropus

 * lib/rgl/adjacency.rb: Defect 21609: Fix the to_adjacency method
	  to preserve edgeless vertices

### 2008-03-18 15:03  javanthropus

 * lib/rgl/rdot.rb, tests/TestRdot.rb: More reliably detect and
	  handle newlines embedded within IDs and labels

### 2008-03-08 10:48  monora

 * ChangeLog, lib/rgl/base.rb (utags: REL_0_3_1): Prepare 0.3.1
	  release

### 2008-03-04 20:18  monora

 * Rakefile (tags: REL_0_3_1, REL_0_3_0): pre-tag commit

### 2008-03-02 18:16  javanthropus

 * lib/rgl/rdot.rb (tags: REL_0_3_0): IDs and labels must be
	  converted to strings before processing

### 2008-03-02 17:45  javanthropus

 * lib/rgl/rdot.rb, tests/TestRdot.rb: Added documentation for
	  rdot.rb and full test coverage

### 2008-03-02 15:19  monora

 * README: Removed dead link to rubygarden.com

### 2008-03-02 15:09  monora

 * ChangeLog, README, Rakefile (utags: REL_0_3_0): Polishing before
	  0.3.0 release

### 2008-03-02 13:45  monora

 * lib/rgl/: adjacency.rb, rdot.rb (utags: REL_0_3_0): Fixed
	  warnings generated by Ruby Dev Tools

### 2008-03-02 07:57  javanthropus

 * Rakefile, lib/rgl/graphxml.rb (tags: REL_0_3_0),
	  tests/TestGraphXML.rb (tags: REL_0_3_0): Change the way GraphML
	  support is added to the MutableGraph module such that the
	  interface is cleaner and documented

### 2008-03-01 20:12  javanthropus

 * lib/rgl/base.rb, tests/TestGraph.rb: Polish the documentation for
	  and expand the test coverage of RGL::Graph

### 2008-02-27 19:44  monora

 * README: Added link to coverage page

### 2008-02-26 06:01  javanthropus

 * lib/rgl/dot.rb, lib/rgl/rdot.rb, tests/TestDot.rb,
	  tests/TestRdot.rb: All IDs for DOT objects, including names,
	  options, and values, are now automatically quoted as necessary
	  according to the rules documented at
	  https://www.graphviz.org/doc/info/lang.html and
	  https://www.graphviz.org/Documentation/dotguide.pdf.

	  Labels are handled specially in order to account for \l, \r, and
	  \n sequences but are otherwise treated the same as other options.

	  New tests were added to confirm proper function.

	  Some changes were made in order to remove explicit quotes from
	  labels which are no longer necessary.

### 2008-02-17 20:15  monora

 * lib/rgl/enumerable_ext.rb: Removed backwards compatability method
	  inject. Ruby > 1.8 supports it out of the box.

### 2008-02-17 20:07  monora

 * tests/: TestEdge.rb, TestDirectedGraph.rb, TestGraph.rb: Improved
	  test coverage

### 2008-02-17 20:06  monora

 * lib/rgl/adjacency.rb: fixed bug in edgelist_class

### 2008-02-17 17:59  monora

 * Rakefile: - added coverage task - fixed BUG #2674 - added
	  changelog task - use jamis buck rdoc template

### 2008-02-17 17:45  monora

 * lib/rgl/base.rb: Changed Version to 0.3.0

### 2008-02-17 09:09  javanthropus

 * lib/rgl/rdot.rb: DOTSimpleElement provides no useful function, so
	  remove it

### 2008-02-17 09:08  javanthropus

 * tests/TestRdot.rb: Test that setting only the name for a DOTNode
	  does NOT set the label

### 2008-02-17 08:58  javanthropus

 * lib/rgl/rdot.rb, tests/TestRdot.rb: Add support for the Mrecord
	  shape to DOTNode.  Rewrite DOTNode#to_s to be easier to
	  understand.  #Rewrite DOTPort to allow for nesting ports.

### 2008-02-17 03:20  javanthropus

 * lib/rgl/rdot.rb, tests/TestRdot.rb: BUG 17964: DOTElement no
	  longer sets the label unless the user explicitly sets one

### 2008-02-17 02:56  javanthropus

 * tests/TestRdot.rb: Fix a DOTEdge test which was actually
	  retesting DOTNode

### 2008-02-16 19:58  javanthropus

 * lib/rgl/rdot.rb, tests/TestRdot.rb: BUG #17962: Subgraphs must be
	  identified by a "subgraph" header rather than a "graph" header

### 2008-02-13 22:32  monora

 * tests/TestRdot.rb: Fixed typo

### 2008-02-13 22:20  monora

 * doc/jamis.rb: Added template from Jamis Buck for rdoc. Looks
	  better.

### 2008-02-12 23:37  monora

 * lib/rgl/rdot.rb: BUG #17969: Applied patch from Jeremy Bopp.
	  Thanks.

### 2008-02-12 22:29  monora

 * README: fixed require in topsort example added delicious links

### 2007-12-11 21:04  wsdng

 * lib/rgl/rdot.rb, tests/TestRdot.rb: fixed [#16125] DOT::DOTNode
	  produces wrong DOT syntax

### 2007-12-11 00:21  wsdng

 * tests/: TestDot.rb, TestRdot.rb: reproduced [#16125] DOT::DOTNode
	  produces wrong DOT syntax

### 2007-06-20 22:43  monora

 * lib/rgl/base.rb, rakelib/dep_graph.rake: Fixed typo

### 2006-04-19 21:32  monora

 * rakelib/dep_graph.rake: - Use write_to_graphic_file instead of
	  dotty (dotty crashes) - omit added task from vertices

### 2006-04-12 23:45  monora

 * rakelib/dep_graph.rake: Initial checkin

### 2006-04-12 23:40  monora

 * lib/rgl/bidirectional.rb: Moved to module RGL

### 2006-04-12 23:36  monora

 * lib/rgl/base.rb: Moved BidirectionalGraph to own file.

### 2006-04-12 23:31  monora

 * lib/rgl/: base.rb, edge.rb, graph.rb: - Merged changes from Shawn
	  - dont want to split base.rb

### 2006-04-12 23:27  monora

 * tests/: TestCycles.rb, TestGraph.rb, test_helper.rb,
	  TestComponents.rb, TestTransitiveClosure.rb, TestTraversal.rb: -
	  Merged changes from Shawn - added test_helper

### 2006-04-12 23:23  monora

 * lib/rgl/adjacency.rb: - Merged changes from Shawn - implemented
	  clone support (initialize_copy)

### 2006-04-12 23:20  monora

 * lib/rgl/mutable.rb: Use clone instead of self.class.new(self)

### 2006-04-12 23:19  monora

 * lib/rgl/enumerable_ext.rb: Do not extend system class Array. Only
	  used for testing.

### 2006-03-28 19:10  monora

 * lib/rgl/dot.rb: Added links to graphviz.

### 2006-03-20 02:06  spgarbet

 * lib/rgl/adjacency.rb, lib/rgl/base.rb, lib/rgl/bidirectional.rb,
	  lib/rgl/edge.rb, lib/rgl/enumerable_ext.rb, lib/rgl/graph.rb,
	  lib/rgl/mutable.rb, tests/TestComponents.rb, tests/TestCycles.rb,
	  tests/TestGraph.rb, tests/TestTransitiveClosure.rb,
	  tests/TestTraversal.rb: Added equality test for graphs, added
	  cycle locating.  Modified initialize to allow duplicating and
	  merging of graphs.  Split base into various subfiles.  Added test
	  cases for changes.  Fixed problem with GraphXML.

### 2006-03-09 23:25  monora

 * lib/rgl/base.rb: Fixed typo Bug #2875

### 2006-03-03 22:28  monora

 * .cvsignore, .project: We now use Eclipse-RDT

### 2005-09-18 14:08  monora

 * tests/TestComponents.rb (tags: PRE_CHECKIN_JC): Fixed required
	  files.

### 2005-09-17 18:27  monora

 * lib/rgl/base.rb (tags: PRE_CHECKIN_JC): Documentation corrected.

### 2005-09-17 18:25  monora

 * README (tags: PRE_CHECKIN_JC): Added link to delicious.

### 2005-04-12 20:59  monora

 * Rakefile (tags: PRE_CHECKIN_JC): corrected homepage link in
	  gemspec

### 2005-04-12 20:50  monora

 * Makefile: rake is better than make

### 2005-04-12 20:35  monora

 * README (tags: REL_0_2_3): updated copyright notice

### 2005-04-12 20:32  monora

 * examples/examples.rb (tags: PRE_CHECKIN_JC, REL_0_2_3): Added
	  doc.

### 2005-04-12 18:23  monora

 * README: Fixed some outdated links.

### 2005-04-05 19:54  monora

 * ChangeLog (tags: PRE_CHECKIN_JC, REL_0_2_3): New entries
	  generated

### 2005-03-30 21:27  monora

 * tests/TestDirectedGraph.rb (tags: PRE_CHECKIN_JC, REL_0_2_3):
	  Added test for isolated vertices in DirectedGraph#reverse.

### 2005-03-30 21:25  monora

 * lib/rgl/adjacency.rb (tags: PRE_CHECKIN_JC, REL_0_2_3): Fixed bug
	  in DirectedGraph#reverse reported by Kaspar Schiess. Isolated
	  vertices were not treated correctly.

### 2005-03-26 15:06  wsdng

 * lib/rgl/rdot.rb (tags: PRE_CHECKIN_JC, REL_0_2_3): added node and
	  edge attributes

### 2005-03-22 22:31  monora

 * Rakefile (tags: REL_0_2_3): Fixed autorequire to work with gem
	  version 0.8.8

### 2005-02-04 22:41  monora

 * README, lib/rgl/adjacency.rb, lib/rgl/base.rb (tags: REL_0_2_3),
	  lib/rgl/connected_components.rb (tags: PRE_CHECKIN_JC,
	  REL_0_2_3), lib/rgl/dot.rb (tags: PRE_CHECKIN_JC, REL_0_2_3),
	  lib/rgl/graphxml.rb (tags: PRE_CHECKIN_JC, REL_0_2_3),
	  lib/rgl/implicit.rb (tags: PRE_CHECKIN_JC, REL_0_2_3),
	  lib/rgl/mutable.rb (tags: PRE_CHECKIN_JC, REL_0_2_3),
	  lib/rgl/rdot.rb, lib/rgl/topsort.rb (tags: PRE_CHECKIN_JC,
	  REL_0_2_3), lib/rgl/transitiv_closure.rb (tags: PRE_CHECKIN_JC,
	  REL_0_2_3), lib/rgl/traversal.rb (tags: PRE_CHECKIN_JC,
	  REL_0_2_3): Fixed some formatting issues and smoothed
	  documentation. Thanks to Rich Morin.

### 2004-12-13 23:33  monora

 * Makefile, README, Rakefile, lib/rgl/base.rb, lib/rgl/graphxml.rb,
	  lib/rgl/implicit.rb, lib/rgl/traversal.rb: Polished documentation

### 2004-12-13 21:07  monora

 * lib/rgl/adjacency.rb, tests/TestDirectedGraph.rb,
	  tests/TestUnDirectedGraph.rb (tags: PRE_CHECKIN_JC, REL_0_2_3):
	  Fixed bug in Graph#reverse reported by Sascha Ebach.

### 2004-12-12 19:09  cyent

 * tests/TestGraphXML.rb: Fixed bug in relative path

### 2004-12-12 19:08  cyent

 * tests/TestDirectedGraph.rb: Added test_random

### 2004-12-12 19:07  cyent

 * lib/rgl/: adjacency.rb, base.rb, connected_components.rb,
	  rdot.rb: Fixed comments, removed warnings in ruby1.9 -w by adding
	  attr_readers, told emacs to use tab-width 4 on these files

### 2004-12-11 23:46  monora

 * README (tags: REL_0_2_2), Rakefile (tags: REL_0_2_2),
	  examples/examples.rb (tags: REL_0_2_2), lib/stream.rb,
	  lib/rgl/base.rb (tags: REL_0_2_2), lib/rgl/graphxml.rb (tags:
	  REL_0_2_2), lib/rgl/traversal.rb (tags: REL_0_2_2),
	  tests/TestGraphXML.rb (tags: PRE_CHECKIN_JC, REL_0_2_3,
	  REL_0_2_2), tests/_TestGraphXML.rb: Added gem packaging.

### 2004-10-08 15:15  monora

 * tests/runtests.rb: In new testframework not needed.

### 2004-10-08 15:14  monora

 * lib/utils.rb: Code move to base.rb

### 2004-10-06 22:11  monora

 * lib/rgl/base.rb: Code from utils.rb included

### 2004-10-06 22:09  monora

 * Rakefile: First start for gem preparation

### 2003-07-30 21:50  monora

 * lib/utils.rb, lib/rgl/implicit.rb (tags: REL_0_2_2),
	  tests/TestComponents.rb (tags: REL_0_2_3, REL_0_2_2),
	  tests/TestDirectedGraph.rb (tags: REL_0_2_2),
	  tests/TestImplicit.rb (tags: PRE_CHECKIN_JC, REL_0_2_3,
	  REL_0_2_2), tests/TestTransitiveClosure.rb (tags: PRE_CHECKIN_JC,
	  REL_0_2_3, REL_0_2_2), tests/TestTraversal.rb (tags:
	  PRE_CHECKIN_JC, REL_0_2_3, REL_0_2_2),
	  tests/TestUnDirectedGraph.rb (tags: REL_0_2_2),
	  tests/_TestGraphXML.rb, tests/runtests.rb (utags: rforge-import):
	  - port to ruby 1.8 - compiler warnings removed - set_up -> setup
	  in testfiles

### 2002-11-13 21:53  monora

 * lib/rgl/: rdot.rb, dot.rb (utags: REL_0_2_2, rforge-import):
	  Name-attribute of DOTNode has to be escaped by ".

### 2002-11-10 21:21  monora

 * lib/: utils.rb, rgl/adjacency.rb (tags: REL_0_2_2,
	  rforge-import), set.rb: Use knus compatibility library for Ruby
	  1.8 esp. for set.rb and inject.

### 2002-09-22 15:58  monora

 * lib/rgl/dot.rb: to_dot_graph now also outputs vertices.

### 2002-09-22 15:57  monora

 * lib/rgl/adjacency.rb: cosmetic.

### 2002-09-17 22:58  monora

 * Makefile (tags: REL_0_2_2, rforge-import): Added releasedoc
	  target.

### 2002-09-17 22:57  monora

 * lib/rgl/: base.rb (tags: rforge-import), implicit.rb: Fixed typo.

### 2002-08-29 21:20  monora

 * ChangeLog: Changed NameError to NoVertexError.

### 2002-08-29 21:17  monora

 * tests/TestDirectedGraph.rb, tests/TestUnDirectedGraph.rb,
	  lib/rgl/adjacency.rb, lib/rgl/base.rb, ChangeLog: Changed
	  NameError to NoVertexError.

### 2002-08-23 22:07  monora

 * Makefile (tags: V0_2_1), README (tags: rforge-import, V0_2_1),
	  examples/canvas.rb (tags: PRE_CHECKIN_JC, REL_0_2_3, REL_0_2_2,
	  rforge-import, V0_2_1), examples/north/g.12.8.graphml (tags:
	  PRE_CHECKIN_JC, REL_0_2_3, REL_0_2_2, rforge-import, V0_2_1),
	  examples/north/g.14.9.graphml (tags: PRE_CHECKIN_JC, REL_0_2_3,
	  REL_0_2_2, rforge-import, V0_2_1), lib/dot/dot.rb,
	  lib/rgl/base.rb (tags: V0_2_1), lib/rgl/dot.rb (tags: V0_2_1),
	  lib/rgl/rdot.rb (tags: V0_2_1): canvas.rb added. Collision with
	  rdoc/dot.rb removed.

### 2002-08-19 21:58  monora

 * README (tags: V0_2): Added link to SF.
