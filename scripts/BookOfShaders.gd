extends Control


const USER_SHADER_DIR_2D : String = "user://shaders"
const USER_SHADER_DIR_3D : String = "user://shaders/3D/"
const SHADER_TEMPLATE_2D : String = "shader_type canvas_item;\n\nuniform sampler2D texture;\nuniform vec2 mouse_position;\nvoid fragment(){\n\tCOLOR = vec4(vec3(0.0,0.5,0.3), 1.);\n}"
const SHADER_TEMPLATE_3D : String = "shader_type spatial;\nrender_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;\n\nuniform sampler2D texture;\nuniform vec2 mouse_position;\n\nvarying smooth vec3 our_color;\n//varying flat vec3 our_color;\n\nvoid vertex() {\n	our_color = VERTEX;\n}\n\nvoid fragment() {\n	vec3 base = texture(texture, UV).rgb;\n	ALBEDO = mix(base, our_color.rgb, 0.5);\n}\n\n"
const UPDATE_SHADER_2D_TIME   : float = 0.2
const SAVE_SHADER_2D_TIME     : float = 2.0
const UPDATE_SHADER_3D_TIME   : float = 1.0
const SAVE_SHADER_3D_TIME     : float = 2.0

#### SCENE DEPENDENCIES
onready var textEdit  : TextEdit     = $TextEdit
onready var colorRect : ColorRect    = $ColorRect
onready var rectMat   : Material     = colorRect.material
onready var main3d    : Spatial      = $"../3D"
onready var meshInst  : MeshInstance = $"../3D/MeshInstance"
onready var meshMat   : Material     = $"../3D/MeshInstance".get_surface_material(0)
onready var dimension : Button       = $"2D3D"
onready var logLbl    : Label        = $Log
onready var debugLbl  : Label        = $Debug
onready var stopTimer : Timer        = $StopLoadTimer

##### STATE
var mode2d = true
var target = rectMat # either a mesh or color rect mat depending on mode2d
var userShaderDir = USER_SHADER_DIR_2D
var shaderTemplate = SHADER_TEMPLATE_2D
var currentShaderPath = ""
var shouldUpdateShader = false
var updateShader = UPDATE_SHADER_2D_TIME
var saveShader = SAVE_SHADER_2D_TIME
var updateDelta = 0.0
var saveDelta = 0.0
var meshIndex = 0
var meshes = []
var lastLog = ""


func _ready():
	var _e = stopTimer.connect("timeout", self, '_on_stop_load_timer')
	dimension.text = "3D"
	# res is not editable outside of editor - move res shaders to user directory
	Util.copy_recursive("res://shaders", userShaderDir)
	# overwrite the 3d shader files as there are plans to add more in the future
	Util.copy_recursive("res://shaders/3D", userShaderDir+"/3D", true)
	Util.copy_recursive("res://mesh", "user://mesh")
	
	# Get everything from the user/mesh dir and load it into the meshes
	var mesh_files = Util.get_files("user://mesh")
	for mesh_file in mesh_files:
		meshes.append(load("user://mesh/"+mesh_file))
	
	# set the current shader path to the new or existing user path now
	currentShaderPath = target.shader.get_path().replace('res://', 'user://')
	target.shader = load(currentShaderPath)
	textEdit.text = target.shader.code
	# pop up FileDialog on start, use user dir
	$FileDialog.current_dir = userShaderDir
	$FileDialog.current_path = userShaderDir
	$NewShaderDialog.current_dir = userShaderDir
	$NewShaderDialog.current_path = userShaderDir
	$FileDialog.popup()
	main3d.hide()

func _input(event):
	if event is InputEventMouseMotion:
		target.set_shader_param('mouse_position', get_local_mouse_position())

func _process(delta):
	updateDelta += delta
	saveDelta += delta
	if updateDelta > updateShader:
		updateDelta = float()
		_copy_editor_shader_code()
	if saveDelta > saveShader:
		saveDelta = float()
		_saveShader()

func _saveShader():
	if !shouldUpdateShader: return
	var shader_to_save = target.shader
	var err = ResourceSaver.save(currentShaderPath, shader_to_save)
	if err != OK:
		debugLbl.text = 'ERROR: Failed to save shader'
		return

func _copy_editor_shader_code():
	if textEdit.text == "": return
	if !shouldUpdateShader: return
	target.shader.set_code(textEdit.text)
	_set_last_log()
	logLbl.text = lastLog
	if not "         " in lastLog:
		# this is a total hack to clear the error log
		# but showing the stdout/stderr in application is a total hack anyway
		print('                                                                                    ')

#### ERROR "display"
func _set_last_log():
	var file = File.new()
	file.open("user://logs/godot.log", File.READ)
	file.seek_end(-100)
	lastLog = ""
	lastLog += file.get_line()
	lastLog += file.get_line()
	file.close()
	if "         " in lastLog:
		var f = File.new()
		f.open("user://logs/godot.log", File.WRITE)
		f.store_string("         ")
		f.close()
		lastLog = ""

#### SHOULD UPDATE TIMEOUT
func _on_TextEdit_text_changed():
	shouldUpdateShader = true
	stopTimer.start()

func _on_stop_load_timer():
	_copy_editor_shader_code()
	_saveShader()
	shouldUpdateShader = false

#### GUI CALLBACKS
func _on_NewShader_pressed():
	$NewShaderDialog.popup()

func _on_SwitchShader_pressed():
	$FileDialog.popup()

func _on_ImportMesh_pressed():
	$MeshDialog.popup()

func _on_ImportImg_pressed():
	$ImgDialog.popup()

func _on_SwitchMesh_pressed():
	var sz = meshes.size()
	meshIndex += 1
	if meshIndex >= sz:
		meshIndex = 0
	meshInst.set_mesh(meshes[meshIndex])

func _on_CodeToggle_toggled(_button_pressed):
	if textEdit.is_visible_in_tree(): textEdit.hide()
	else: textEdit.show()

func _on_Reset_pressed():
	# overwrite user data with res version
	var resource_version = currentShaderPath.replace('user://', 'res://')
	var resource_shader = load(resource_version)
	if not resource_shader or resource_shader.code == "":
		debugLbl.text = 'ERROR: Could not find original resource shader'
		return
	debugLbl.text = ""
	textEdit.text = resource_shader.code
	target.shader.set_code(resource_shader.code)
	_saveShader()

func _on_NewShaderDialog_file_selected(path):
	# create new shader
	if not (path.ends_with('.gdshader') or path.ends_with('.shader')): return
	currentShaderPath = path
	var new_shader = Shader.new()
	new_shader.code = shaderTemplate
	textEdit.text = shaderTemplate
	target.set_shader(new_shader)
	_saveShader()

func _on_FileDialog_file_selected(path):
	# load the selected shader
	currentShaderPath = path
	var shader = load(currentShaderPath)
	if not shader or not shader is Shader:
		debugLbl.text = 'ERROR: Failed to load shader'
		return
	debugLbl.text = ""
	textEdit.text = shader.code
	target.set_shader(shader)

func _on_ImgDialog_file_selected(path):
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		debugLbl.text = 'ERROR: Failed loading image'
		return
	debugLbl.text = ""
	var texture = ImageTexture.new()
	texture.create_from_image(image)
#	name = path.rsplit('/')[-1].rsplit('.')[0]
	target.set_shader_param("texture", texture)

func _on_MeshDialog_file_selected(path):
	var newMesh = ObjParse.parse_obj(path) # only grab one mesh, one surface
	var meshName = path.rsplit("/")[-1]
	meshName = meshName.rsplit(".obj")[0]
	var err = ResourceSaver.save("user://mesh/"+meshName+".mesh", newMesh)
	if err != OK:
		debugLbl.text = 'ERROR: Failed to save mesh'
		return
	debugLbl.text = ""
	if newMesh:
		meshes.append(newMesh)
	meshInst.set_mesh(newMesh)
	meshIndex = meshes.size() - 1

func _on_2D3D_button_up():
	# switches from 2d to 3d mode
	self.set_process(false)
	mode2d = !mode2d
	if mode2d:
		dimension.text = "3D"
		target = rectMat
		shaderTemplate = SHADER_TEMPLATE_2D
		updateShader = UPDATE_SHADER_2D_TIME
		saveShader = SAVE_SHADER_2D_TIME
		userShaderDir = USER_SHADER_DIR_2D
		colorRect.show()
		main3d.hide()
		$ImportMesh.hide()
		$SwitchMesh.hide()
	else:
		dimension.text = "2D"
		target = meshMat
		shaderTemplate = SHADER_TEMPLATE_3D
		updateShader = UPDATE_SHADER_3D_TIME
		saveShader = SAVE_SHADER_3D_TIME
		userShaderDir = USER_SHADER_DIR_3D
		main3d.show()
		colorRect.hide()
		$ImportMesh.show()
		$SwitchMesh.show()
	
	debugLbl.text = ""
	updateDelta = 0.0
	saveDelta = 0.0
	$FileDialog.current_dir = userShaderDir
	$FileDialog.current_path = userShaderDir
	$NewShaderDialog.current_dir = userShaderDir
	$NewShaderDialog.current_path = userShaderDir
	currentShaderPath = target.shader.get_path().replace('res://', 'user://')
	textEdit.text = target.shader.code
	self.set_process(true)
