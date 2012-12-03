class Plane
	constructor: (@id, @x=0, @y=0, @vx=0, @vy=0, @ax=0, @ay=0, @dir=0, @targetX=0, @targetY=0) ->
	update: (@delta = 1.0/60)->
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta
		@vx *= 0.9
		@vy *= 0.9
	setClient: (@client) ->
module.exports =
	Plane: Plane
