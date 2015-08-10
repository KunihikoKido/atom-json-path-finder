Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'
unflatten = require('flat').unflatten
flatten = require 'flat'
{SelectListView} = require 'atom-space-pen-views'

tempFilePath = Path.join Os.tmpDir(), "find-json-view.json"

module.exports =
class FindPathListView extends SelectListView
  initialize: (objct, @isResultFlatten) ->
    super
    @isFlatten ?= true
    @flattenJson = @makeFlattenJson(objct)
    @setItems(@makeItems(@flattenJson))
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  viewForItem: (pathName) ->
    "<li>#{pathName}</li>"

  hide: -> @panel?.hide()

  confirmed: (pathName) ->
    @showResult(@filterItems(pathName))
    @hide()

  cancelled: ->
    @hide()

  # private ...

  makeFlattenJson: (objct) ->
    maxDepth = atom.config.get("json-path-finder.maxDepth")
    options = {}
    if maxDepth != -1
      options.maxDepth = maxDepth
    flattenJson = flatten(objct, options)
    return flattenJson

  makeItems: (flattenJson) ->
    Array::unique = ->
      output = {}
      output[@[key]] = @[key] for key in [0...@length]
      value for key, value of output

    items = []
    for pathName in Object.keys(flattenJson)
      pathName = pathName.replace(/\.[0-9]+/g, "[]")
      items.push(pathName)
    items.sort()
    items = items.unique()
    return items

  filterItems: (pathName) ->
    items = {}
    for key, value of @flattenJson
      if pathName == key.replace(/\.[0-9]+/g, "[]")
        items[key] = value
    return items

  showResult: (items) ->
    flattenFunc = if @isResultFlatten then flatten else unflatten
    text = JSON.stringify(flattenFunc(items), null, 2)
    fs.writeFileSync(tempFilePath, text, flag: 'w+')
    atom.workspace.open(tempFilePath, split: 'right', activatePane: true)
