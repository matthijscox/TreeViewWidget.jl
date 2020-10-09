module TreeViewWidget
    using WebIO
    using UUIDs
    using Observables

    export TreeViewNode, TreeViewRoot, TreeView, eachnode

    # note: should not be "selected", because Jupyter already uses that
    const SELECTED_CLASS = "selected2" 

    # used by single_select_js, and by TreeView observable constructor
    const SELECTION_OBSERVABLE_NAME = "selected_node"

    include("treeview.jl")
    include("html.jl")
    include("nodeIterator.jl")
end
