module ApplicationHelper
  def editor(partial, options = {})
    top = '<a href="#" id="show-editor">Show Editor</a><div id="editor">'
    bottom = '</div>'
    top.html_safe << render(partial, options) << bottom.html_safe
  end
end
