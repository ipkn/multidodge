class Bullet
	constructor: (@id, @x=0, @y=0, @vx=0, @vy=0, @ax=0, @ay=0) ->
	update: (delta = 1.0/60)->
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta
	isLive: (worldSize) ->
		@x*@x+@y*@y<=(worldSize+100)*(worldSize+100)

module.exports =
	Bullet: Bullet
