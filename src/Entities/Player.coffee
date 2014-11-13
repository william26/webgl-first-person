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
	anglex = 0
	angley = 0
	companion_cube = undefined
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


			cubeGeo = new THREE.BoxGeometry(50, 100, 50)
			cubeMaterial = new THREE.MeshLambertMaterial({
				color: 0x000000,
				ambient: 0x000000,
				shading: THREE.FlatShading
			})
			companion_cube = new THREE.Mesh(cubeGeo, cubeMaterial)
			companion_cube.position.z = - 10
			companion_cube.position.y = -150
			# @object.add companion_cube

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


		testCollisions: (old_position, delta) ->
			vector = new THREE.Vector3()
			vector.copy(@object.position)
			vector.y = @object.position.y
			direction = new THREE.Vector3(-Math.sin(angley), 0, -Math.cos(angley))
			# console.log direction
			raycaster = new THREE.Raycaster(vector, direction, 0, 50)
			intersects = raycaster.intersectObjects(game.world)

			for intersect in intersects
				_delta = new THREE.Vector3().copy(delta)
				_delta.projectOnVector(intersect.face.normal)
				@object.position.sub(_delta)


			# vector = new THREE.vector3()
			# vector.copy(@object.position)
			# vector.y += game.camera.positon
			# vert_ray = new THREE.Raycaster(vector, new THREE.Vector3(0,-1,0))
			# intersects = raycaster.intersectObjects(game.world)
			
			# for intersect in intersects
			# 	if intersect.point.y > @top_position
			# 		console.log @top_position
			# 		@top_position = intersect.point.y
			# if (@object.position.y > @top_position)
			# 	@state = 'jumping'


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
