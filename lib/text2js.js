var util = require('util');

var PRIMITIVE_TPL = '' +
    'window.__templates__ = window.__templates__ || {};\n' +
    'window.__templates__[\'%s\'] = \'%s\';\n';

var SINGLE_PRIMITIVE_TPL = '' +
    'window[\'%s\'] = window[\'%s\'] || {};\n' +
    'window[\'%s\'] = \'%s\';\n';

var TEMPLATE = 'angular.factory(\'%s\', function() {\n' +
    '    return \'%s\';\n' +
    '});\n';

var SINGLE_MODULE_TPL =
    '(function(module) {\n' +
    'try {\n' +
    '    module = angular.module(\'%s\');\n' +
    '} catch (e) {\n' +
    '    module = angular.module(\'%s\', []);\n' +
    '}\n' +
    'module.factory(\'%s\', function() {\n' +
    '    return \'%s\';\n' +
    '});\n' +
    '})();\n';

var escapeContent = function (content) {
    return content.replace(/\\/g, '\\\\').replace(/'/g, '\\\'').replace(/\r?\n/g, '\\n\' +\n    \'');
};

var text2JsPreprocessor = function (logger, basePath, config) {
    config = typeof config === 'object' ? config : {};

    var log = logger.create('preprocessor.text2js');
    var moduleName = config.moduleName;
    // angularMode default is true;
    var angularMode = config.angularMode || true;
    var stripPrefix = new RegExp('^' + (config.stripPrefix || ''));
    var prependPrefix = config.prependPrefix || '';
    var stripSufix = new RegExp((config.stripSufix || '') + '$');
    var cacheIdFromPath = config && config.cacheIdFromPath || function (filepath) {
            return prependPrefix + filepath.replace(stripPrefix, '').replace(stripSufix, '');
        };

    return function (content, file, done) {
        log.debug('Processing "%s".', file.originalPath);

        var textPath = cacheIdFromPath(file.originalPath.replace(basePath + '/', ''));

        if (!/\.js$/.test(file.path)) {
            file.path = file.path + '.js';
        }

        if (angularMode && moduleName) {
            done(util.format(SINGLE_MODULE_TPL, moduleName, moduleName, textPath, escapeContent(content)));
        } else if (angularMode && !moduleName) {
            done(util.format(TEMPLATE, textPath, textPath, escapeContent(content)));
        } else if (!angularMode && moduleName) {
            done(util.format(SINGLE_PRIMITIVE_TPL, textPath, textPath, textPath, escapeContent(content)));
        } else if (!angularMode && !moduleName) {
            done(util.format(PRIMITIVE_TPL, textPath, escapeContent(content)));
        }
    };
};

text2JsPreprocessor.$inject = ['logger', 'config.basePath', 'config.html2JsPreprocessor'];

module.exports = text2JsPreprocessor;
