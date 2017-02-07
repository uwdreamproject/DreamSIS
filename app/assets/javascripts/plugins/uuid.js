(function() {
  this.App || (this.App = {});

  App.uuid = (function() {

  // From https://gist.github.com/jed/982883
  function b(a){return a?(a^Math.random()*16>>a/4).toString(16):([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g,b)}
  
  return {
    v4: function() {
      return b();
    }
  }
})();

}).call(this);
