/*jslint regexp: true */
'use strict';

module.exports = function (grunt) {

  var _, localConfig, yeoman;

  _ = require('lodash');

  try {
    localConfig = require('./server/local.env');
  } catch (_err) {
    localConfig = {};
  }

  // Configurable paths for the application
  yeoman = {
    client: 'public',
    dist: 'dist'
  };

  yeoman.srcpath = {
    jade: {
      cwd: yeoman.client,
      src: [
        '*.jade',
        '**/*.jade',
        '!bower_components/**/*.jade'
      ]
    },
    sass: {
      src: yeoman.client + '/app/app.scss'
    },
    less: {
      cwd: yeoman.client,
      src: ['bower_components/bootstrap/less/*.less']
    },
    coffee: {
      cwd: yeoman.client,
      src: [
        '*.coffee',
        '**/*.coffee',
        '!{,*/}*.{spec,mock}.coffee',
        '!bower_components/**/*.coffee'
      ]
    },
    copyOverride: {
      cwd: yeoman.client + '/overrides',
      src: ['bootstrap/**/*']
    },
    injectSass: {
      src: [
        yeoman.client + '/app/*.scss',
        yeoman.client + '/app/**/{app,style}.scss',
        yeoman.client + '/app/**/*.scss',
        '!' + yeoman.client + '/app/app.scss'
      ]
    },
    injectJS: {
      src: [
        '.tmp/app/config.js',
        '.tmp/app/app.js',
        '.tmp/app/**/app.js',
        '.tmp/app/**/*.js',
        '!.tmp/app/{,*/}*.{spec,mock}.js',
        yeoman.client + '/assets/**/*.js'
        // 'tmp/app/config.js',
        // 'tmp/app/app.js',
        // 'tmp/app/**/app.js',
        // 'tmp/app/**/*.js',
        // '!tmp/app/{,*/}*.{spec,mock}.js',
      ]
    },
    injectCss: {
      src: [
        '.tmp/app/*.css',
        '.tmp/app/**/*.css'
      ]
    }
  };

  function generateFiles(data) {
    var cwd, file, i, len, src;
    data.files = [];
    if (!data.src) {
      return;
    }
    src = typeof data.src === 'string' ? [data.src] : data.src;
    if (data.cwd) {
      cwd = data.cwd + '/';
    } else {
      cwd = '';
    }
    for (i = 0, len = src.length; i < len; i++) {
      file = src[i];
      data.files.push(file.replace(/^([!]{0,1})/, '$1' + cwd));
    }
  }

  Object.keys(yeoman.srcpath).forEach(function (name) {
    generateFiles(yeoman.srcpath[name]);
  });

  // Load grunt tasks automatically, when needed
  require('jit-grunt')(grunt, {
    express: 'grunt-express-server',
    useminPrepare: 'grunt-usemin',
    ngtemplates: 'grunt-angular-templates',
    ngconstant: 'grunt-ng-constant',
    injector: 'grunt-asset-injector',
    i18nextract: 'grunt-angular-translate'
  });

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Define the configuration for all the tasks
  grunt.initConfig({

    // Project settings
    yeoman: yeoman,

    env: {
      test: {
        NODE_ENV: 'test'
      },
      prod: {
        NODE_ENV: 'production'
      },
      all: localConfig
    },

    express: {
      options: {
        port: process.env.PORT || 7000
      },
      dev: {
        options: {
          opts: ['node_modules/coffee-script/bin/coffee'],
          // script: 'server/app.js',
          script: 'server/app.coffee',
          debug: false
        }
      },
      dev2: {
        options: {
          port: 8010,
          opts: ['node_modules/coffee-script/bin/coffee'],
          // script: 'server/app.js',
          script: 'server/app.coffee',
          debug: true
        }
      },
      prod: {
        options: {
          script: 'dist/server/app.js'
        }
      }
    },

    open: {
      server: {
        url: 'http://127.0.0.1:<%= express.options.port %>',
        app: process.platform.search(/^win/i) !== -1 ? 'Chrome' : 'Google Chrome'
      }
    },

    watch: {
      jade: {
        files: yeoman.srcpath.jade.files,
        tasks: ['newer:jade']
      },
      sass: {
        files: _.flatten([
          yeoman.srcpath.sass.files,
          yeoman.srcpath.injectSass.files
        ]),
        tasks: ['sass', 'autoprefixer']
      },
      less: {
        files: yeoman.srcpath.less.files,
        tasks: ['less']
      },
      coffee: {
        files: yeoman.srcpath.coffee.files,
        tasks: ['newer:coffee']
      },
      i18nextract: {
        files: ['.tmp/app/**/*.html', '.tmp/app/**/*.js'],
        tasks: ['i18nextract']
      },
      copyOverride: {
        files: yeoman.srcpath.copyOverride.files,
        tasks: ['copy:override']
      },
      injectJS: {
        files: yeoman.srcpath.injectJS.files,
        tasks: ['injector:scripts']
      },
      injectSass: {
        files: yeoman.srcpath.injectSass.files,
        tasks: ['injector:sass']
      },
      injectCss: {
        files: yeoman.srcpath.injectCss.files,
        tasks: ['injector:css']
      },
      injectAll: {
        files: ['.tmp/index.html'],
        tasks: ['injector:scripts', 'injector:css', 'wiredep']
      },
      livereload: {
        files: [
          '{.tmp,<%= yeoman.client %>}/app/**/*.css',
          '{.tmp,<%= yeoman.client %>}/app/**/*.html',
          '{.tmp,<%= yeoman.client %>}/app/**/*.js',
          '!{.tmp,<%= yeoman.client %>}app/**/*.spec.js',
          '!{.tmp,<%= yeoman.client %>}/app/**/*.mock.js',
          '<%= yeoman.client %>/assets/img/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ],
        options: {
          livereload: true
        }
      }
    },

    // Empties folders to start fresh
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/*'
          ]
        }]
      },
      server: '.tmp'
    },

    injector: {

      // Inject component scss into app.scss
      sass: {
        options: {
          transform: function (filePath) {
            filePath = filePath.replace('/' + grunt.config('yeoman.client') + '/app/', '');
            return '@import \'' + filePath + '\';';
          },
          starttag: '// injector',
          endtag: '// endinjector'
        },
        files: {
          '<%= yeoman.client %>/app/app.scss': yeoman.srcpath.injectSass.src
        }
      },

      // Inject application script files into index.html (doesn't include bower)
      scripts: {
        options: {
          transform: function (filePath) {
            filePath = filePath.replace('/' + grunt.config('yeoman.client') + '/', '');
            filePath = filePath.replace('/.tmp/', '');
            return '<script src="' + filePath + '"></script>';
          },
          starttag: '<!-- injector:js -->',
          endtag: '<!-- endinjector -->'
        },
        files: {
          '.tmp/index.html': yeoman.srcpath.injectJS.src
        }
      },

      // Inject component css into index.html
      css: {
        options: {
          transform: function (filePath) {
            filePath = filePath.replace('/' + grunt.config('yeoman.client') + '/', '');
            filePath = filePath.replace('/.tmp/', '');
            return '<link rel="stylesheet" href="' + filePath + '">';
          },
          starttag: '<!-- injector:css -->',
          endtag: '<!-- endinjector -->'
        },
        files: {
          '.tmp/index.html': yeoman.srcpath.injectCss.src
        }
      }
    },

    // Compiles Jade to html
    jade: {
      compile: {
        options: {
          data: {
            debug: false
          },
          pretty: true
        },
        files: [{
          expand: true,
          cwd: yeoman.srcpath.jade.cwd,
          src: yeoman.srcpath.jade.src,
          dest: '.tmp',
          ext: '.html',
          extDot: 'last'
        }]
      }
    },

    // Compiles Sass to CSS
    sass: {
      compile: {
        options: {
          compass: false
        },
        files: {
          '.tmp/app/app.css': yeoman.srcpath.sass.src
        }
      }
    },

    // Compiles less to CSS (bootstrao only)
    less: {
      compile: {
        files: {
          'public/bower_components/bootstrap/dist/css/bootstrap.css': yeoman.client + '/bower_components/bootstrap/less/bootstrap.less'
        }
      }
    },

    // Compiles CoffeeScript to JavaScript
    coffee: {
      compile: {
        options: {
          sourceMap: true
        },
        files: [{
          expand: true,
          cwd: yeoman.srcpath.coffee.cwd,
          src: yeoman.srcpath.coffee.src,
          dest: '.tmp',
          ext: '.js',
          extDot: 'last'
        }]
      }
    },

    // Run some tasks in parallel to speed up the build process
    concurrent: {
      server: [
        'jade',
        'sass',
        'less',
        'coffee'
      ],
      dist: [
        'jade',
        'sass',
        'less',
        'coffee'
      ]
    },

    // Extract all the translation keys for angular-translate
    i18nextract: {
      default_options: {
        nullEmpty: false,
        namespace: true,
        safeMode: false,
        stringifyOptions: {
          space: 2
        },
        customRegex: ['translationId\\s*:\\s*\'(([a-zA-Z0-9\\.\\_\\-])+)\''],
        prefix: 'locale-',
        suffix: '.json',
        src: [
          '.tmp/app/**/*.html', '.tmp/app/index.html', '.tmp/app/**/*.js',
          '!.tmp/app/**/*.decorator.html'
        ],
        lang: ['ko-KR', 'en-US', 'ja-JP'],
        dest: '<%= yeoman.client %>/assets/i18n'
      }
    },

    // Automatically inject Bower components into the app
    wiredep: {
      target: {
        overrides: {
          // see `Bower Overrides` section below.
          //
          // This inline object offers another way to define your overrides if
          // modifying your project's `bower.json` isn't an option.
          bootstrap: {
            main: ['dist/css/bootstrap.css', 'dist/js/bootstrap.js']
          },
          'font-awesome': {
            main: ['css/font-awesome.css']
          },
          moment: {
            main: ['moment.js', 'locale/ko.js', 'locale/en.js', 'locale/ja.js']
          },
          trianglify: {
            main: ['dist/trianglify.min.js']
          }
        },
        src: '.tmp/index.html',
        ignorePath: '../<%= yeoman.client %>/'
      }
    },

    // Add vendor prefixed styles
    autoprefixer: {
      options: {
        browsers: ['last 3 versions', 'ie 8', 'ie 9']
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/',
          src: '{,*/}*.css',
          dest: '.tmp/'
        }]
      }
    },

    htmlmin: {
      dist: {
        options: {
          collapseWhitespace: true,
          conservativeCollapse: true,
          collapseBooleanAttributes: true,
          removeCommentsFromCDATA: true
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>',
          src: ['*.html', '{,*/}*.html'],
          dest: '<%= yeoman.dist %>'
        }]
      }
    },

    // http://stackoverflow.com/questions/16339595/how-do-i-configure-different-environments-in-angular-js
    ngconstant: {
      options: {
        name: 'config',
        dest: '.tmp/app/config.js'
      },
      dist: {
        constants: function () {
          return {
            config: grunt.file.readJSON('./public/config/config.json')
          };
        }
      },
    },

    // Package all the html partials into a single javascript payload
    ngtemplates: {
      options: {
        // This should be the name of your apps angular module
        module: 'james',
        htmlmin: {
          collapseBooleanAttributes: true,
          collapseWhitespace: true,
          removeAttributeQuotes: true,
          removeEmptyAttributes: true,
          removeRedundantAttributes: true,
          removeScriptTypeAttributes: true,
          removeStyleLinkTypeAttributes: true
        },
        usemin: 'app/app.js'
      },
      main: {
        cwd: '.tmp',
        src: [
          'app/*.html',
          'app/**/*.html'
        ],
        dest: '.tmp/templates.js'
      }
    },

    // Allow the use of non-minsafe AngularJS files. Automatically makes it
    // minsafe compatible so Uglify does not destroy the ng references
    ngAnnotate: {
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/concat',
          src: '*/**.js',
          dest: '.tmp/concat'
        }]
      }
    },

    // Copies remaining files to places other tasks can use
    copy: {
      override: {
        files: [{
          expand: true,
          dot: true,
          cwd: yeoman.srcpath.copyOverride.cwd,
          src: yeoman.srcpath.copyOverride.src,
          dest: '<%= yeoman.client %>/bower_components'
        }]
      },
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.client %>',
          dest: '<%= yeoman.dist %>/public',
          src: [
            '*.{ico,png,txt}',
            '.htaccess',
            'assets/css/{,*/}*',
            'assets/img/{,*/}*',
            'assets/i18n/{,*/}*'
          ]
        }, {
          expand: true,
          cwd: '<%= yeoman.client %>/bower_components/font-awesome',
          dest: '<%= yeoman.dist %>/public',
          src: ['fonts/*']
        }, {
          expand: true,
          cwd: '.tmp',
          dest: '<%= yeoman.dist %>/public',
          src: ['index.html']
        }, {
          expand: true,
          dest: '<%= yeoman.dist %>',
          src: [
            'package.json',
            'server/**/*'
          ]
        }]
      }
    },

    // Renames files for browser caching purposes
    filerev: {
      dist: {
        src: [
          '<%= yeoman.dist %>/public/{,*/}*.{js,css}'
        ]
      }
    },

    // Reads HTML for usemin blocks to enable smart builds that automatically
    // concat, minify and revision files. Creates configurations in memory so
    // additional tasks can operate on them
    useminPrepare: {
      html: ['.tmp/index.html'],
      options: {
        dest: '<%= yeoman.dist %>/public'
      }
    },

    // Performs rewrites based on rev and the useminPrepare configuration
    usemin: {
      html: ['<%= yeoman.dist %>/public/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/public/{,*/}*.css'],
      js: ['<%= yeoman.dist %>/public/{,*/}*.js'],
      options: {
        assetsDirs: ['<%= yeoman.dist %>/public']
      }
    },

    // Generate manifest file for offline app cache
    manifest: {
      prod: {
        options: {
          network: ['*'],
          // fallback: ['/ /offline.html'],
          // preferOnline: true,
          verbose: true,
          timestamp: true
        },
        cwd: './<%= yeoman.dist %>/public',
        src: ['*.html', '{app,assets,fonts}/**/*.{js,css,woff}'],
        dest: './<%= yeoman.dist %>/public/manifest.appcache'
      }
    },

    // Change html tag manifest attribute for offline appcache
    replace: {
      overrideAngularTranslate: {
        options: {
          patterns: [{
            match: /(\(\s*translation\s*,\s*interpolateParams\s*)\)/g,
            replacement: '$1, translationId)'
          }]
        },
        files: {
          '<%= yeoman.client %>/bower_components/angular-translate/angular-translate.js': '<%= yeoman.client %>/bower_components/angular-translate/angular-translate.js'
        }
      },
      prod: {
        options: {
          patterns: [{
            match: /<(html)>/i,
            replacement: '<$1 manifest="manifest.appcache">'
          }]
        },
        files: {
          './<%= yeoman.dist %>/public/index.html': './<%= yeoman.dist %>/public/index.html'
        }
      }
    },

    forever: {
      server: {
        options: {
          command: 'coffee',
          index: 'server/app.coffee'
        }
      }
    }
  });

  // Used for delaying livereload until after server has restarted
  grunt.registerTask('wait', function () {
    var done;
    grunt.log.ok('Waiting for server reload...');
    done = this.async();
    setTimeout(function () {
      grunt.log.writeln('Done waiting!');
      done();
    }, 1500);
  });

  grunt.registerTask('express-keepalive', 'Keep grunt running', function () {
    this.async();
  });

  grunt.registerTask('serve', 'Compile then start a connect web server', function (target) {
    if (target === 'dist') {
      return grunt.task.run([
        'build',
        'env:all',
        'env:prod',
        'express:prod',
        'wait',
        'open',
        'express-keepalive'
      ]);
    }

    grunt.task.run([
      'clean:server',
      'copy:override',
      'replace:overrideAngularTranslate',
      'env:all',
      'ngconstant',
      'injector:sass',
      'concurrent:server',
      'i18nextract',
      'injector',
      'wiredep',
      'autoprefixer',
      'express:dev',
      // 'express:dev2',
      'wait',
      'open',
      'watch'
    ]);
  });

  grunt.registerTask('build', [
    'clean:dist',
    'copy:override',
    'ngconstant',
    'injector:sass',
    'concurrent:dist',
    'injector',
    'wiredep',
    'useminPrepare',
    'autoprefixer',
    'ngtemplates',
    'concat',
    'ngAnnotate',
    'copy:dist',
    'cssmin',
    'uglify',
    'filerev',
    'usemin',
    'htmlmin',
    'manifest',
    'replace'
  ]);
};