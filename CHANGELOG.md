# Changelog

## [0.6.7](https://github.com/monora/rgl/compare/v0.6.6...v0.6.7) (2026-05-10)

### Bug Fixes

* Fix command injection vulnerability in `write_to_graphic_file` ([#154](https://github.com/monora/rgl/issues/154))

### Improvements

* Allow `class` attribute in SVG output via Graphviz ([#142](https://github.com/monora/rgl/issues/142))
* Ruby code modernization: frozen string literals, keyword arguments ([#160](https://github.com/monora/rgl/issues/160))

### Maintenance

* Modernize gemspec ([#158](https://github.com/monora/rgl/issues/158))
* Update CI matrix, remove stale dev environment files ([#157](https://github.com/monora/rgl/issues/157))
* Repository cleanup ([#156](https://github.com/monora/rgl/issues/156))
* Fix outdated links, typos, and missing community files ([#159](https://github.com/monora/rgl/issues/159))

## [0.6.6](https://github.com/monora/rgl/compare/v0.6.5...v0.6.6) (2023-07-10)

### Bug Fixes

* Update pairing_heap requirement from ~> 0.3 to >= 0.3, < 4.0 ([#119](https://github.com/monora/rgl/issues/119), [#122](https://github.com/monora/rgl/issues/122)) ([13e39a4](https://github.com/monora/rgl/commit/13e39a47dd166a36dadbf8e3b5fb3b2ff3941467))
* Bump GoogleCloudPlatform/release-please-action from 2 to 3 ([#120](https://github.com/monora/rgl/issues/120), [#122](https://github.com/monora/rgl/issues/122)) ([3e804d4](https://github.com/monora/rgl/commit/3e804d43de547b8c5754c9c53393973ca6882016))

## [0.6.5](https://github.com/monora/rgl/compare/v0.6.4...v0.6.5) (2023-06-19)

### Bug Fixes

* README links ([#114](https://github.com/monora/rgl/issues/114)) ([682e4e6](https://github.com/monora/rgl/commit/682e4e6f3786dc5419ce8d8bff92d4006e95be0d))

## [0.6.4](https://github.com/monora/rgl/compare/v0.6.3...v0.6.4) (2023-06-19)

### Bug Fixes

* Add test case for `bfs_search_tree_from` (fixes [#99](https://github.com/monora/rgl/issues/99)) ([54f92e4](https://github.com/monora/rgl/commit/54f92e497c0e628c5dcdab3334ef280f6f38bfd7))
* Remove require of the file if already required ([0ef2ce5](https://github.com/monora/rgl/commit/0ef2ce5c43c56503268303abac40fd841c4cea43))

## Ältere Geschichte

Releases 0.6.0–0.6.3 sind in der [GitHub Releases-Liste](https://github.com/monora/rgl/releases) dokumentiert.

### 0.5.x (2015–2022)

Große Algorithmen-Erweiterungen durch @KL-7: Dijkstra, Bellman-Ford, Prim MST,
Edmonds-Karp Maximum Flow, bipartite Mengen, `Graph#path?`. Wechsel von
`lazy_priority_queue` zu `pairing_heap`. Migration von Travis CI zu GitHub Actions.

### 0.4.0 (2008)

DOT-Modul in den `RGL`-Namespace verschoben (Konflikt mit RDocs DOT-Modul beseitigt).
Transitive Reduktion ergänzt.

### 0.3.x (2008)

Verbessertes Quoting von DOT-IDs und Labels gemäß Graphviz-Spezifikation.
Vollständige Testabdeckung für `rdot.rb`. Subgraph-Header-Fix.

### 0.2.x (2004–2006)

Erstes RubyGems-Paket. GraphML-Import via REXML. Zykelerkennung, Graph-Gleichheit,
`initialize_copy` für Clone-Unterstützung.

### 0.1 / Erstveröffentlichung (2002)

Erste öffentliche Veröffentlichung auf RubyForge. Kern-Abstraktionen (`each_vertex`,
`each_adjacent`), Adjacency-List-Darstellung, DOT-Export.
