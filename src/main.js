var WIDTH = 600,
	HEIGHT = 400;
var VIEW_ANGLE = 45,
	ASPECT = WIDTH / HEIGHT,
	NEAR = 0.1,
	FAR = 10000;

var $container = $('#container');

var renderer = new THREE.WebGLRenderer();
var camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);

var scene = new THREE.Scene();

scene.add(camera);

camera.position.z = 300;
camera.position.x = 300;

renderer.setSize(WIDTH, HEIGHT);

$container.append(renderer.domElement);

/*---------------------------------------------*/
var spheres = [];

function createSphere(radius, position) {
	if (typeof position == 'undefined') {
		position = {
			x: 0,
			y: 0,
			z: 0
		};
	}

	var sphereMaterial = new THREE.MeshLambertMaterial({
		color: 0xCC0000
	});

	var radius = 50,
		segments = 16,
		rings = 16;

	var sphere = new THREE.Mesh(
		new THREE.SphereGeometry(radius, segments, rings),
		sphereMaterial
	);
	sphere.origin = {
		x: position.x,
		y: position.y,
		z: position.z
	};

	sphere.position = position;
	sphere.state = 'normal';
	sphere.offset = 0;

	spheres.push(sphere);
	scene.add(sphere);
	return sphere;
}
// var player = createSphere();
for (var i = 0; i < 100; i++) {
	var sphere = createSphere(40 + 20 * Math.random(), {
		x: 50 * i,
		y: 0,
		z: 0
	});
	(function(sphere, i) {
		$(window).keydown(function() {
			setTimeout(function() {
				sphere.state = 'bounce_up';
				phere.state_b = 'bounce_back';
				phere.state_c = 'bounce_left';
			}, 50 * i);
		});
	})(sphere, i);

}

// create a point light
var pointLight =
	new THREE.PointLight(0xFFFFFF);

// set its position
pointLight.position.x = 10;
pointLight.position.y = 50;
pointLight.position.z = 500;

// add to the scene
scene.add(pointLight);

// draw!
var render = function() {
	renderer.render(scene, camera);
}

	function animate() {
		requestAnimationFrame(animate);
		for (var k in spheres) {

			var sphere = spheres[k];

			var offset = Math.abs(sphere.origin.y - sphere.position.y);
			if (sphere.state == "bounce_up") {
				sphere.position.y -= 0.1 + offset / 30;
				if (offset > 100) {
					sphere.state = "bounce_down";
				}
			}

			if (sphere.state == 'bounce_down') {
				sphere.position.y += 0.1 + offset / 30;
				if (offset < 1) {
					sphere.state = "bounce_up";
				}
			}

			// if (sphere.state_b == "bounce_back") {
			// 	sphere.position.z -= 10- offset / 50;
			// 	if (offset > 100) {
			// 		sphere.state_b = "bounce_front";
			// 	}
			// }

			// if (sphere.state_b == 'bounce_front') {
			// 	sphere.position.z += 10- offset / 50;
			// 	if (offset < 1) {
			// 		sphere.state_b = "normal";
			// 	}
			// }

		}

		render();
	}
animate();