Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'
unflatten = require('flat').unflatten
flatten = require 'flat'
{SelectListView} = require 'atom-space-pen-views'

tempFilePath = Path.join Os.tmpDir(), "find-json-view.json"

module.exports =
class FindJsonListView extends SelectListView
  initialize: (originalJson) ->
    super
    @flattenJson = @makeFlattenJson(originalJson)
    @setItems(@makeItems(@flattenJson))
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  viewForItem: (pathName) ->
    "<li>#{pathName}.*</li>"

  hide: -> @panel?.hide()

  confirmed: (pathName) ->
    @showResult(@filterItems(pathName))
    console.log("#{pathName} was selected")
    @hide()

  cancelled: ->
    console.log("This view was cancelled")
    @hide()

  # private ...

  makeFlattenJson: (originalJson) ->
    maxDepth = atom.config.get("find-json.maxDepth")
    options = {}
    if maxDepth != -1
      options.maxDepth = maxDepth
    flattenJson = flatten(originalJson, options)
    return flattenJson

  makeItems: (flattenJson) ->
    items = []
    for pathName in Object.keys(flattenJson)
      pathList = pathName.split(".")
      name = null
      for path in pathList
        name = if name then [name, path].join(".") else path
        if name not in items
          items.push(name)
    items.sort()
    return items

  filterItems: (pathName) ->
    String::startsWith ?= (s) -> @[...s.length] is s
    items = {}
    for key, value of @flattenJson
      if key.startsWith(pathName)
        items[key] = value
    return items

  showResult: (items) ->
    isConvertFlattenJson = atom.config.get("find-json.convertFlattenJson")
    if isConvertFlattenJson
      items = flatten(items)
    else
      items = unflatten(items)
    text = JSON.stringify(items, null, 2)
    fs.writeFileSync(tempFilePath, text, flag: 'w+')
    atom.workspace.open(tempFilePath, split: 'right', activatePane: true)
