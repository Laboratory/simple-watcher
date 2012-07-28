#test comment
utils = {
    addEvent: (element, eventName, callback) ->
        element.addEventListener eventName, callback
    $: (id) ->
        document.getElementById id
}

utils.addEvent window, 'load', ->
    node = utils.$ 'container'
    node.innerHTML = "Change test from Coffee code by simple-watcher"
    generateList(node)

generateList =(node) ->
  return unless node
  content = []
  for index in [0..10]
    content.push "<div>#{index}</div>"
  node.innerHTML += content.join("")
