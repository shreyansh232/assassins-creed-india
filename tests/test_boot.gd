# tests/test_boot.gd
extends SceneTree
func _init():
	assert(DirAccess.dir_exists_absolute("res://scripts"), "scripts missing")
	print("BOOT_OK")
	quit()
