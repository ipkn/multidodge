world = require('./world')

game = null

class Game
	constructor: (@now)->
		@world = new world.World(@now)
		setInterval (=> @world.update()), 1000/60

		@now.pingTime = 100
		@now.ping = (t) ->
			@now.pong(t)
		@now.helloServer = ->
			console.log 'new user',@user.clientId
			game.newConnection(this)

	newConnection: (client) ->
		newPlane = @world.createPlane(client)

	onDisconnect: (client) ->
		@world.onDisconnect client

module.exports = (now) ->
	game = new Game(now)
	game
