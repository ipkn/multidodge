class Plane
	constructor: (@id, @x=0, @y=0, @vx=0, @vy=0, @ax=0, @ay=0, @dir=0, @targetX=0, @targetY=0, @firing=false, @dead=false, @deadCount=0, @startTime = (new Date()).getTime()) ->

	computePlayTime: ->
		if not @dead
			@playTime = (new Date()).getTime() - @startTime

	die: (cb) ->
		@dead = true
		@deadCount++
		delayed = =>
			@revive()
			cb this
		setTimeout delayed, 5000

	revive: ->
		@dead = false

	update: (@delta = 1.0/60)->
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta
		@vx *= 0.9
		@vy *= 0.9

	distance: (another) ->
		dx = another.x - @x
		dy = another.y - @y
		return Math.sqrt(dx*dx+dy*dy)
	
	near: (another, d) ->
		dx = another.x - @x
		dy = another.y - @y
		(-d < dx < d) and (-d < dy < d) and dx*dx+dy*dy < d*d
		

	angularDiff: (another) ->
		dx = another.x - @x
		dy = another.y - @y
		return Math.atan2(dy, dx) - @dir

	setClient: (@client) ->

module.exports =
	Plane: Plane
