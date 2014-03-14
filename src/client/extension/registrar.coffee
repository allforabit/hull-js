define ['underscore'], (_) ->
  (app)->
    (extensionDef)->
      obj = _.extend(extensionDef, {
        require: require
      });
      console.log(obj)
      app.use(obj)
