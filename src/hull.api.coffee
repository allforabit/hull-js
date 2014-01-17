define [
  'lib/utils/emitter'
  'lib/api/api'
  'lib/api/reporting',
  'lib/utils/entity',
  'lib/utils/config'
  ], (emitter, api, reporting, entity, configParser) ->

    create = (config)->
      _emitter = emitter()
      api.init(config).then (api)->
        _reporting = reporting.init(api)
        _emitter.on 'hull.auth.login', (me)-> _reporting.track('hull.auth.login', me)
        _emitter.on 'hull.auth.logout', ()-> _reporting.track('hull.auth.logout')

        created =
          config: configParser(config)
          on: _emitter.on
          off: _emitter.off
          emit: _emitter.emit
          track: _reporting.track
          flag: _reporting.flag
          api: api.api
          login: (args...)->
            if (api.auth.isAuthenticating())
              console.info "Authentication is in progress. Use `Hull.on('hull.auth.login', fn)` to call `fn` when done."
              return
            api.auth.login(args...).then ()->
              api.api('me').then (me)->
                _emitter.emit 'hull.auth.login', me
            , (err)->
              _emitter.emit 'hull.auth.fail', err
          logout: (args...)->
            api.auth.logout(args...).then ()->
              _emitter.emit('hull.auth.logout')
          util:
            entity: entity
            eventEmitter: _emitter
        created.api.create = create
        raw: api
        api: created
        eventEmitter: _emitter

    failure = (error)->
      console.error('Unable to start Hull.api', error)
      error

    init: (config)-> create(config)
    success: (successResult)->
      exports: successResult.api
      context:
        me: successResult.raw.remoteConfig.data.me
        app: successResult.raw.remoteConfig.data.app
        org: successResult.raw.remoteConfig.data.org
    failure: failure
