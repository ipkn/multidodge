PI = 3.1415926535
MAX_SPEED = 50
getContext = ->
	ctx = $('#maincanvas')[0].getContext('2d')
	ctx.canvas.width = window.innerWidth
	ctx.canvas.height = window.innerHeight
	ctx.setTransform(1,0,0,1,window.innerWidth/2, window.innerHeight/2)
	ctx

time = ->
	return (new Date).getTime()

keyboardHandler =
	87: 'up'
	65: 'left'
	83: 'down'
	68: 'right'

game = null
myPlaneId = null

now.updateBullet = (bullet) ->
	console.log bullet

now.updatePlane = (plane) ->
	game.world.updatePlane(plane)

now.notifyMyPlane = (planeId) ->
	myPlaneId = planeId
	console.log "i am plane", myPlaneId

pingTime = 100
now.pong = (t) ->
	pingTime = pingTime * 0.5 + (time()-t)/2*0.5
	
class Entity
	constructor: (@id) ->

class Bullet extends Entity
	constructor: (@id) ->
class Plane extends Entity
	constructor: (meta) ->
		@id = meta.id
		@x = meta.x
		@y = meta.y
		@vx = meta.vx
		@vy = meta.vy
		@ax = meta.ax
		@ay = meta.ay
		@dir = meta.dir
		@targetX = meta.targetx
		@targetY = meta.targety
	isMe: ->
		@id == myPlaneId
	update: (delta = 1.0/60)->
		# update position
		@vx += @ax*delta
		@vy += @ay*delta
		vsize = Math.sqrt (@vx*@vx + @vy*@vy)
		if vsize > MAX_SPEED
			@vx = @vx * MAX_SPEED / vsize
			@vy = @vy * MAX_SPEED / vsize
		@x += @vx*delta
		@y += @vy*delta
		@vx *= 0.8
		@vy *= 0.8

		# update direction
		if @targetX == @x and @targetY == @y
			@targetDir = @dir
		else
			@targetDir = Math.atan2 @targetY-@y, @targetX-@x
		if @targetDir != @dir
			ANGULAR_SPEED = 5 * PI / 180
			angleDiff = @targetDir - @dir
			angleDiff += 2*PI while angleDiff < 0
			angleDiff -= 2*PI while angleDiff >= 2*PI
			if angleDiff < PI
				if angleDiff < ANGULAR_SPEED
					@dir = @targetDir
				else
					@dir += ANGULAR_SPEED
			else
				if angleDiff > 2*PI-ANGULAR_SPEED
					@dir = @targetDir
				else
					@dir -= ANGULAR_SPEED

	render: (ctx) ->
		ctx.beginPath()
		LONG_RADIUS = 15
		SHORT_RADIUS = 5
		ctx.moveTo(@x + Math.cos(@dir)*LONG_RADIUS, @y + Math.sin(@dir)*LONG_RADIUS)
		ctx.lineTo(@x + Math.cos(@dir+PI*2/3)*SHORT_RADIUS, @y + Math.sin(@dir+PI*2/3)*SHORT_RADIUS)
		ctx.lineTo(@x + Math.cos(@dir-PI*2/3)*SHORT_RADIUS, @y + Math.sin(@dir-PI*2/3)*SHORT_RADIUS)
		ctx.lineTo(@x + Math.cos(@dir)*LONG_RADIUS, @y + Math.sin(@dir)*LONG_RADIUS)
		ctx.closePath()
		ctx.stroke()
		ctx.fill()


class Player extends Plane
	constructor: (meta) ->
		super meta
		@directions = {}
	look: (x,y) ->
		@targetX = x
		@targetY = y
	accelerate: (direction, onoff) ->
		if onoff
			@directions[direction] = 1
		else
			@directions[direction] = 0
		dx=0
		dy=0
		for dir, onoffState of @directions
			if onoffState
				if dir == 'left'
					dx -= 1
				else if dir == 'right'
					dx += 1
				else if dir == 'up'
					dy -= 1
				else if dir == 'down'
					dy += 1
		dsize = Math.sqrt (dx*dx+dy*dy)
		if dsize > 0
			@ax = dx / dsize*600
			@ay = dy / dsize*600
		else
			@ax = 0
			@ay = 0

	update: (delta = 1.0/60) ->
		super delta

class World
	constructor: ->
		@planes = {}
		@bullets = {}
	update: ->
		for id, plane of @planes
			plane.update()
	render: (ctx) ->
		for id, plane of @planes
			plane.render(ctx)
	updatePlane: (plane) ->
		if plane.id of @planes 
			# update plane data
		else
			# new plane appear
			if plane.id == myPlaneId
				newPlane = new Player(plane)
			else
				newPlane = new Plane(plane)
			@planes[newPlane.id] = newPlane
		console.log "updatePlane", newPlane
	getMyPlane: ->
		return @planes[myPlaneId]

class Game
	constructor: (fps=60)->
		@fps = fps
		@nextGameTick = time()
		@fpsData = []
		@skipTicks = 1000.0/fps
		@world = new World
		now.helloServer()

	update: ->
		@world.update()

	look: (x,y)->
		x -= @ctx.canvas.width / 2
		y -= @ctx.canvas.height / 2
		@world.getMyPlane().look x,y

	processCommand: (dir, onoff) ->
		@world.getMyPlane().accelerate dir, onoff

	render: ->
		@ctx = getContext()
		testrender = (ctx) ->
			w = ctx.canvas.width
			h = ctx.canvas.height
			ctx.beginPath()
			ctx.arc Math.random()*w, Math.random()*h, Math.random()*50+50,0,2*3.141592
			ctx.closePath()
			ctx.stroke()
		#testrender(@ctx)
		@world.render(@ctx)
		@updateFps()

	updateFps: ->
		currentTime = time()
		idx = 0
		while idx < @fpsData.length
			if @fpsData[idx] + 1000 < currentTime
				@fpsData[idx] = @fpsData[@fpsData.length-1]
				@fpsData.pop()
			else
				idx += 1

		@fpsData.push(currentTime)
		$("#fpsText").text(@fpsData.length)

	start: ->
		onEachFrame =>
			@gameloop()

	gameloop: ->
		updateProcessed = 0
		MAX_FRAME_SKIP = 10
		while time() > @nextGameTick and updateProcessed < MAX_FRAME_SKIP
			@update()
			updateProcessed += 1
			@nextGameTick += @skipTicks

		if updateProcessed
			@render()
		#else # for interpolation
		# @render (new Date()).getTime() - @nextGameTick

getMyPlane = ->
	game.world.getMyPlane()

if window.webkitRequestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			window.webkitRequestAnimationFrame(_cb)
		_cb()
else if window.mozRequestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			window.mozRequestAnimationFrame(_cb)
		_cb()
else if window.requestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			window.requestAnimationFrame(_cb)
		_cb()
else
	onEachFrame = (cb) ->
		setInterval cb, 1000/60

now.ready ->
	$(document).ready ->
		$(document).keydown (e) ->
			if keyboardHandler[e.which]?
				game.processCommand keyboardHandler[e.which], true
		$(document).keyup (e) ->
			if keyboardHandler[e.which]?
				game.processCommand keyboardHandler[e.which], false
		$(document).mousemove (e) ->
			x = e.pageX
			y = e.pageY
			game.look(x,y)
		game = new Game()
		game.start()
		# fast ping adaption
		for x in [0..5]
			now.ping time()
		setInterval (-> now.ping time()), 5000
