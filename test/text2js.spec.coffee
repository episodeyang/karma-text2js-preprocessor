describe 'preprocessors html2js', ->
  chai = require('chai')

  templateHelpers = require('./helpers/template_cache')
  chai.use(templateHelpers)

  expect = chai.expect

  text2js = require '../lib/text2js'
  logger =
    create: -> {debug: ->}
  process = null

  # TODO(vojta): refactor this somehow ;-) it's copy pasted from lib/file-list.js
  File = (path, mtime) ->
    @path = path
    @originalPath = path
    @contentPath = path
    @mtime = mtime
    @isUrl = false

  createPreprocessor = (config = {}) ->
    text2js logger, '/base', config

  beforeEach ->
    process = createPreprocessor()

  it 'should convert text to js code', (done) ->
    file = new File '/base/path/file.tex'
    text = '% here is a comment'

    process text, file, (processedContent) ->
      expect(processedContent)
      .to.defineModule('path/file.tex').and
      .to.defineTemplateId('path/file.tex').and
      .to.haveContent text
      done()


  it 'should change path to *.js', (done) ->
    file = new File '/base/path/file.tex'

    process '', file, (processedContent) ->
      expect(file.path).to.equal '/base/path/file.tex.js'
      done()

  it 'should not append *.js to a processed file\'s path more than once', (done) ->
    file = new File '/base/path/file.tex'

    process '', file, (processedContent) ->
      process '', file, (processedContent) ->
        expect(file.path).to.equal '/base/path/file.tex.js'
        done()

  it 'should preserve new lines', (done) ->
    file = new File '/base/path/file.tex'

    process 'first\nsecond', file, (processedContent) ->
      expect(processedContent)
      .to.defineModule('path/file.tex').and
      .to.defineTemplateId('path/file.tex').and
      .to.haveContent 'first\nsecond'
      done()


  it 'should preserve Windows new lines', (done) ->
    file = new File '/base/path/file.tex'

    process 'first\r\nsecond', file, (processedContent) ->
      expect(processedContent).to.not.contain '\r'
      done()


  it 'should preserve the backslash character', (done) ->
    file = new File '/base/path/file.tex'

    process 'first\\second', file, (processedContent) ->
      expect(processedContent)
      .to.defineModule('path/file.tex').and
      .to.defineTemplateId('path/file.tex').and
      .to.haveContent 'first\\second'
      done()


  describe 'options', ->
    describe 'stripPrefix', ->
      beforeEach ->
        process = createPreprocessor stripPrefix: 'path/'


      it 'strips the given prefix from the file path', (done) ->
        file = new File '/base/path/file.tex'
        HTML = '<html></html>'

        process HTML, file, (processedContent) ->
          expect(processedContent)
          .to.defineModule('file.tex').and
          .to.defineTemplateId('file.tex').and
          .to.haveContent HTML
          done()


    describe 'prependPrefix', ->
      beforeEach ->
        process = createPreprocessor prependPrefix: 'served/'


      it 'prepends the given prefix from the file path', (done) ->
        file = new File '/base/path/file.tex'
        HTML = '<html></html>'

        process HTML, file, (processedContent) ->
          expect(processedContent)
          .to.defineModule('served/path/file.tex').and
          .to.defineTemplateId('served/path/file.tex').and
          .to.haveContent HTML
          done()


    describe 'stripSufix', ->
      beforeEach ->
        process = createPreprocessor stripSufix: '.ext'


      it 'strips the given sufix from the file path', (done) ->
        file = new File 'file.tex.ext'
        HTML = '<html></html>'

        process HTML, file, (processedContent) ->
          expect(processedContent)
          .to.defineModule('file.tex').and
          .to.defineTemplateId('file.tex').and
          .to.haveContent HTML
          done()


    describe 'cacheIdFromPath', ->
      beforeEach ->
        process = createPreprocessor
          cacheIdFromPath: (filePath) -> "generated_id_for/#{filePath}"


      it 'invokes custom transform function', (done) ->
        file = new File '/base/path/file.tex'
        HTML = '<html></html>'

        process HTML, file, (processedContent) ->
          expect(processedContent)
          .to.defineModule('generated_id_for/path/file.tex').and
          .to.defineTemplateId('generated_id_for/path/file.tex').and
          .to.haveContent HTML
          done()

    describe 'moduleName', ->
      beforeEach ->
        process = createPreprocessor
          moduleName: 'foo'

      it 'should generate code with a given module name', ->
        file1 = new File '/base/tpl/one.html'
        HTML1 = '<span>one</span>'
        file2 = new File '/base/tpl/two.html'
        HTML2 = '<span>two</span>'
        bothFilesContent = ''

        process HTML1, file1, (processedContent) ->
          bothFilesContent += processedContent

        process HTML2, file2, (processedContent) ->
          bothFilesContent += processedContent

        # evaluate both files (to simulate multiple files in the browser)
        expect(bothFilesContent)
        .to.defineModule('foo').and
        .to.defineTemplateId('tpl/one.html').and
        .to.haveContent(HTML1).and
        .to.defineTemplateId('tpl/two.html').and
        .to.haveContent(HTML2)
