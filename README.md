# TreeViewWidget.jl
A minimal TreeView widget for use in Jupyter notebooks (and maybe Blink)

## Installation

```
    julia>]add TreeViewWidget
```

## Example

Create a treeview widget from a treeview structure
```
    tree = TreeViewRoot()
    beverages = TreeViewNode("Beverages")
    push!(beverages, TreeViewNode("Water"))
    push!(beverages, TreeViewNode("Tea"))
    push!(tree, beverages)
    push!(tree, TreeViewNode("Food"))

    treeview = TreeView(tree)
```

Select something and see the observable result
```
    treeview[]
```