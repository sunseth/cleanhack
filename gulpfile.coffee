async = require 'async'
exec = require('child_process').exec
gulp = require 'gulp'
del = require 'del'
bowerFiles = require 'main-bower-files'
variant = require 'rework-variant'
concat = require 'gulp-concat'
rename = require 'gulp-rename'
nodemon = require 'gulp-nodemon'
bless = require 'gulp-bless'
templateCache = require 'gulp-angular-templatecache'
changed = require 'gulp-changed'
imagemin = require 'gulp-imagemin'

gutil = require 'gulp-util'
source = require 'vinyl-source-stream'
watchify = require 'watchify'
browserify = require 'browserify'
envify = require 'envify'
uglify = require 'gulp-uglify'
filter = require 'gulp-filter'
rename = require 'gulp-rename'

input =
  css: "#{__dirname}/source/css/**/*.css"
  coffee: "#{__dirname}/source/angular/**/*.coffee"
  angular: "#{__dirname}/source/angular/index.coffee"
  bower: "#{__dirname}/bower_components"
  semantic: "#{__dirname}/public/vendor/semantic-ui/dist/*.css"

output =
  css: "#{__dirname}/public/css"
  js: "#{__dirname}/public/js"
  vendor: "#{__dirname}/public/vendor"
  semantic: "#{__dirname}/public/vendor/semantic-ui/dist"

gulp.task 'css', ->
  gulp.src input.css
    .pipe concat('style.css')
    .pipe gulp.dest(output.css)

gulp.task 'bower', ->
  files = bowerFiles()
  EXCEPT = ['!base64/**/*', '!xdomain/**/*', '!polymer-mutationobserver/**/*'] # Bower files to exclude from vendor.js bundle
  gulp.src files, {base: input.bower}
    .pipe filter(['**/*.js'].concat EXCEPT)
    .pipe concat('vendor.js')
    .pipe uglify()
    .pipe gulp.dest(output.vendor)

  gulp.src files, {base: input.bower}
    .pipe gulp.dest(output.vendor)

gulp.task 'coffee', ->
  bundler = browserify input.angular,
    extensions: ['.js', '.coffee', '.json', '.cson']
  bundler.transform 'coffeeify'
  bundler.transform {global: true}, 'envify'
  return bundler.bundle()
    .on 'error', (err) -> gutil.log "Browserify error:", gutil.colors.red(err.message)
    .pipe source('app.js')
    .pipe gulp.dest(output.js)

gulp.task 'watch-coffee', ->
  bundler = watchify browserify input.angular,
    extensions: ['.js', '.coffee', '.json', '.cson']
  bundler.transform 'coffeeify'
  bundler.transform {global: true}, 'envify'
  bundler.on 'update', (ids) ->
    for id in ids
      gutil.log "Coffee compiling", gutil.colors.magenta(id)
    rebundle()
  rebundle = ->
    bundler.bundle()
      .on 'error', (err) -> gutil.log "Browserify error:", gutil.colors.red(err.message)
      .pipe source('app.js')
      .pipe gulp.dest(output.js)
  return rebundle()

gulp.task 'watch', ['build', 'watch-coffee'], ->
  gulp.watch input.css, ['css']
  gulp.watch input.bower, ['bower']

gulp.task 'nodemon', ['build'], ->
  return nodemon
    script: 'app.coffee'
    ignore: [
      "bower_components/**/*",
      "node_modules/**/*"
    ]

gulp.task 'serve', ['nodemon', 'watch']
gulp.task 'build', ['css', 'bower', 'coffee']