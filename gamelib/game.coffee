world = require('./world')

planeId = 1

class Game
	constructor: (@now)->
		@world = new world.World

		@now.ping = (t) ->
			@now.pong(t)

	newConnection: (user)->
		newPlane = @world.createPlane planeId
		planeId = newPlane.id
		user.user.id = planeId
		user.now.notifyMyPlane planeId
		@now.updatePlane newPlane

module.exports = (now) ->
	new Game(now)
