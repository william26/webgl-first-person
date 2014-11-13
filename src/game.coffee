

module.exports = (id) ->
	game = {
		constants: {
			PLAYER_SPEED: 5,
			PLAYER_SPEED_RUN_FACTOR: 2,
			MOUSE_SENSITIVITY: 0.002
		}
	}

	$element = game.$element = $(id)

	camera = game.camera = undefined
	scene = game.scene = undefined

	world = game.world = []
	entities = game.entities = []
	renderer = game.renderer = undefined

	player = game.player = undefined

	game.initPlayer = () ->
		game.player = new Player()
		game.player.init(game)
		game.scene.add game.player.object
		game.entities.push game.player
	game.initLighting = () ->
		# ambient
		ambient = new THREE.AmbientLight 0x606060
		game.scene.add ambient

		directional = new THREE.DirectionalLight 0xffffff
		directional.position.set(1, 0.75, 0.5).normalize()
		game.scene.add directional

	game.initCube = () ->
		cubeGeo = new THREE.BoxGeometry(100, 100, 100)
		cubeMaterial = new THREE.MeshLambertMaterial({
			color: 0xfeb74c,
			ambient: 0x00ff80,
			shading: THREE.FlatShading
		})

		cube_mesh = new THREE.Mesh(cubeGeo, cubeMaterial)
		cube_mesh.position.set 0, 25, 0
		game.world.push cube_mesh
		game.scene.add cube_mesh

	game.initRenderer = () ->
		game.renderer = new THREE.WebGLRenderer({
			antialias: true
		})
		game.renderer.setClearColor(0xf0f0f0);
		game.renderer.setSize(window.innerWidth, window.innerHeight);
		game.$element.append game.renderer.domElement

	game.init = () ->
		game.camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 10000);
		game.camera.lookAt new THREE.Vector3(0, 0, 0)
		game.scene = new THREE.Scene()

		@initRenderer()


		@initPlayer()
		@initCube()
		@initLighting()
		

	game.controls = () ->
		for entity in game.entities
			entity.controls()

	game.physics = () ->
		for entity in game.entities
			entity.physics()


	game.render = () ->
		for entity in game.entities
			entity.render()
		game.renderer.render game.scene, game.camera

	game.animate = () ->
		requestAnimationFrame game.animate

		game.controls()
		game.physics()
		game.render()

	game.run = () ->
		@init()
		@animate()

		return

	Player = require('./Entities/Player')(game)

	game

