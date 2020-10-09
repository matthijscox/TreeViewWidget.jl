struct NodeIterator
    iter
end

Iterators.IteratorSize(::NodeIterator) = Iterators.SizeUnknown()
Base.iterate(x::NodeIterator, args...) = iterate(x.iter, args...)

function eachnode(tree)
    return NodeIterator(node_iterator(tree))
end

node_iterator(node::AbstractTreeViewNode) = Iterators.flatten(((node,), child_node_iterator(node)))
child_node_iterator(node::AbstractTreeViewNode) = Iterators.flatten(node_iterator(x) for x in children(node))

node_iterator(tree::TreeViewRoot) = Iterators.flatten(node_iterator(x) for x in tree.nodes)
node_iterator(treeview::TreeView) = node_iterator(treeview.content)

function find_by_id(tree::TreeViewRoot, id::String)
    for node in eachnode(tree)
        if tree_id(node)==id
            return node
        end
    end
    return nothing
end

Base.getindex(tree::TreeViewRoot, id::String) = find_by_id(tree, id)
Base.getindex(treeview::TreeView, id::String) = find_by_id(treeview.content, id)

Base.getindex(tree::TreeViewRoot, d::Dict{String, String}) = find_by_id(tree, d["id"])
Base.getindex(treeview::TreeView, d::Dict{String, String}) = find_by_id(treeview.content, d["id"])