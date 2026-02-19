extends Node3D

var playerController
var fuelLevel = 0.0
var generatorFuelBar 


func fill_generator(player, canister):
	playerController = player
	generatorFuelBar = player.genGasLevel
	#Play the animation for the canister
	#Set the value of the generator gas level to max
	fuelLevel = 100.0
	#Show the player how much fuel is in the generator
	generatorFuelBar.value = 100.0
	#Set the canister fill to false
	canister.canisterFilled = false
	#Turn on the lights

func _process(delta):
	#Drain the gas from the generator
	if fuelLevel > 0.0:
		var percent = generatorFuelBar.value / generatorFuelBar.max_value
		generatorFuelBar.material.set_shader_parameter("value", percent)
		generatorFuelBar.value -= generatorFuelBar.step
	
