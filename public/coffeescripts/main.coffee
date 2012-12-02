getContext = ->
	ctx = $('#maincanvas')[0].getContext('2d')
	ctx.canvas.width = window.innerWidth
	ctx.canvas.height = window.innerHeight
	ctx

class Game
	constructor: ->
		@ctx = getContext()
	gameloop: ->
		ctx = @ctx
		w = ctx.canvas.width
		h = ctx.canvas.width
		ctx.beginPath()
		ctx.arc(Math.random()*w, Math.random()*h, Math.random()*50+50,0,2*3.141592)
		ctx.closePath()
		ctx.stroke()
	start: ->
		onEachFrame => @gameloop()

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

$(document).ready ->
	new Game().start()
