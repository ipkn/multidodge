(function() {
  var Game, getContext, onEachFrame;

  getContext = function() {
    var ctx;
    ctx = $('#maincanvas')[0].getContext('2d');
    ctx.canvas.width = window.innerWidth;
    ctx.canvas.height = window.innerHeight;
    return ctx;
  };

  Game = (function() {

    function Game() {
      this.ctx = getContext();
    }

    Game.prototype.gameloop = function() {
      var ctx, h, w;
      ctx = this.ctx;
      w = ctx.canvas.width;
      h = ctx.canvas.width;
      ctx.beginPath();
      ctx.arc(Math.random() * w, Math.random() * h, Math.random() * 50 + 50, 0, 2 * 3.141592);
      ctx.closePath();
      return ctx.stroke();
    };

    Game.prototype.start = function() {
      var _this = this;
      return onEachFrame(function() {
        return _this.gameloop();
      });
    };

    return Game;

  })();

  if (window.webkitRequestAnimationFrame) {
    onEachFrame = function(cb) {
      var _cb;
      var _this = this;
      _cb = function() {
        cb();
        return webkitRequestAnimationFrame(_cb);
      };
      return _cb();
    };
  } else if (window.mozRequestAnimationFrame) {
    onEachFrame = function(cb) {
      var _cb;
      var _this = this;
      _cb = function() {
        cb();
        return mozRequestAnimationFrame(_cb);
      };
      return _cb();
    };
  } else {
    onEachFrame = function(cb) {
      return setInterval(cb, 1000 / 60);
    };
  }

  $(document).ready(function() {
    return new Game().start();
  });

}).call(this);
