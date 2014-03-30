module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-includes');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.initConfig({
    includes: {
      files: {
        src: ['src/main.asm'],
        dest: 'built',
        flatten: true,
        options: {
          silent: true
        }
      }
    },
    watch: {
      asm: {
        files: ['src/**/*.asm'],
        tasks: ['includes']
      },
    }
  });

  grunt.registerTask('default', ['includes']);
  grunt.registerTask('listen', ['includes', 'watch']);
};
