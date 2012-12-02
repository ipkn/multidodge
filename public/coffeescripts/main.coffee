getContext = ->
	ctx = $('#maincanvas')[0].getContext('2d')
	ctx.canvas.width = window.innerWidth
	ctx.canvas.height = window.innerHeight
	ctx

myPlaneId = null

now.updateBullet = (bullet) ->
	console.log bullet

now.updatePlane = (plane) ->
	if plane.id == myPlaneId
		new Player(plane)
	else
		new Plane(plane)

now.notifyMyPlane = (planeId) ->
	myPlaneId = planeId

time = ->
	return (new Date).getTime()

class Entity
	constructor: (@id) ->

#class Bullet extends Entity
	#constructor: (@id) ->
#class Plane extends Entity
	#constructor: (@id) ->
#class Player extends Plane
	#constructor: (@id) ->

class World
	update: ->

class Game
	constructor: (fps=60)->
		@ctx = getContext()
		@fps = fps
		@nextGameTick = time()
		@fpsData = []
		@skipTicks = 1000.0/fps
		@world = new World
		now.helloServer()

	update: ->
		@world.update()

	render: ->
		testrender = (ctx) ->
			w = ctx.canvas.width
			h = ctx.canvas.height
			ctx.beginPath()
			ctx.arc Math.random()*w, Math.random()*h, Math.random()*50+50,0,2*3.141592
			ctx.closePath()
			ctx.stroke()
		testrender(@ctx)
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

if window.webkitRequestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			webkitRequestAnimationFrame(_cb)
		_cb()
else if window.mozRequestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			mozRequestAnimationFrame(_cb)
		_cb()
else
	onEachFrame = (cb) ->
		setInterval cb, 1000/60

now.ready ->
	$(document).ready ->
		new Game().start()
