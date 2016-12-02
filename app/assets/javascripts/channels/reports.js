//= require cable

(function() {
  this.App || (this.App = {});

  App.cable = Cable.createConsumer("ws://can.dreamsis.dev:5000/cable");
  
}).call(this);
