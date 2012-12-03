plane = require('./plane')
class World
	constructor: ->
	createPlane: (id)->
		newPlane = new plane.Plane(id)
		newPlane

module.exports =
	World: World
