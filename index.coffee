stratus = require 'stratus'
fractus = require 'fractus'
ui      = require 'stratus-ui'

# Internal: Create a GitHub Gist.
# 
# text     - String
# public   - Boolean
# callback - Receives `(response)`, which is an obejct
#            like the one described at
#            <http://developer.github.com/v3/gists/#response-2>
# 
gist = (filename, text, public, callback) ->
  files           = {}
  files[filename] = {content: text}
  $.post "https://api.github.com/gists", JSON.stringify({public, files})
  , (data, status, xhr) ->
    callback data


# Internal: Use the current selection to create a Gist, then
# display it in a dialog.
# 
# public - (Boolean)
# 
gistSelection = (public) ->
  editor   = fractus.current
  parts    = editor.path.split "/"
  filename = parts[parts.length - 1]
  if editor.cursor.region
    text = editor.cursor.region.text()
  else
    text = editor.text()
  
  gist filename, text, public, (res) ->
    url = res.html_url
    showUrl url


# Internal: Display the given URL in a dialog.
# 
# url - (String)
# 
showUrl = (url) ->
  $url = $ "<input/>",
    type:     "text"
    value:    url
    readonly: true
  $container = $ """
      <div class="selection-to-gist">
        <a class="symbol" href="#{url}" target="_blank" title="Open Gist in new tab">K</a>
      </div>
    """
  $container.prepend $url
  ui.dialog "Gist", $container, {draggable: true}
  $url.mouseup -> $url.select()
  $url.select()


# Add toolbar items:
# 
#   * Tools > Gist
#   * Tools > Gist > Private
#   * Tools > Gist > Public
# 
jQuery ($) ->
  stratus.ui.toolbar.Tools.append
    text: "Gist"
    actions: [
      { text: "Private", click: -> gistSelection false }
      { text: "Public",  click: -> gistSelection true }
    ]
