(function() {
  var Entity, Game, World, getContext, myPlaneId, onEachFrame, time;

  getContext = function() {
    var ctx;
    ctx = $('#maincanvas')[0].getContext('2d');
    ctx.canvas.width = window.innerWidth;
    ctx.canvas.height = window.innerHeight;
    return ctx;
  };

  myPlaneId = null;

  now.updateBullet = function(bullet) {
    return console.log(bullet);
  };

  now.updatePlane = function(plane) {
    if (plane.id === myPlaneId) {
      return new Player(plane);
    } else {
      return new Plane(plane);
    }
  };

  now.notifyMyPlane = function(planeId) {
    return myPlaneId = planeId;
  };

  time = function() {
    return (new Date).getTime();
  };

  Entity = (function() {

    function Entity(id) {
      this.id = id;
    }

    return Entity;

  })();

  World = (function() {

    function World() {}

    World.prototype.update = function() {};

    return World;

  })();

  Game = (function() {

    function Game(fps) {
      if (fps == null) fps = 60;
      this.ctx = getContext();
      this.fps = fps;
      this.nextGameTick = time();
      this.fpsData = [];
      this.skipTicks = 1000.0 / fps;
      this.world = new World;
      now.helloServer();
    }

    Game.prototype.update = function() {
      return this.world.update();
    };

    Game.prototype.render = function() {
      var currentTime, idx, testrender;
      testrender = function(ctx) {
        var h, w;
        w = ctx.canvas.width;
        h = ctx.canvas.height;
        ctx.beginPath();
        ctx.arc(Math.random() * w, Math.random() * h, Math.random() * 50 + 50, 0, 2 * 3.141592);
        ctx.closePath();
        return ctx.stroke();
      };
      testrender(this.ctx);
      currentTime = time();
      idx = 0;
      while (idx < this.fpsData.length) {
        if (this.fpsData[idx] + 1000 < currentTime) {
          this.fpsData[idx] = this.fpsData[this.fpsData.length - 1];
          this.fpsData.pop();
        } else {
          idx += 1;
        }
      }
      this.fpsData.push(currentTime);
      return $("#fpsText").text(this.fpsData.length);
    };

    Game.prototype.start = function() {
      var _this = this;
      return onEachFrame(function() {
        return _this.gameloop();
      });
    };

    Game.prototype.gameloop = function() {
      var MAX_FRAME_SKIP, updateProcessed;
      updateProcessed = 0;
      MAX_FRAME_SKIP = 10;
      while (time() > this.nextGameTick && updateProcessed < MAX_FRAME_SKIP) {
        this.update();
        updateProcessed += 1;
        this.nextGameTick += this.skipTicks;
      }
      if (updateProcessed) return this.render();
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

  now.ready(function() {
    return $(document).ready(function() {
      return new Game().start();
    });
  });

}).call(this);
