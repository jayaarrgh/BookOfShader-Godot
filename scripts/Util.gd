class_name Util
extends Object


# Thanks to https://www.davidepesce.com/2019/11/04/essential-guide-to-godot-filesystem-api/
# For the godot 3 implementation
# updated to godot 4 by jayaarrgh
static func copy_recursive(from, to):
	# create target directory, if nonexistent
	if DirAccess.dir_exists_absolute(to): return
	if DirAccess.make_dir_recursive_absolute(to) != OK: return
		
	# Open directory
	var dirAccess = DirAccess.open(from)
	# List directory content
	if dirAccess.list_dir_begin() == OK: # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dirAccess.get_next()
		while file_name != "":
			if dirAccess.current_is_dir():
				copy_recursive(from + "/" + file_name, to + "/" + file_name)
			else:
				dirAccess.copy(from + "/" + file_name, to + "/" + file_name)
			file_name = dirAccess.get_next()
	else:
		print("Error copying " + from + " to " + to)

