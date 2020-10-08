const SELECTED_CLASS = "selected2" # note: should not be "selected", because Jupyter already uses that
const SELECTION_OBSERVABLE_NAME = "selected_node"

selected_css = """
.$SELECTED_CLASS {
  background: rgb(0, 209, 178);
  color: white;
  padding: 2px;
}

.selectable {
  cursor: pointer;
}
"""

single_select_js = js"""
function() {
  let selected = document.getElementsByClassName("selectable");
  for(let elem of selected) {
      elem.classList.remove($SELECTED_CLASS);
  }
  this.classList.add($SELECTED_CLASS);
  _webIOScope.setObservableValue('selected_node', {'text':this.innerText, 'id':this.id});
}
"""
selected_style = node(:style, selected_css)

nested_css = """
/* Create the caret/arrow with a unicode, and style it */
.caret-start {
  display: inline-block;
  margin-right: 6px;
  cursor: pointer;
}

.caret-down {
  transform: rotate(90deg);
}

/* Hide the nested list */
.nested {
  list-style-type:none;
  display: none;
}

/* Show the nested list when the user clicks on the caret/arrow (with JavaScript) */
.active {
  display: block;
}
"""
nested_style = node(:style, nested_css)

toggle_nested_js = js"""
function() {
    this.parentElement.querySelector(".nested").classList.toggle("active");
    this.classList.toggle("caret-down");
}
"""

function visible_list(text_array::Vector{<:AbstractString})
    list_elements = [node(:li, text) for text in text_array]
    return a_list(list_elements)
end

function nested_list(text_array::Vector{<:AbstractString})
    list_elements = [selectable_list_element(text) for text in text_array]
    return nested_list(list_elements)
end

function nested_list(list_elements::Array{<:Node})
    return dom"""ul.nested[style=$("list-style-type:none")]"""(list_elements...)
end

caret_element() = dom"""span.caret-start"""(dom"b"(">"), events=Dict("click" => toggle_nested_js))

function selectable_text_node(text::String, id::String = string(UUIDs.uuid4()))
    return node(
            :span, 
            text,
            className="selectable",
            id=id,
            events=Dict("click" => single_select_js)
            )
end

function selectable_list_element(text::String, id::String = string(UUIDs.uuid4()))
    return dom"""li[style=$("cursor:auto")]"""(selectable_text_node(text, id))
end

function nested_selectable_list(text_array::Vector{<:AbstractString})
    list_elements = [selectable_list_element(text) for text in text_array]
    return nested_list(list_elements)
end

function selectable_list(text_array::Array{<:AbstractString})
    list_elements = [selectable_list_element(text) for text in text_array]
    return a_list(list_elements)
end

function a_list(list_elements::Array{<:Node})
    return dom"""ul[style=$("list-style-type:none")]"""(list_elements...)
end

function selectable_element_with_list(text::String, list)
    return dom"""li[style=$("cursor:auto")]"""(caret_element(), selectable_text_node(text), list)
end

function create_scope(treeview::Node)
    return Scope(dom = Node(:div, nested_style, selected_style, treeview))
end

function tohtml(node::TreeViewNode)
    return selectable_list_element(node.text, node.id)
end