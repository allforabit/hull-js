define({
  require: {
    paths: {
      rivets: '../bower_components/rivets/dist/rivets'
    }
  },
  initialize: function(app){
    var rivets = require('rivets');
    app.components.after('render', function(){
      //not working for some reason
      this.rivetsTemplate = rivets.bind(this.el, this.data);
    });
    app.components.after('remove', function(){
      //tidy up
      this.rivetsTemplate.unbind();
    });
  }
});
