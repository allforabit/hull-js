Hull = window.Hull = window.Hull || {}

Hull.templates  ?= {}
Hull.init       = (config, cb, errcb)->
  require ['lib/hull'], (app)->
    app(config, cb, errcb)

Hull.widget     = (widgetName, parent, widgetDef)->
  if !widgetDef
    widgetDef = parent
    parent = {}

  widgetDef = widgetDef() if Object.prototype.toString.apply(widgetDef) == '[object Function]'
  widgetDef.type      ?= "Hull"

  if typeof parent == 'string'
    [parentName, parentSrc] = parent.split '@'
    parentSrc ?= 'default'
    define "__widget__$#{widgetName}@default", ["__widget__$#{parentName}@#{parentSrc}"], (p)-> _.extend {}, p, widgetDef
  return widgetDef

define ['lib/version', 'underscore'], (version, _) ->
  window.Hull.version ||= version
  window.Hull

