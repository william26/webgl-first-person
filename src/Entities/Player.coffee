module.exports = () ->
	game = undefined
	canvas = undefined
	lockChangeAlert = () ->
		if document.pointerLockElement == canvas ||	document.mozPointerLockElement == canvas ||	document.webkitPointerLockElement == canvas
			document.addEventListener "mousemove", canvasLoop, false
		else
			document.removeEventListener "mousemove", canvasLoop, false
	mouse_movement = {
		x: 0, y: 0
	}
	canvasLoop = (e) ->
		mouse_movement.x = e.movementX ||
			e.mozMovementX ||
			e.webkitMovementX ||
			0

		mouse_movement.y = e.movementY ||
			e.mozMovementY ||
			e.webkitMovementY ||
			0

	keyPressed = []
	buttonsPressed = []

	movement = new THREE.Vector3()

	onDocumentMouseDown = (e) ->
		buttonsPressed[e.which] = true

	onDocumentMouseUp = (e) ->
		buttonsPressed[e.which] = false

	onDocumentKeyDown = (e) ->
		keyPressed[e.keyCode] = true

	onDocumentKeyUp = (e) ->
		keyPressed[e.keyCode] = false

	rotateAroundObjectAxis = (object, axis, radians) ->
		rotationMatrix = new THREE.Matrix4()
		rotationMatrix.makeRotationAxis(axis.normalize(), radians)
		object.matrix.multiply(rotationMatrix);
		object.rotation.setFromRotationMatrix(object.matrix, object.order)

	rotateAroundWorldAxis = (object, axis, radians) ->
		rotWorldMatrix = new THREE.Matrix4()
		rotWorldMatrix.makeRotationAxis(axis.normalize(), radians)
		object.matrix = rotWorldMatrix
		object.rotation.setFromRotationMatrix(object.matrix, object.order)


	drawLine = (from, to) ->
		geometry = new THREE.Geometry()
		material = new THREE.LineBasicMaterial {
			color: 0x0000ff,
			linewidth: 5
		}
		geometry.vertices.push(from)
		geometry.vertices.push(to)
		line = new THREE.Line geometry, material
		trail.push line
		game.scene.add line
		if trail.length > 500
			game.scene.remove trail[0]
			trail.shift()



	anglex = 0
	angley = 0
	companion_cube = undefined
	walk_style_angle = 0
	trail = []




	class Player
		constructor: () ->
			@object = new THREE.Object3D()
			@speed = new THREE.Vector3()
			@state = 'walking'
			@feet = new THREE.Object3D()
			return

		initControls: () ->
			canvas = game.renderer.domElement
			canvas.requestPointerLock = canvas.requestPointerLock ||
				canvas.mozRequestPointerLock ||
				canvas.webkitRequestPointerLock

			$(canvas).click () ->
				canvas.requestPointerLock()

			document.addEventListener('pointerlockchange', lockChangeAlert, false)
			document.addEventListener('pointerlockchange', lockChangeAlert, false)
			document.addEventListener('mozpointerlockchange', lockChangeAlert, false)
			document.addEventListener('webkitpointerlockchange', lockChangeAlert, false)
			document.addEventListener('mousedown', onDocumentMouseDown, false)
			document.addEventListener('mouseup', onDocumentMouseUp, false)
			document.addEventListener('keydown', onDocumentKeyDown, false)
			document.addEventListener('keyup', onDocumentKeyUp, false)


		init: (g) ->
			game = g
			@object.add game.camera
			game.camera.position.y = 175
			@object.position.z = 500
			@object.position.y = 0
			@object. add @feet
			@top_position = 0
			@initControls()


		controls: () ->
			speed = game.constants.PLAYER_SPEED
			speed *= game.constants.PLAYER_SPEED_RUN_FACTOR if keyPressed[16]

			movement = new THREE.Vector3()

			if keyPressed[87]
				movement.z = -1
			if keyPressed[83]
				movement.z = 1
			if keyPressed[65]
				movement.x = -1
			if keyPressed[68]
				movement.x = 1

			@speed.z = speed * (movement.z * Math.cos(angley) - movement.x * Math.sin(angley))
			@speed.x = speed * (movement.x * Math.cos(angley) + movement.z * Math.sin(angley))

			if (@speed.length() > 0)
				walk_style_angle += 0.25
				walk_style_angle += 0.1 if keyPressed[16]
				walk_style_angle = walk_style_angle % (2 * Math.PI)
			else
				walk_style_angle = 0
			walk_style_height = 5

			game.camera.position.y = Math.sin(walk_style_angle) * walk_style_height + 1 + 175


			anglex -= mouse_movement.y * game.constants.MOUSE_SENSITIVITY
			if anglex > Math.PI / 2
				anglex = Math.PI / 2
			if anglex < -Math.PI / 2
				anglex = -Math.PI / 2

			angley -= mouse_movement.x * game.constants.MOUSE_SENSITIVITY
			rotateAroundWorldAxis(game.camera, new THREE.Vector3(0, 1, 0), angley)
			rotateAroundObjectAxis(game.camera, new THREE.Vector3(1, 0, 0), anglex)
			rotateAroundWorldAxis(companion_cube, new THREE.Vector3(0, 1, 0), angley)

			mouse_movement = {
				x: 0, y: 0
			}

			if @state == 'walking' and keyPressed[32]
				@state = 'jumping'
				@speed.y = 15

		collisionForAngle: (origin, angle, delta) ->
			vector = new THREE.Vector3()
			vector.copy(origin)
			direction = new THREE.Vector3(-Math.sin(angle), 0, -Math.cos(angle))
			raycaster = new THREE.Raycaster(vector, direction, 0, 10)
			intersects = raycaster.intersectObjects(game.world)
			_delta = undefined
			for intersect in intersects
				_delta = new THREE.Vector3().copy(delta)
				_delta.projectOnVector(intersect.face.normal)
				if _delta.angleTo(intersect.face.normal) < Math.PI / 2
					_delta = undefined
			return _delta

		testCollisions: (old_position, delta) ->
			k = 0
			d = undefined
			while k <= 2 * Math.PI
				de = @collisionForAngle(@object.position, k, delta)
				if d and de and not d.equals de
					d.add de
				else if de
					d = de
				k += Math.PI / 2
			@object.position.sub(d) if d

			k = 0
			d = undefined
			vector = new THREE.Vector3().copy(@object.position).add(new THREE.Vector3(0, 175 / 2, 0))
			while k <= 2 * Math.PI
				de = @collisionForAngle(vector, k, delta)
				if d and de and not d.equals de
					d.add de
				else if de
					d = de
				k += Math.PI / 2
			@object.position.sub(d) if d

			k = 0
			d = undefined
			vector = new THREE.Vector3().copy(@object.position).add(new THREE.Vector3(0, 175, 0))
			while k <= 2 * Math.PI
				de = @collisionForAngle(vector, k, delta)
				if d and de and not d.equals de
					d.add de
				else if de
					d = de
				k += Math.PI / 2
			@object.position.sub(d) if d



			vector = new THREE.Vector3()
			vector.copy(@object.position)
			vector.y += 175
			v2 = new THREE.Vector3(0,-1,0)
			vert_ray = new THREE.Raycaster(vector, v2)

			if not old_position.equals(@object.position)
				gv = new THREE.Vector3().copy(vector).sub(new THREE.Vector3(0,175,0))
				drawLine gv, new THREE.Vector3().subVectors(gv, v2), true

			intersects = vert_ray.intersectObjects(game.world)
			if intersects.length > 0
				for intersect in intersects
					if intersect.point.y > @top_position
						@top_position = intersect.point.y + 5
				@object.position.y = @top_position
			if (@object.position.y > @top_position)
				@state = 'jumping'


		physics: (old_position) ->
			@top_position = 0
			old_position = new THREE.Vector3()
			old_position.copy(@object.position)
			@object.position.add(@speed)
			delta = new THREE.Vector3().subVectors(@object.position, old_position)
			@testCollisions(old_position, delta)


			if @state == 'jumping' and @object.position.y > @top_position
				@speed.y -= 1
			else if @object.position.y <= @top_position
				@state = 'walking'
				@speed.y = 0
				@object.position.y = @top_position
			if @object.state == 'walking'
				@object.position.y = @top_position


		render: () ->
			return

	Player
