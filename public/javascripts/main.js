(function() {
  var Bullet, Entity, Game, MAX_SPEED, PI, Plane, Player, World, game, getContext, getMyPlane, keyboardHandler, myPlaneId, onEachFrame, pingTime, time;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  PI = 3.1415926535;

  MAX_SPEED = 50;

  getContext = function() {
    var ctx;
    ctx = $('#maincanvas')[0].getContext('2d');
    ctx.canvas.width = window.innerWidth;
    ctx.canvas.height = window.innerHeight;
    ctx.setTransform(1, 0, 0, 1, window.innerWidth / 2, window.innerHeight / 2);
    return ctx;
  };

  time = function() {
    return (new Date).getTime();
  };

  keyboardHandler = {
    87: 'up',
    65: 'left',
    83: 'down',
    68: 'right'
  };

  game = null;

  myPlaneId = null;

  now.updateBullet = function(bullet) {
    return console.log(bullet);
  };

  now.updatePlane = function(plane) {
    return game.world.updatePlane(plane);
  };

  now.notifyMyPlane = function(planeId) {
    myPlaneId = planeId;
    return console.log("i am plane", myPlaneId);
  };

  pingTime = 100;

  now.pong = function(t) {
    return pingTime = pingTime * 0.5 + (time() - t) / 2 * 0.5;
  };

  Entity = (function() {

    function Entity(id) {
      this.id = id;
    }

    return Entity;

  })();

  Bullet = (function() {

    __extends(Bullet, Entity);

    function Bullet(id) {
      this.id = id;
    }

    return Bullet;

  })();

  Plane = (function() {

    __extends(Plane, Entity);

    function Plane(meta) {
      this.id = meta.id;
      this.x = meta.x;
      this.y = meta.y;
      this.vx = meta.vx;
      this.vy = meta.vy;
      this.ax = meta.ax;
      this.ay = meta.ay;
      this.dir = meta.dir;
      this.targetX = meta.targetx;
      this.targetY = meta.targety;
    }

    Plane.prototype.isMe = function() {
      return this.id === myPlaneId;
    };

    Plane.prototype.update = function(delta) {
      var ANGULAR_SPEED, angleDiff, vsize;
      if (delta == null) delta = 1.0 / 60;
      this.vx += this.ax * delta;
      this.vy += this.ay * delta;
      vsize = Math.sqrt(this.vx * this.vx + this.vy * this.vy);
      if (vsize > MAX_SPEED) {
        this.vx = this.vx * MAX_SPEED / vsize;
        this.vy = this.vy * MAX_SPEED / vsize;
      }
      this.x += this.vx * delta;
      this.y += this.vy * delta;
      this.vx *= 0.8;
      this.vy *= 0.8;
      if (this.targetX === this.x && this.targetY === this.y) {
        this.targetDir = this.dir;
      } else {
        this.targetDir = Math.atan2(this.targetY - this.y, this.targetX - this.x);
      }
      if (this.targetDir !== this.dir) {
        ANGULAR_SPEED = 5 * PI / 180;
        angleDiff = this.targetDir - this.dir;
        while (angleDiff < 0) {
          angleDiff += 2 * PI;
        }
        while (angleDiff >= 2 * PI) {
          angleDiff -= 2 * PI;
        }
        if (angleDiff < PI) {
          if (angleDiff < ANGULAR_SPEED) {
            return this.dir = this.targetDir;
          } else {
            return this.dir += ANGULAR_SPEED;
          }
        } else {
          if (angleDiff > 2 * PI - ANGULAR_SPEED) {
            return this.dir = this.targetDir;
          } else {
            return this.dir -= ANGULAR_SPEED;
          }
        }
      }
    };

    Plane.prototype.render = function(ctx) {
      var LONG_RADIUS, SHORT_RADIUS;
      ctx.beginPath();
      LONG_RADIUS = 15;
      SHORT_RADIUS = 5;
      ctx.moveTo(this.x + Math.cos(this.dir) * LONG_RADIUS, this.y + Math.sin(this.dir) * LONG_RADIUS);
      ctx.lineTo(this.x + Math.cos(this.dir + PI * 2 / 3) * SHORT_RADIUS, this.y + Math.sin(this.dir + PI * 2 / 3) * SHORT_RADIUS);
      ctx.lineTo(this.x + Math.cos(this.dir - PI * 2 / 3) * SHORT_RADIUS, this.y + Math.sin(this.dir - PI * 2 / 3) * SHORT_RADIUS);
      ctx.lineTo(this.x + Math.cos(this.dir) * LONG_RADIUS, this.y + Math.sin(this.dir) * LONG_RADIUS);
      ctx.closePath();
      ctx.stroke();
      return ctx.fill();
    };

    return Plane;

  })();

  Player = (function() {

    __extends(Player, Plane);

    function Player(meta) {
      Player.__super__.constructor.call(this, meta);
      this.directions = {};
    }

    Player.prototype.look = function(x, y) {
      this.targetX = x;
      return this.targetY = y;
    };

    Player.prototype.accelerate = function(direction, onoff) {
      var dir, dsize, dx, dy, onoffState, _ref;
      if (onoff) {
        this.directions[direction] = 1;
      } else {
        this.directions[direction] = 0;
      }
      dx = 0;
      dy = 0;
      _ref = this.directions;
      for (dir in _ref) {
        onoffState = _ref[dir];
        if (onoffState) {
          if (dir === 'left') {
            dx -= 1;
          } else if (dir === 'right') {
            dx += 1;
          } else if (dir === 'up') {
            dy -= 1;
          } else if (dir === 'down') {
            dy += 1;
          }
        }
      }
      dsize = Math.sqrt(dx * dx + dy * dy);
      if (dsize > 0) {
        this.ax = dx / dsize * 600;
        return this.ay = dy / dsize * 600;
      } else {
        this.ax = 0;
        return this.ay = 0;
      }
    };

    Player.prototype.update = function(delta) {
      if (delta == null) delta = 1.0 / 60;
      return Player.__super__.update.call(this, delta);
    };

    return Player;

  })();

  World = (function() {

    function World() {
      this.planes = {};
      this.bullets = {};
    }

    World.prototype.update = function() {
      var id, plane, _ref, _results;
      _ref = this.planes;
      _results = [];
      for (id in _ref) {
        plane = _ref[id];
        _results.push(plane.update());
      }
      return _results;
    };

    World.prototype.render = function(ctx) {
      var id, plane, _ref, _results;
      _ref = this.planes;
      _results = [];
      for (id in _ref) {
        plane = _ref[id];
        _results.push(plane.render(ctx));
      }
      return _results;
    };

    World.prototype.updatePlane = function(plane) {
      var newPlane;
      if (plane.id in this.planes) {} else {
        if (plane.id === myPlaneId) {
          newPlane = new Player(plane);
        } else {
          newPlane = new Plane(plane);
        }
        this.planes[newPlane.id] = newPlane;
      }
      return console.log("updatePlane", newPlane);
    };

    World.prototype.getMyPlane = function() {
      return this.planes[myPlaneId];
    };

    return World;

  })();

  Game = (function() {

    function Game(fps) {
      if (fps == null) fps = 60;
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

    Game.prototype.look = function(x, y) {
      x -= this.ctx.canvas.width / 2;
      y -= this.ctx.canvas.height / 2;
      return this.world.getMyPlane().look(x, y);
    };

    Game.prototype.processCommand = function(dir, onoff) {
      return this.world.getMyPlane().accelerate(dir, onoff);
    };

    Game.prototype.render = function() {
      var testrender;
      this.ctx = getContext();
      testrender = function(ctx) {
        var h, w;
        w = ctx.canvas.width;
        h = ctx.canvas.height;
        ctx.beginPath();
        ctx.arc(Math.random() * w, Math.random() * h, Math.random() * 50 + 50, 0, 2 * 3.141592);
        ctx.closePath();
        return ctx.stroke();
      };
      this.world.render(this.ctx);
      return this.updateFps();
    };

    Game.prototype.updateFps = function() {
      var currentTime, idx;
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

  getMyPlane = function() {
    return game.world.getMyPlane();
  };

  if (window.webkitRequestAnimationFrame) {
    onEachFrame = function(cb) {
      var _cb;
      var _this = this;
      _cb = function() {
        cb();
        return window.webkitRequestAnimationFrame(_cb);
      };
      return _cb();
    };
  } else if (window.mozRequestAnimationFrame) {
    onEachFrame = function(cb) {
      var _cb;
      var _this = this;
      _cb = function() {
        cb();
        return window.mozRequestAnimationFrame(_cb);
      };
      return _cb();
    };
  } else if (window.requestAnimationFrame) {
    onEachFrame = function(cb) {
      var _cb;
      var _this = this;
      _cb = function() {
        cb();
        return window.requestAnimationFrame(_cb);
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
      var x;
      $(document).keydown(function(e) {
        if (keyboardHandler[e.which] != null) {
          return game.processCommand(keyboardHandler[e.which], true);
        }
      });
      $(document).keyup(function(e) {
        if (keyboardHandler[e.which] != null) {
          return game.processCommand(keyboardHandler[e.which], false);
        }
      });
      $(document).mousemove(function(e) {
        var x, y;
        x = e.pageX;
        y = e.pageY;
        return game.look(x, y);
      });
      game = new Game();
      game.start();
      for (x = 0; x <= 5; x++) {
        now.ping(time());
      }
      return setInterval((function() {
        return now.ping(time());
      }), 5000);
    });
  });

}).call(this);
