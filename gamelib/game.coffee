world = require('./world')

game = null

time = ->
	return (new Date).getTime()

class Game
	constructor: (@now)->
		@world = new world.World(@now)
		setInterval (=> @update()), 1000/60

		@now.pingTime = 100
		@now.ping = (t) ->
			@now.pong(t)
		@now.helloServer = ->
			game.newConnection(this)
		@nextGameTick = time()

	newConnection: (client) ->
		newPlane = @world.createPlane(client)

	onDisconnect: (client) ->
		@world.onDisconnect client
	
	update: ->
		updateProcessed = 0
		MAX_SKIP = 10
		@skipTicks = 1000.0/60
		while time() > @nextGameTick and updateProcessed < MAX_SKIP
			@world.update()
			updateProcessed += 1
			@nextGameTick += @skipTicks
		if @updateProcessed > 1
			console.log 'burst update', updateProcessed
		

module.exports = (now) ->
	game = new Game(now)
	game
