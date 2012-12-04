class Space
	constructor: (@step = 50) ->
		@world = {}
	computeKey: (o) ->
		[Math.floor(o.x/@step), Math.floor(o.y/@step)]
	update: (o) ->
		[key1, key2] = @computeKey o
		if key1 == o.spaceKey[0] and key2 == o.spaceKey[1]
			return
		delete @world[o.spaceKey[0]][o.spaceKey[1]][o.id]
		o.spaceKey = [key1,key2]
		@world[key1] ?= {}
		@world[key1][key2] ?= {}
		@world[key1][key2][o.id] = o
	add: (o) ->
		o.spaceKey = [key1, key2] = @computeKey o
		@world[key1] ?= {}
		@world[key1][key2] ?= {}
		@world[key1][key2][o.id] = o
	remove: (o) ->
		[key1, key2] = @computeKey o
		delete @world[key1][key2][o.id]
	foreach: (x1, y1, x2, y2, f) ->
		x1 /= @step
		y1 /= @step
		x2 /= @step
		y2 /= @step
		x1 = Math.floor x1
		y1 = Math.floor y1
		x2 = Math.floor x2
		y2 = Math.floor y2
		x2+=1
		y2+=1
		for x in [x1...x2]
			for y in [y1...y2]
				if @world[x]? and @world[x][y]?
					for idx, o of @world[x][y]
						f o
		
	foreach2: (x, y, c, f) ->
		@foreach x-c,y-c,x+c,y+c,f
		
module.exports =
	Space: Space
