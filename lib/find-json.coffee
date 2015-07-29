FindJsonListView = require './find-json-list-view'
{CompositeDisposable} = require 'atom'

module.exports = FindJson =
  subscriptions: null

  config:
    maxDepth:
      type: 'integer'
      default: 6

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'find-json:show': => @show(isResultFlatten: false)
    @subscriptions.add atom.commands.add 'atom-workspace', 'find-json:show-result-flatten': => @show(isResultFlatten: true)

  deactivate: ->
    @subscriptions.dispose()

  show: ({isResultFlatten} = {isResultFlatten: true})->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    text = editor.getText()

    try
      object = JSON.parse(text)
    catch error
      return console.error(error)

    findJsonListView = new FindJsonListView(object, isResultFlatten)
