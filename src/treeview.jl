
abstract type AbstractTreeViewNode end
struct TreeViewNode <: AbstractTreeViewNode
    id::String
    label::String
    children::Vector{TreeViewNode}
end
label(t::TreeViewNode) = t.label
tree_id(t::TreeViewNode) = t.id
children(t::TreeViewNode) = t.children

"""
    TreeViewNode(::String)

Create a TreeViewNode
"""
function TreeViewNode(text::String) 
    TreeViewNode(string(UUIDs.uuid4()), text, TreeViewNode[])
end

Base.push!(parent::TreeViewNode, child::TreeViewNode) = push!(children(parent), child)
    
"""
TreeViewRoot(::String)

Create a TreeViewRoot for use as content in a TreeView widget

# Examples

Create a TreeViewRoot
```
    tree = TreeViewRoot()
    beverages = TreeViewNode("Beverages")
    push!(tree, beverages)
    push!(tree, TreeViewNode("Food"))
```
And push some children into a node if you want
```
    push!(beverages, TreeViewNode("Water"))
    push!(beverages, TreeViewNode("Tea"))
    push!(beverages, TreeViewNode("Coffee"))
```

"""
struct TreeViewRoot
    nodes::AbstractArray{<:AbstractTreeViewNode}
end
TreeViewRoot() = TreeViewRoot(TreeViewNode[])

Base.push!(tree::TreeViewRoot, node::TreeViewNode) = push!(tree.nodes, node)

function example_treeview_root()
    tree = TreeViewRoot()

    beverages = TreeViewNode("Beverages")
    push!(tree, beverages)
    push!(beverages, TreeViewNode("Water"))
    push!(beverages, TreeViewNode("Tea"))

    coffee = TreeViewNode("Coffee")
    push!(beverages, coffee)
    push!(coffee, TreeViewNode("Espresso"))
    push!(coffee, TreeViewNode("Cappuccino"))

    meat = TreeViewNode("Meat")
    push!(tree, meat)
    push!(meat, TreeViewNode("Chicken"))
    push!(meat, TreeViewNode("Steak"))
    
    vegetables = TreeViewNode("Vegetables")
    push!(tree, vegetables)

    return tree
end

struct TreeView
    content::TreeViewRoot
    selection::Observable
    scope::Scope
end

"""
TreeView(::TreeViewRoot)

Create a TreeView widget from a TreeViewRoot structure

# Examples

Create a TreeView
```
    tree = TreeViewRoot()
    beverages = TreeViewNode("Beverages")
    push!(beverages, TreeViewNode("Water"))
    push!(beverages, TreeViewNode("Tea"))
    push!(tree, beverages)
    push!(tree, TreeViewNode("Food"))

    treeview = TreeView(tree)
```
To get the Observable selection of elements:
```
    treeview[]
```
"""
function TreeView(content::TreeViewRoot)
    treeview_scope = create_scope(tohtml(content))
    obs = Observable(treeview_scope, SELECTION_OBSERVABLE_NAME, Dict{String, String}())
    return TreeView(content, obs, treeview_scope)
end

# standard behavior of widgets: get the observable via the getindex: treeview[]
Base.getindex(tv::TreeView) = tv.selection

Base.show(io::IO, x::TreeView) = show(io, x.scope)
Base.show(io::IO, m::MIME"text/html", x::TreeView) = show(io, m, x.scope)
#Base.display(w::TreeView) = display(render(w))

