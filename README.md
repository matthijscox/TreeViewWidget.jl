# TreeViewWidget.jl
A minimal TreeView widget for use in Jupyter notebooks (and maybe Blink)

## Installation

```
    julia>]add TreeViewWidget
```

## Example

Create a treeview widget from a treeview structure:
```
    tree = TreeViewRoot()
    beverages = TreeViewNode("Beverages")
    push!(beverages, TreeViewNode("Water"))
    push!(beverages, TreeViewNode("Tea"))
    push!(tree, beverages)
    push!(tree, TreeViewNode("Food"))

    treeview = TreeView(tree)
```

The elements with children are shown as collapsed nested structures. You can expand them by clicking on the `>` icon.
The text of each element can be selected. Use CTRL+Click to select multiple elements.

![example_treeview](https://raw.githubusercontent.com/matthijscox/TreeViewWidget.jl/main/figures/example_treeview.png)

The selection is available in Julia via an Observable. This is an array of dictionaries with the text label `treeview[][1]["label"]` and the identifier `treeview[][1]["id"]` which is also present in each `TreeViewNode`.
```
    julia> treeview[]
2-element Array{Dict{String,String},1}:
 Dict("label" => "Tea","id" => "654c1dbc-a4c4-42ec-9290-b27ce6165993")
 Dict("label" => "Food","id" => "8c26fdf9-9d4b-4f04-ae54-0f94ad21603c")
```

You can automatically do things whenever the user clicks something using `on` from Observables:
```
    using Observables
    h = on(treeview[]) do selected
        if !isempty(selected)
            println("The first selected label is: ", selected[1]["label"])
        end
    end
```

The TreeViewNode identifier is unique and can be used to retrieve the node from the TreeView and TreeViewRoot. Given the example above you can find the Tea Node via:
```
    treeview["654c1dbc-a4c4-42ec-9290-b27ce6165993"]
```
Or directly via one of the array elements returned by the Observable
```
    selected = treeview[]
    treeview[selected[1]]
```

You can also store data directly in each TreeViewNode, for later retrieval
```
    TreeViewNode(label = "Tea", data=5.0)
```
