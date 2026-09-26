# scripts/crowd_blend.gd
extends Node
class_name BlendSys
func can_enter(zone_id: String, disguise: String, has_farman: bool) -> bool:
	if has_farman: return true
	if zone_id == "fort": return disguise == "noble"
	if zone_id == "taj": return disguise == "mazdoor" or disguise == "noble"
	return true
