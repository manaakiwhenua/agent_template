# Changelog

## 0.2 - ???


### Added
- Configuration file specified on the command line with, e.g.,
  - ```python -m agent_template config.yaml```
- Override configuration file on command line with
  - ```python -m agent_template config.yaml plot=solara```

## 0.1 - 2024-01-10

### Changed
- Update README.md, CHANGELOG.md
- Simplify LU-network-rule in netlogo
- Fix random seed for development in Netlogo, so that graphs will be identical when testing code changes.
- Replace "occurrence" repeated code with a modulo function in Netlogo. This will work after 30 ticks.
- Modify the occurrence test so that the update-occurrence function is not needed, hopefully what you wanted.
- Set multiple variables in one line, (e.g., set [LU pcolor] [1 8]). This requires netlogo 6.4.0.
- Convert some repeated code into loops moved some data definitions into setup

### Added
- Plot with Solara in python version
- Use raster and shape file inputs to generate Netlogo initial land use.
