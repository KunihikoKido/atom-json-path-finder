FindJsonListView = require './find-json-list-view'
{CompositeDisposable} = require 'atom'

module.exports = FindJson =
  findJsonView: null
  modalPanel: null
  subscriptions: null

  config:
    maxDepth:
      type: 'integer'
      default: 6
    convertFlattenJson:
      type: 'boolean'
      default: true

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'find-json:show': => @show()

  deactivate: ->
    @subscriptions.dispose()

  show: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    text = editor.getText()

    try
      jsonObject = JSON.parse(text)
    catch error
      return console.error(error)

    findJsonListView = new FindJsonListView(jsonObject)
