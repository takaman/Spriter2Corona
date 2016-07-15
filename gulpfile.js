var gulp      = require('gulp');
var watch     = require('gulp-watch');
var luaminify = require('gulp-luaminify');
var concat    = require('gulp-concat');

// put the source here to concat in the right order
var sourceFiles = [
  'source/S2C.lua',
  'source/classes/*.lua',
  'source/returnS2C.lua'
];

function buildTask(){
  gulp.src(sourceFiles)
    .pipe(concat('Spriter2Corona.lua'))

    // disabled for now, there's an error that it not minify all var names
    // .pipe(luaminify())

    // .on('error', function(error){
    //   console.log(error.toString());
    // })

    .pipe(gulp.dest('dist'));
}

gulp.task('default', buildTask);

gulp.task('watch', ['default'], function(){
  return watch(sourceFiles, {verbose: true}, buildTask);
});
