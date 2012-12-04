(function() {
  var BASE_RADIUS, Bullet, Entity, Game, MAX_SPEED, PI, Plane, Player, World, flipCanvas, game, getContext, keyboardHandler, myName, myPlaneId, onEachFrame, time;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  PI = Math.PI;

  BASE_RADIUS = 300;

  MAX_SPEED = 50;

  getContext = function() {
    var ctx;
    ctx = $('#maincanvas')[0].getContext('2d');
    ctx.canvas.width = window.innerWidth;
    ctx.canvas.height = window.innerHeight;
    ctx.setTransform(1, 0, 0, 1, window.innerWidth / 2, window.innerHeight / 2);
    return ctx;
  };

  flipCanvas = function() {
    var h, mainctx, viewctx, w;
    return;
    mainctx = $('#maincanvas')[0].getContext('2d');
    viewctx = $('#viewcanvas')[0].getContext('2d');
    w = viewctx.canvas.width = window.innerWidth;
    h = viewctx.canvas.height = window.innerHeight;
    return viewctx.drawImage(mainctx.canvas, 0, 0);
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

  now.youDead = function() {
    return game.die();
  };

  now.updateBullet = function(bullet) {
    return game.world.updateBullet(bullet);
  };

  now.deleteBullet = function(id) {
    return game.world.deleteBullet(id);
  };

  now.updatePlaneCount = function(planeCount) {
    return game.world.updatePlaneCount(planeCount);
  };

  now.updatePlane = function(plane) {
    return game.world.updatePlane(plane);
  };

  now.deletePlane = function(id) {
    return game.world.deletePlane(id);
  };

  now.notifyMyPlane = function(planeId) {
    myPlaneId = planeId;
    return console.log("i am plane", myPlaneId);
  };

  now.pingTime = 100;

  now.pong = function(t) {
    return now.pingTime = now.pingTime * 0.5 + (time() - t) / 2 * 0.5;
  };

  Entity = (function() {

    function Entity(meta) {}

    return Entity;

  })();

  Bullet = (function() {

    __extends(Bullet, Entity);

    function Bullet(meta) {
      this.id = meta.id;
      this.x = meta.x;
      this.y = meta.y;
      this.vx = meta.vx;
      this.vy = meta.vy;
      this.ax = meta.ax;
      this.ay = meta.ay;
      this.r = meta.r;
    }

    Bullet.prototype.update = function(delta) {
      if (delta == null) delta = 1 / 60;
      this.vx += this.ax * delta;
      this.vy += this.ay * delta;
      this.x += this.vx * delta;
      return this.y += this.vy * delta;
    };

    Bullet.prototype.render = function(ctx) {
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, 2 * Math.PI);
      ctx.closePath();
      ctx.stroke();
      return ctx.fill();
    };

    return Bullet;

  })();

  Plane = (function() {

    __extends(Plane, Entity);

    function Plane(meta) {
      var _ref;
      this.id = meta.id;
      this.x = meta.x;
      this.y = meta.y;
      this.vx = meta.vx;
      this.vy = meta.vy;
      this.ax = meta.ax;
      this.ay = meta.ay;
      this.dir = meta.dir;
      this.targetX = meta.targetX;
      this.targetY = meta.targetY;
      this.firing = meta.firing;
      this.dead = meta.dead;
      this.deadCount = meta.deadCount;
      this.playTime = meta.playTime;
      if ((_ref = this.playTime) == null) this.playTime = 0;
      this.exciting = meta.exciting;
      this.maxExciting = meta.maxExciting;
      this.name = meta.name;
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
        ANGULAR_SPEED = 10 * PI / 180;
        angleDiff = this.targetDir - this.dir;
        while (angleDiff < -PI) {
          angleDiff += 2 * PI;
        }
        while (angleDiff >= +PI) {
          angleDiff -= 2 * PI;
        }
        if (angleDiff >= 0) {
          if (angleDiff < ANGULAR_SPEED) {
            return this.dir = this.targetDir;
          } else {
            return this.dir += ANGULAR_SPEED;
          }
        } else {
          if (angleDiff > -ANGULAR_SPEED) {
            return this.dir = this.targetDir;
          } else {
            return this.dir -= ANGULAR_SPEED;
          }
        }
      }
    };

    Plane.prototype.render = function(ctx) {
      var LONG_RADIUS, SHORT_RADIUS, cv, t, x, _i, _len, _ref;
      if (this.dead) ctx.globalAlpha = 0.3;
      ctx.beginPath();
      LONG_RADIUS = 13;
      SHORT_RADIUS = 5;
      ctx.fillStyle = '#ffffff';
      ctx.arc(this.x, this.y, 2, 0, 2 * PI);
      ctx.fill();
      ctx.fillStyle = '#000000';
      ctx.moveTo(this.x + Math.cos(this.dir) * LONG_RADIUS, this.y + Math.sin(this.dir) * LONG_RADIUS);
      ctx.lineTo(this.x + Math.cos(this.dir + PI * 2 / 3) * SHORT_RADIUS, this.y + Math.sin(this.dir + PI * 2 / 3) * SHORT_RADIUS);
      ctx.lineTo(this.x + Math.cos(this.dir - PI * 2 / 3) * SHORT_RADIUS, this.y + Math.sin(this.dir - PI * 2 / 3) * SHORT_RADIUS);
      ctx.lineTo(this.x + Math.cos(this.dir) * LONG_RADIUS, this.y + Math.sin(this.dir) * LONG_RADIUS);
      ctx.closePath();
      ctx.stroke();
      if (this.isMe()) ctx.fillStyle = '#16f';
      ctx.fill();
      ctx.fillStyle = '#000000';
      t = time() / 10 % 30;
      if (time() - this.lookOverTime < 1000 && (this.name != null)) {
        ctx.textAlign = 'center';
        ctx.font = '12px helvetica';
        ctx.fillText(this.name, this.x, this.y + 20);
      }
      if (this.firing && !this.dead) {
        _ref = [0, 30, 60, 90];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          if (x === 90) {
            cv = Math.floor(t * 255 / 30);
            ctx.strokeStyle = "rgb(" + cv + "," + cv + "," + cv + ")";
          }
          ctx.beginPath();
          ctx.arc(this.x, this.y, x + t, this.dir - PI / 6, this.dir + PI / 6);
          ctx.stroke();
        }
      }
      ctx.strokeStyle = '#000000';
      ctx.fillStyle = '#000000';
      ctx.globalAlpha = 1.0;
      if (this.dead && this.isMe()) {
        ctx.textAlign = 'center';
        ctx.font = '20px helvetica';
        return ctx.fillText("You died " + this.deadCount + " time(s).", 0, 0);
      }
    };

    return Plane;

  })();

  Player = (function() {

    __extends(Player, Plane);

    function Player(meta) {
      Player.__super__.constructor.call(this, meta);
      this.directions = {};
    }

    Player.prototype.startFiring = function() {
      now.startFiring(this.dir);
      return this.firing = true;
    };

    Player.prototype.endFiring = function() {
      now.endFiring(this.dir);
      return this.firing = false;
    };

    Player.prototype.die = function() {
      return console.log('ARGH!!!! I died!!!', this.deadCount);
    };

    Player.prototype.look = function(x, y) {
      this.targetX = x;
      this.targetY = y;
      if (now.syncTarget != null) {
        if (this.lastLook != null) {
          if (time() - this.lastLook < 150 || this.firing && time() - this.lastLook < 100) {
            return;
          }
        }
        this.lastLook = time();
        return now.syncTarget(x, y, this.dir);
      }
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
        this.ay = dy / dsize * 600;
      } else {
        this.ax = 0;
        this.ay = 0;
      }
      if (now.syncPosition != null) {
        now.syncPosition(this.x, this.y, this.vx, this.vy, this.ax, this.ay);
      }
      if (this.lastdx !== dx || this.lastdy !== dy) {
        console.log(dx, dy);
        this.lastdx = dx;
        return this.lastdy = dy;
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
      var bullet, d, id, plane, w, x, y, _ref, _ref2, _results;
      _ref = this.planes;
      for (id in _ref) {
        plane = _ref[id];
        plane.update();
        x = plane.x;
        y = plane.y;
        w = this.computeWorldSize();
        if (x * x + y * y > w * w) {
          d = Math.sqrt(x * x + y * y);
          plane.x *= w / d;
          plane.y *= w / d;
        }
      }
      _ref2 = this.bullets;
      _results = [];
      for (id in _ref2) {
        bullet = _ref2[id];
        _results.push(bullet.update());
      }
      return _results;
    };

    World.prototype.computeWorldSize = function() {
      return Math.sqrt(1 + 0.1 * this.planeCount) * BASE_RADIUS;
    };

    World.prototype.renderBackground = function(ctx) {
      var h, targetRadius, w;
      if (!(this.planeCount != null)) return;
      if (!(this.lastRenderedBackgroundSize != null)) {
        this.lastRenderedBackgroundSize = this.computeWorldSize();
      }
      w = ctx.canvas.width;
      h = ctx.canvas.height;
      ctx.globalCompositeOperation = 'source-over';
      ctx.fillStyle = "#ffefc0";
      ctx.fillRect(-w / 2, -h / 2, w, h);
      ctx.globalCompositeOperation = 'destination-out';
      ctx.beginPath();
      targetRadius = this.computeWorldSize();
      if (Math.abs(targetRadius - this.lastRenderedBackgroundSize) < 10) {
        this.lastRenderedBackgroundSize = targetRadius;
      }
      if (this.lastRenderedBackgroundSize < targetRadius) {
        this.lastRenderedBackgroundSize += 10;
      } else if (this.lastRenderedBackgroundSize > targetRadius) {
        this.lastRenderedBackgroundSize -= 10;
      }
      ctx.arc(0, 0, this.lastRenderedBackgroundSize, 0, 2 * Math.PI);
      ctx.closePath();
      ctx.stroke();
      ctx.fill();
      ctx.globalCompositeOperation = 'destination-over';
      return ctx.fillStyle = "#000000";
    };

    World.prototype.render = function(ctx) {
      var bullet, id, plane, _ref, _ref2, _results;
      this.renderBackground(ctx);
      _ref = this.planes;
      for (id in _ref) {
        plane = _ref[id];
        plane.render(ctx);
      }
      _ref2 = this.bullets;
      _results = [];
      for (id in _ref2) {
        bullet = _ref2[id];
        _results.push(bullet.render(ctx));
      }
      return _results;
    };

    World.prototype.deleteBullet = function(id) {
      return delete this.bullets[id];
    };

    World.prototype.updateBullet = function(bullet) {
      var newBullet, old;
      newBullet = new Bullet(bullet);
      old = this.bullets[newBullet.id];
      return this.bullets[newBullet.id] = newBullet;
    };

    World.prototype.deletePlane = function(id) {
      return delete this.planes[id];
    };

    World.prototype.updatePlaneCount = function(planeCount) {
      this.planeCount = planeCount;
    };

    World.prototype.updatePlane = function(plane) {
      var newPlane;
      if (plane.id in this.planes) {
        if (plane.id !== myPlaneId && plane.id in this.planes) {
          return this.planes[plane.id] = new Plane(plane);
        } else {
          this.planes[plane.id].dead = plane.dead;
          this.planes[plane.id].deadCount = plane.deadCount;
          this.planes[plane.id].playTime = plane.playTime;
          this.planes[plane.id].exciting = plane.exciting;
          return this.planes[plane.id].maxExciting = plane.maxExciting;
        }
      } else {
        if (plane.id === myPlaneId) {
          newPlane = new Player(plane);
        } else {
          newPlane = new Plane(plane);
        }
        return this.planes[newPlane.id] = newPlane;
      }
    };

    World.prototype.getMyPlane = function() {
      if (myPlaneId != null) return this.planes[myPlaneId];
      return null;
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
      var i, idx, p, plane, s, v, _ref, _ref2;
      this.world.update();
      v = [];
      _ref = this.world.planes;
      for (idx in _ref) {
        plane = _ref[idx];
        if (!(plane.playTime != null)) continue;
        v.push([(plane.playTime - plane.deadCount * 5000) / (plane.deadCount + 1), plane.id]);
      }
      v.sort(function(l, r) {
        return -l[0] + r[0];
      });
      p = this.world.getMyPlane();
      if (!(p != null)) return;
      s = '';
      s += 'WSAD to move, Click to push bullets<br>';
      s += 'I am Plane ' + p.id + '<br>Rank by avg play time per life<br>';
      i = 0;
      while (i < 10 && i < v.length) {
        if (v[i][1] === myPlaneId) s += '<span style="color:#19f">';
        p = this.world.planes[v[i][1]];
        if (p.name != null) {
          s += p.name;
        } else {
          s += 'Plane ' + v[i][1];
        }
        s += ' : ';
        s += (v[i][0] / 1000).toFixed(1);
        s += ' / ' + this.world.planes[v[i][1]].deadCount + '<br>';
        if (v[i][1] === myPlaneId) s += '</span>';
        i += 1;
      }
      s += '<br>Rank by exciting(비비기,절묘도)<br>score : max (current)<br>';
      v = [];
      _ref2 = this.world.planes;
      for (idx in _ref2) {
        plane = _ref2[idx];
        if (!(plane.exciting != null)) continue;
        v.push([plane.maxExciting, plane.id]);
      }
      v.sort(function(l, r) {
        return -l[0] + r[0];
      });
      i = 0;
      while (i < 10 && i < v.length) {
        if (v[i][1] === myPlaneId) s += '<span style="color:#19f">';
        p = this.world.planes[v[i][1]];
        if (p.name != null) {
          s += p.name;
        } else {
          s += 'Plane ' + v[i][1];
        }
        s += ' : ';
        s += p.maxExciting.toFixed(3);
        s += ' (' + p.exciting.toFixed(3) + ')<br>';
        if (v[i][1] === myPlaneId) s += '</span>';
        i += 1;
      }
      return $('#rankStat').html(s);
    };

    Game.prototype.die = function() {
      return this.world.getMyPlane().die();
    };

    Game.prototype.look = function(x, y) {
      var dx, dy, idx, plane, _ref, _results;
      if (!(this.ctx != null)) return;
      x -= this.ctx.canvas.width / 2;
      y -= this.ctx.canvas.height / 2;
      if (this.world.getMyPlane() != null) this.world.getMyPlane().look(x, y);
      _ref = this.world.planes;
      _results = [];
      for (idx in _ref) {
        plane = _ref[idx];
        dx = plane.x - x;
        dy = plane.y - y;
        if (dx * dx + dy * dy < 50 * 50) {
          _results.push(plane.lookOverTime = time());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Game.prototype.startFiring = function() {
      if (this.world.getMyPlane() != null) {
        return this.world.getMyPlane().startFiring();
      }
    };

    Game.prototype.endFiring = function() {
      if (this.world.getMyPlane() != null) {
        return this.world.getMyPlane().endFiring();
      }
    };

    Game.prototype.processCommand = function(dir, onoff) {
      if (this.world.getMyPlane() != null) {
        return this.world.getMyPlane().accelerate(dir, onoff);
      }
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
      if (updateProcessed) {
        this.render();
        return flipCanvas();
      }
    };

    return Game;

  })();

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

  myName = prompt('what is your name');

  now.ready(function() {
    now.name = myName;
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
      $('#rankStat').keydown(function(e) {
        if (keyboardHandler[e.which] != null) {
          return game.processCommand(keyboardHandler[e.which], true);
        }
      });
      $('#rankStat').keyup(function(e) {
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
      $(document).mousedown(function(e) {
        return game.startFiring();
      });
      $(document).mouseup(function(e) {
        return game.endFiring();
      });
      game = new Game();
      game.start();
      for (x = 0; x <= 5; x++) {
        now.ping(time());
      }
      setInterval((function() {
        if (now.ping != null) return now.ping(time());
      }), 5000);
      return setInterval((function() {
        var p;
        p = game.world.getMyPlane();
        if (p != null) {
          if (now.syncPosition != null) {
            return now.syncPosition(p.x, p.y, p.vx, p.vy, p.ax, p.ay);
          }
        }
      }), 500);
    });
  });

}).call(this);
