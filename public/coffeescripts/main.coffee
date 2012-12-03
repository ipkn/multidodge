PI = Math.PI
BASE_RADIUS = 300
MAX_SPEED = 50
BULLET_RADIUS = 5
getContext = ->
	ctx = $('#maincanvas')[0].getContext('2d')
	ctx.canvas.width = window.innerWidth
	ctx.canvas.height = window.innerHeight
	ctx.setTransform(1,0,0,1,window.innerWidth/2, window.innerHeight/2)
	ctx
flipCanvas = ->
	return
	#canvasIndex = 1-canvasIndex
	#mainctx = $('#maincanvas')[0].getContext('2d')
	#viewctx = $('#viewcanvas')[0].getContext('2d')
	#w = viewctx.canvas.width = window.innerWidth
	#h =viewctx.canvas.height = window.innerHeight
	#viewctx.clearRect 0,0,w,h
	#viewctx.drawImage mainctx.canvas,0,0

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
	game.world.updateBullet bullet

now.deleteBullet = (id) ->
	game.world.deleteBullet id

now.updatePlaneCount = (planeCount) ->
	game.world.updatePlaneCount planeCount

now.updatePlane = (plane) ->
	game.world.updatePlane(plane)

now.deletePlane = (id) ->
	game.world.deletePlane id

now.notifyMyPlane = (planeId) ->
	myPlaneId = planeId
	console.log "i am plane", myPlaneId

now.pingTime = 100
now.pong = (t) ->
	now.pingTime = now.pingTime * 0.5 + (time()-t)/2*0.5
	
class Entity
	constructor: (meta) ->

class Bullet extends Entity
	constructor: (meta) ->
		@id = meta.id
		@x = meta.x
		@y = meta.y
		@vx = meta.vx
		@vy = meta.vy
		@ax = meta.ax
		@ay = meta.ay

	update: (delta=1/60) ->
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta

	render: (ctx) ->
		ctx.beginPath()
		ctx.arc(@x,@y,BULLET_RADIUS,0,2*Math.PI)
		ctx.closePath()
		ctx.stroke()
		ctx.fill()
		
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
		@targetX = meta.targetX
		@targetY = meta.targetY
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
			ANGULAR_SPEED = 10 * PI / 180
			angleDiff = @targetDir - @dir
			angleDiff += 2*PI while angleDiff < -PI
			angleDiff -= 2*PI while angleDiff >= +PI
			if angleDiff >= 0
				if angleDiff < ANGULAR_SPEED
					@dir = @targetDir
				else
					@dir += ANGULAR_SPEED
			else
				if angleDiff > -ANGULAR_SPEED
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
		if now.syncTarget?
			if @lastLook?
				if time() - @lastLook < 300
					return
			@lastLook = time()
			now.syncTarget x, y, @dir
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
		now.syncPosition @x, @y, @vx, @vy, @ax, @ay

	update: (delta = 1.0/60) ->
		super delta


class World
	constructor: ->
		@planes = {}
		@bullets = {}
	update: ->
		for id, plane of @planes
			plane.update()
		for id, bullet of @bullets
			bullet.update()
	renderBackground: (ctx)->
		if not @planeCount?
			return
		if not @lastRenderedBackgroundSize?
			@lastRenderedBackgroundSize = Math.sqrt(@planeCount) * BASE_RADIUS
		w = ctx.canvas.width
		h = ctx.canvas.height
		ctx.globalCompositeOperation = 'source-over'
		ctx.fillStyle="#ff0000"
		ctx.fillRect -w/2, -h/2, w, h
		ctx.globalCompositeOperation = 'destination-out'
		ctx.beginPath()
		targetRadius = Math.sqrt(@planeCount) * BASE_RADIUS
		if Math.abs(targetRadius - @lastRenderedBackgroundSize) < 10
			@lastRenderedBackgroundSize = targetRadius
		if @lastRenderedBackgroundSize < targetRadius
			@lastRenderedBackgroundSize += 10
		else if @lastRenderedBackgroundSize > targetRadius
			@lastRenderedBackgroundSize -= 10
		ctx.arc(0,0,@lastRenderedBackgroundSize,0,2*Math.PI)
		#ctx.arc(0,0,600,0,2*Math.PI)
		ctx.closePath()
		ctx.stroke()
		ctx.fill()
		ctx.globalCompositeOperation = 'destination-over'
		ctx.fillStyle="#000000"
	render: (ctx) ->
		@renderBackground(ctx)

		for id, plane of @planes
			plane.render(ctx)

		for id, bullet of @bullets
			bullet.render(ctx)

	deleteBullet: (id) ->
		delete @bullets[id]

	updateBullet: (bullet) ->
		newBullet = new Bullet(bullet)
		@bullets[newBullet.id] = newBullet

	deletePlane: (id) ->
		delete @planes[id]

	updatePlaneCount: (@planeCount) ->
		
	updatePlane: (plane) ->
		console.log plane, time()
		if plane.id of @planes
			# update plane data
			if plane.id != myPlaneId and plane.id of @planes
				@planes[plane.id] = new Plane(plane)
				#@planes[newPlane.id].sync plane
		else
			# new plane appear
			if plane.id == myPlaneId
				newPlane = new Player(plane)
			else
				newPlane = new Plane(plane)
			@planes[newPlane.id] = newPlane
	getMyPlane: ->
		if myPlaneId?
			return @planes[myPlaneId]
		return null

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
		if @world.getMyPlane()?
			@world.getMyPlane().look x,y

	processCommand: (dir, onoff) ->
		if @world.getMyPlane()?
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
			flipCanvas()
		#else # for interpolation
		# @render (new Date()).getTime() - @nextGameTick


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
