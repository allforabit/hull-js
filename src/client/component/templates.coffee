define ['underscore', 'handlebars', 'lib/utils/promises'], (_, Handlebars, promises) ->

  strategies =
    app: ['hullGlobal', 'meteor', 'sprockets', 'hullDefault']
    dom: ['inner', 'global']
    server: ['require']

  #Compiles the template depending on its definition
  setupTemplate = (tplSrc, tplName, wrapped) ->
    engine = module.templateEngine
    if (!_.isFunction(tplSrc))
      compiled = engine.compile tplSrc
    else if !wrapped
      compiled = engine.template tplSrc
    else
      compiled = tplSrc

    engine.registerPartial(tplName, compiled)
    compiled

  _domTemplate = ($el)->
    module.domFind($el.get(0)).text() if $el.length

  strategyHandlers =
    dom:
      inner: (selector, tplName, el)->
        $el = module.domFind(selector, el)
        _domTemplate($el)
      global: (selector, tplName)->
        $el = module.domFind(selector, document)
        _domTemplate($el)
    app:
      hullGlobal: (tplName)->
        if module.global.Hull.templates[tplName]
          setupTemplate module.global.Hull.templates["#{tplName}"], tplName
      meteor: (tplName)->
        if module.global.Meteor? && module.global.Template?[tplName]?
          module.global.Template[tplName]
      sprockets: (tplName)->
        if module.global.HandlebarsTemplates? && module.global.HandlebarsTemplates?[tplName]?
          setupTemplate(module.global.HandlebarsTemplates[tplName], tplName, true)
      hullDefault: (tplName)->
        if module.global.Hull.templates._default?[tplName]
          setupTemplate(module.global.Hull.templates._default[tplName],  tplName)
    server:
      require: (tplName, path, format)->
        path = "text!#{path}.#{format}"
        dfd = module.deferred.deferred()
        module.require [path], (tpl)->
          dfd.resolve setupTemplate(tpl, tplName)
        , (err)->
          console.error "Error loading template", tplName, err.message
          dfd.reject err
        dfd

  _execute = (type, args...)->
    for stratName in strategies[type]
      strategyResult = strategyHandlers[type][stratName](args...)
      return strategyResult if strategyResult

  applyDomStrategies = (tplName, el)->
    selector = "script[data-hull-template='#{tplName}']"
    tpl = _execute('dom', selector, tplName, el)
    setupTemplate(tpl, tplName) if tpl

  applyAppStrategies = (tplName)->
    _execute('app', tplName)

  applyServerStrategies = (tplName, path, format)->
    _execute('server', tplName, path, format)


  lookupTemplate = (options, name)->
    path = "#{options.ref}/#{name}"
    tplName = [options.componentName, name.replace(/^_/, '')].join("/")

    tpl = applyDomStrategies tplName, options.rootEl if module.domFind
    tpl = applyAppStrategies tplName unless tpl

    module.define path, tpl if tpl

    tpl = applyServerStrategies tplName, path, options.templateFormat unless tpl
    tpl

  module =
    global: window
    require: require
    define: define
    templateEngine: Handlebars
    domFind: undefined
    deferred: undefined
    initialize: (app) ->
      module.domFind = app.core.dom.find
      module.deferred = promises
      app.core.template.load = (names=[], ref, el, format="hbs") ->
        dfd = module.deferred.deferred()
        names = [names] if _.isString(names)
        componentProps =
          componentName: ref.replace('__component__$', '').split('@')[0]
          templateFormat: format
          rootEl: el
          ref: ref

        tpls = _.map names, _.bind(lookupTemplate, undefined, componentProps)
        module.deferred.all(tpls).then (ary)->
          dfd.resolve _.object(names, ary)
        , (err)->
          console.warn('WARNING', err)
          dfd.reject err
        dfd.promise
  module
