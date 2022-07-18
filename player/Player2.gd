extends KinematicBody

# Emits process(delta) signal and input(event) signal.
# The process one emits every _process() call, 
# and the input(event) one maps directly to _input.
# You get the idea.


signal process(delta)
signal input(event)


# So look at the export we got here.
# Basically, in the editor there are Script Properties
# in the `Inspector` portion of your Godot editor. See?
# You're gonna have to go into 3D mode and add plugins 
# in order for anything at all to happen. 

# The shape of the stuff you put in is a list of scripts.
# Godot will help you find only .gd scripts, so that's cool.
# It's a little wierd adding more values.
# You have to increase the length of the array, and only then
# can you click on the new item and load a script. 
# It's really not that bad once you get used to it.
export(Array, GDScript) var plugin_scripts

# Now take a look at `setup_plugin()`

const plugins = []

func _ready():
	for script in plugin_scripts:
		setup_plugin(script)

# Okay so here's the magic.
# It's simple, we call the script- this is outside the scene_tree(), which is
# a good thing, but now we have to pass it the player
# so that it has a reference back. 
# All plugins MUST have a set_player method, 
# the set_player method takes the player node as an argument.
# We save a list of the plugins for who knows why, idk.
func setup_plugin(script:GDScript):
	var plugin = script.new()
	plugin.set_player(self)
	plugins.append(plugin)

func _input(event):
	emit_signal("input", event)

func _process(delta):
	emit_signal("process", delta)
