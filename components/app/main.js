Hull.component({
  templates: ['app'],
  initialize: function() {

    this.dataTest = {
      bla: 'bla',
      bla2: 'bla 2'
    };

    setTimeout(this.changeData.bind(this), 3000);
    setTimeout(this.changeData2.bind(this), 6000);

  },
  changeData: function(){
    this.dataTest.bla = 'waahhaa wahh';
  },
  changeData2: function(){
    this.dataTest.bla = 'Yo ho ho';
  },
  afterRender: function(data){
    //todo move to extension
    this.rivetsTemplate = rivets.bind(this.el, this.dataTest);
  },
  afterRemove: function(){
  }
});
