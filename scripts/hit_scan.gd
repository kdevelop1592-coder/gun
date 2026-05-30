extends RefCounted
class_name HitScan

static func shoot(world: World3D, origin: Vector3, direction: Vector3, distance: float = 250.0) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction.normalized() * distance)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	return world.direct_space_state.intersect_ray(query)

