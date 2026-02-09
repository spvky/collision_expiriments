package main

import "core:fmt"
import l "core:math/linalg"
import gc "shared:ghst/collision"
import rl "vendor:raylib"

camera: rl.Camera3D
tri: Triangle

Vec3 :: [3]f32
Triangle :: [3]Vec3

a, b, c: gc.Collider

init :: proc() {
	camera = rl.Camera3D {
		position = {0, 0, -10},
		fovy     = 45,
		up       = {0, 1, 0},
	}

	a = gc.make_collider_rect(Vec3{-2, 0, 0}, Vec3{2, 2, 2})


	c = gc.make_collider_rect(Vec3{2, 0, 0}, Vec3{2, 2, 2})


	b = gc.Collision_Sphere {
		center = {0, 0, 0},
		radius = 0.5,
	}


	tri = {{-2, 2, 3}, {2, 2, 3}, {0, -2, 3}}
}

handle_colliders :: proc() {
	delta := rl.GetFrameTime()
	move_delta: Vec3
	if rl.IsKeyDown(.W) {
		move_delta.y += 1
	}
	if rl.IsKeyDown(.S) {
		move_delta.y -= 1
	}
	if rl.IsKeyDown(.A) {
		move_delta.x += 1
	}
	if rl.IsKeyDown(.D) {
		move_delta.x -= 1
	}
	sphere := &b.(gc.Collision_Sphere)
	sphere.center += move_delta * delta

	if overlap, simplex := gc.gjk(a, b); overlap {
		draw_simplex(simplex)
		mtv := gc.solve_epa(simplex, a, b)
		draw_mtv(mtv)
	}
}

draw_colliders :: proc() {
	cube := a.(gc.Collision_Poly)
	sphere := b.(gc.Collision_Sphere)

	edges := gc.collider_rect_edges(a)

	for i in 0 ..< 8 {
		rl.DrawSphere(cube.points[i], 0.1, rl.BEIGE)
	}

	for i in 0 ..< 12 {
		rl.DrawLine3D(edges[i][0], edges[i][1], rl.BEIGE)
	}

	rl.DrawSphere(sphere.center, sphere.radius, rl.GOLD)

	rl.DrawSphere({0, 0, 0}, 0.1, rl.GRAY)
}

main :: proc() {
	rl.InitWindow(1600, 900, "collision")
	init()
	normal := l.cross(tri[1] - tri[0], tri[2] - tri[0])
	fmt.printfln("Tri Normal %v", normal)
	fmt.printfln("Point Dot Normal: %.2f", l.dot(tri[0], normal))

	for !rl.WindowShouldClose() {
		update()
	}
}

draw_simplex :: proc(simplex: gc.Simplex) {
	rl.DrawSphere(simplex.a, 0.1, rl.GREEN)
	rl.DrawSphere(simplex.b, 0.1, rl.GREEN)
	rl.DrawSphere(simplex.c, 0.1, rl.GREEN)
	rl.DrawSphere(simplex.d, 0.1, rl.GREEN)

	rl.DrawLine3D(simplex.a, simplex.b, rl.GREEN)
	rl.DrawLine3D(simplex.a, simplex.c, rl.GREEN)
	rl.DrawLine3D(simplex.a, simplex.d, rl.GREEN)
	rl.DrawLine3D(simplex.b, simplex.c, rl.GREEN)
	rl.DrawLine3D(simplex.b, simplex.d, rl.GREEN)
	rl.DrawLine3D(simplex.c, simplex.d, rl.GREEN)
}

draw_mtv :: proc(mtv: Vec3) {
	rl.DrawLine3D({0, 0, 0}, mtv, rl.RED)
}

update :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.BeginMode3D(camera)
	handle_colliders()
	// rl.DrawSphere(tri[0], 0.1, rl.WHITE)
	// rl.DrawSphere(tri[1], 0.1, rl.YELLOW)
	// rl.DrawSphere(tri[2], 0.1, rl.GRAY)
	// rl.DrawLine3D(tri[0], tri[1], rl.BLUE)
	// rl.DrawLine3D(tri[0], tri[2], rl.BLUE)
	// rl.DrawLine3D(tri[1], tri[2], rl.BLUE)
	// avg := (tri[0] + tri[1] + tri[2]) / 3
	// ab := tri[1] - tri[0]
	// ac := tri[2] - tri[0]
	// ao := -tri[0]
	// abc := l.normalize(l.cross(ab, ac))
	// vtp1 := l.normalize(l.vector_triple_product(ab, ao, ab))
	// vtp2 := l.normalize(l.vector_triple_product(ac, ao, ac))
	// // rl.DrawLine3D(avg, avg + abc, rl.GREEN)
	// rl.DrawLine3D(avg, avg + vtp1, rl.RED)
	// rl.DrawLine3D(avg, avg + vtp2, rl.PINK)
	draw_colliders()
	rl.EndMode3D()
	rl.EndDrawing()
}
