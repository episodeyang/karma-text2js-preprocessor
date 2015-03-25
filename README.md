# karma-text2js-preprocessor

> Preprocessor for converting text files to javascript strings.

## Installation

The easiest way is to keep `karma-text2js-preprocessor` as a devDependency in your `package.json`.
```json
{
  "devDependencies": {
    "karma": "~0.10",
    "karma-text2js-preprocessor": "~0.1"
  }
}
```

You can simple do it by:
```bash
npm install karma-text2js-preprocessor --save-dev
```

## Configuration
```js
// karma.conf.js
module.exports = function(config) {
  config.set({
    preprocessors: {
      '**/*.html': ['text2js']
    },

    files: [
      '*.js',
      '*.html',
      '*.html.ext',
      // if you wanna load template files in nested directories, you must use this
      '**/*.html'
    ],

    text2JsPreprocessor: {
      // strip this from the file path
      stripPrefix: 'public/',
      stripSufix: '.ext',
      // prepend this to the
      prependPrefix: 'served/',

      // or define a custom transform function
      cacheIdFromPath: function(filepath) {
        return cacheId;
      },

      // in angular mode, angular modules are created
      angularMode: true,
      // setting this option will create only a single module that contains templates
      // from all the files, so you can load them all with module('foo')
      moduleName: 'foo'
    }
  });
};
```

----

For more information on Karma see the [homepage].


[homepage]: http://karma-runner.github.com
