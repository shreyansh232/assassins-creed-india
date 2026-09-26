# scripts/detection.gd
extends Node
class_name DetectionSys
func get_state(dist: float, crouched: bool, hiding: bool) -> String:
	if hiding and crouched: return "unseen"
	if dist > 18.0: return "unseen"
	if dist < 8.0 and not crouched: return "hunted"
	if dist < 12.0: return "suspicious"
	return "unseen"
