Hull.extension({
  require: {
    paths: {
      rivets: '../bower_components/rivets/dist/rivets'
    }
  },
  initialize: function(app){

    //todo find a way of requiring modules 
    //similarly to components
    //for now just adding as script in index.html
    var rivets = this.require('rivets');
    console.log(rivets);

    app.components.after('dorender', function(){
      //not working for some reason
      this.rivetsTemplate = rivets.bind(this.el, this.data);
    });

    app.components.after('remove', function(){
      alert('remove');
      //tidy up
      this.rivetsTemplate.unbind();
    });
    
  }
});
