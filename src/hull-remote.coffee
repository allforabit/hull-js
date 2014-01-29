define ['aura/aura', 'lib/utils/version'], (Aura, version)->

  hull = null

  Hull = (config)->
    return hull if hull && hull.app
    hull = { config }
    config.debug ?= false
    config.components = false
    hull.app = Aura(config)
    hull.app.use('lib/remote/services')
    hull.app.use('lib/remote/handler')
    hull.app.use('lib/remote/current-user')
    hull.app.use('lib/remote/services/hull')

    hull.app.use('lib/remote/services/facebook') if config?.services?.settings?.facebook_app?.appId

    services = ['github', 'twitter', 'instagram', 'soundcloud', 'angellist', 'tumblr', 'linkedin']
    _.each services, (value, index) ->
      hull.app.use "lib/remote/services/#{value}" if config?.services?.settings?["#{value}_app"]

    hull.app.start()

    return hull

  window.Hull = Hull
  Hull.version = version
  Hull
