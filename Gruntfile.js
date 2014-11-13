module.exports = function(grunt) {
	var gruntConfig = {
		watch: {
			options: {
				nospawn: true
			},
			src: {
				files: ['src/**/*.coffee'],
				tasks: ['default']
			}
		},
		coffee: {
			src: {
				expand: true,
				cwd: 'src',
				src: ['**/*.coffee'],
				dest: 'bin/js',
				ext: '.js',
				options: {
					bare: true
				}
			}
		},
		browserify: {
			main: {
				files: {
					'./bin/app.js': ['./bin/js/app.js'],
				},
				options: {
					// transform: ['coffeeify']
				}
			}
		}
	};

	grunt.initConfig(gruntConfig);

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-browserify');

	grunt.registerTask('default', ['coffee', 'browserify']);

}