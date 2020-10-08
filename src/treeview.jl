

struct TreeViewNode
    id::String
    text::String
    children::Vector{TreeViewNode}
end

"""
    TreeViewNode(::String)

Create a TreeViewNode
"""
function TreeViewNode(text::String) 
    TreeViewNode(string(UUIDs.uuid4()), text, TreeViewNode[])
end
children(node::TreeViewNode) = node.children

Base.push!(parent::TreeViewNode, child::TreeViewNode) = push!(children(parent), child)
    
"""
    TreeView(::String)

Create a TreeView for use as content of a TreeViewWidget

# Examples

Create a TreeView
```
    tree = TreeView()
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
    nodes::AbstractArray{TreeViewNode}
end
TreeViewRoot() = TreeViewRoot(TreeViewNode[])

Base.push!(tree::TreeViewRoot, node::TreeViewNode) = push!(tree.nodes, node)

function example_treeview_root()
    tree = TreeViewRoot()
    beverages = TreeViewNode("Beverages")
    push!(tree, beverages)
    push!(beverages, TreeViewNode("Water"))
    push!(beverages, TreeViewNode("Tea"))
    push!(beverages, TreeViewNode("Coffee"))
    food = TreeViewNode("Food")
    push!(tree, food)
    push!(food, TreeViewNode("Vegetable"))
    push!(food, TreeViewNode("Meat"))
    return tree
end

struct TreeView
    content::TreeViewRoot
    selection::Observable
    scope::Scope
end
function TreeView(content::TreeViewRoot)
    treeview_html = node(:p, "I'm a tree!")
    treeview_scope = create_scope(treeview_html)
    obs = Observable(treeview_scope, SELECTION_OBSERVABLE_NAME, Dict{String, String}())
end

