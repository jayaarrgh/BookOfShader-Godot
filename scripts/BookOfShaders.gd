extends Control

# TODO: in 3d mode show more options
	# Switch target mesh to sphere, suzanne, teapot, etc, and swap the material shader
# TODO: only swap 3d shader code when changes have been made
# TODO: Allow applying texture to shader uniform

const RES_SHADER_DIR_2D  : String = "res://shaders"
const USER_SHADER_DIR_2D : String = "user://shaders"
const SHADER_TEMPLATE_2D : String = "shader_type canvas_item;\n\nvoid fragment(){\n\tCOLOR = vec4(vec3(0.0,0.5,0.3), 1.);\n}"
const RES_SHADER_DIR_3D  : String = "res://shaders/3D/"
const USER_SHADER_DIR_3D : String = "user://shaders/3D/"
const SHADER_TEMPLATE_3D : String = "shader_type spatial;\nrender_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;\n//TODO: Accept a texture in our editor\n//uniform sampler2D texture_albedo : source_color;\n\nvarying smooth vec3 our_color;\n//varying flat vec3 our_color;\n\nvoid vertex() {\n	our_color = VERTEX;\n}\n\n\nvoid fragment() {\n	ALBEDO = our_color.rgb;\n}\n"
const UPDATE_SHADER_2D   : float = 0.2 # update shader every 200ms
const SAVE_SHADER_2D     : float = 2.0 # save every 2 seconds
# update in 3d is a bit slower at Godot stutters when loading 3d shaders 
const UPDATE_SHADER_3D   : float = 1.0 # update shader every 1s
const SAVE_SHADER_3D     : float = 4.0 # save every 4s


@onready var codeEdit  : CodeEdit  = $CodeEdit
@onready var colorRect : ColorRect = $ColorRect
@onready var rectMat   : Material  = colorRect.material
@onready var main3d    : Node3D   = $"../3D"
@onready var meshMat   : Material  = $"../3D/MeshInstance3D".get_surface_override_material(0)
@onready var dimension : Button    = $"HBoxContainer/2D3D"


# STATE
var target # either a mesh or color rect depending on mode
var mode2d = true
var res_shader_dir = RES_SHADER_DIR_2D
var user_shader_dir = USER_SHADER_DIR_2D
var shader_template = SHADER_TEMPLATE_2D
var current_shader_path
var update_shader
var save_shader
var update_delta = 0.0
var save_delta = 0.0


func _ready():
	dimension.text = "3D"
	target = rectMat
	# res is not editable outside of editor - move res shaders to user directory
	Util.copy_recursive(res_shader_dir, user_shader_dir)
	# set the current shader path to the new or existing user path now
	current_shader_path = target.shader.get_path().replace('res://', 'user://')
	target.shader = load(current_shader_path)
	codeEdit.text = target.shader.code
	update_shader = UPDATE_SHADER_2D
	save_shader = SAVE_SHADER_2D
	shader_template = SHADER_TEMPLATE_2D
	# pop up FileDialog on start, use user dir
	$FileDialog.current_dir = user_shader_dir
	$FileDialog.current_path = user_shader_dir
	$NewShaderDialog.current_dir = user_shader_dir
	$NewShaderDialog.current_path = user_shader_dir
	$FileDialog.popup()


func _input(event):
	if !mode2d: return
	if event is InputEventMouseMotion:
		# send mouse movement to the shader - even if the shader doesn't have the param
		target.set_shader_parameter('mouse_position', get_local_mouse_position())


func _process(delta):
	update_delta += delta
	save_delta += delta
	if update_delta > update_shader:
		update_delta = float()
		_copy_editor_shader_code()
	if save_delta > save_shader:
		save_delta = float()
		_save_shader()


func _copy_editor_shader_code():
	if codeEdit.text == "": return
	target.shader.set_code(codeEdit.text)


func _save_shader():
	# TODO: ? allow user to choose whether autosave happens?
	var shader_to_save = target.shader
	var _e = ResourceSaver.save(shader_to_save, current_shader_path)
	if _e != OK:
		print('something went wrong when trying to save shader')


## GUI CALLBACKS
func _on_NewShader_pressed():
	$NewShaderDialog.popup()


func _on_SwitchShader_pressed():
	$FileDialog.popup()


func _on_CodeToggle_toggled(_button_pressed):
	if codeEdit.is_visible_in_tree(): codeEdit.hide()
	else: codeEdit.show()


func _on_Reset_pressed():
	# overwrite user data with res version
	var resource_version = current_shader_path.replace('user://', 'res://')
	var resource_shader = load(resource_version)
	if not resource_shader:
		print('Could not find original resource shader')
		return
	codeEdit.text = resource_shader.code
	target.shader.set_code(resource_shader.code)
	_save_shader()


func _on_NewShaderDialog_file_selected(path):
	# create new shader
	if not path.ends_with('.gdshader'): return
	current_shader_path = path
	var new_shader = Shader.new()
	new_shader.code = shader_template
	codeEdit.text = shader_template
	target.set_shader(new_shader)
	_save_shader()


func _on_FileDialog_file_selected(path):
	# load the selected shader
	current_shader_path = path
	var shader = load(current_shader_path)
	if not shader:
		print('could not load resource')
		return
	if not shader is Shader:
		print('that wasnt a shader')
		return
	codeEdit.text = shader.code
	target.set_shader(shader)


func _on_2D3D_button_up():
	self.set_process(false)
	mode2d = !mode2d
	if mode2d:
		dimension.text = "3D"
		target = rectMat
		shader_template = SHADER_TEMPLATE_2D
		update_shader = UPDATE_SHADER_2D
		save_shader = SAVE_SHADER_2D
		user_shader_dir = USER_SHADER_DIR_2D
		colorRect.show()
		main3d.hide()
	else:
		dimension.text = "2D"
		target = meshMat
		shader_template = SHADER_TEMPLATE_3D
		update_shader = UPDATE_SHADER_3D
		save_shader = SAVE_SHADER_3D
		user_shader_dir = USER_SHADER_DIR_3D
		main3d.show()
		colorRect.hide()
	
	update_delta = 0.0
	save_delta = 0.0
	$FileDialog.current_dir = user_shader_dir
	$FileDialog.current_path = user_shader_dir
	$NewShaderDialog.current_dir = user_shader_dir
	$NewShaderDialog.current_path = user_shader_dir
	current_shader_path = target.shader.get_path().replace('res://', 'user://')
	codeEdit.text = target.shader.code
	self.set_process(true)
