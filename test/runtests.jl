#!/usr/bin/env julia
using Test
using TreeViewWidget
using WebIO

@testset "TreeViewWidget.jl" begin

    function test_text_node_html(tree_node::TreeViewWidget.AbstractTreeViewNode, html::Node)
        # <span id=tree_node.id>tree_node.label</span>
        @test html.instanceof.tag == :span
        @test html.props[:id] == tree_node.id
        @test html.children[1] == tree_node.label
    end

    function test_node_html(tree_node::TreeViewWidget.AbstractTreeViewNode, html::Node)
        # <li>
        #   <span id=tree_node.id>tree_node.label</span>
        # </li>
        @test html.instanceof.tag == :li
        test_text_node_html(tree_node, html.children[1])
    end

    function test_nested_node_html(tree_node::TreeViewWidget.AbstractTreeViewNode, html::Node)
        # <li>
        #   <span class="caret-start"></span>
        #   <span id=tree_id>label</span>
        #   <ul class="nested">children</ul>
        # </li>
        @test html.instanceof.tag == :li
        @test length(html.children) == 3
        test_text_node_html(tree_node, html.children[2])
        nested_list = html.children[3].children
        tree_node_children = tree_node.children
        @test length(nested_list) == length(tree_node_children)
        for (child_node, html_element) in zip(tree_node_children, nested_list)
            if isempty(child_node.children)
                test_node_html(child_node, html_element)
            else
                test_nested_node_html(child_node, html_element)
            end
        end
    end

    function test_example_root_html(root::TreeViewWidget.TreeViewRoot, html::Node)
        # <ul>
        #   <li>...beverages with children... coffee with children...</li>
        #   <li>...meat with children...</li>
        #   <li>...vegetables...</li>
        # </ul>
        @test html isa Node
        @test html.instanceof.tag == :ul
        @test length(html.children) == 3
        @test html.children[1].instanceof.tag == :li
        test_nested_node_html(root.nodes[1], html.children[1])
        test_nested_node_html(root.nodes[2], html.children[2])
        test_node_html(root.nodes[3], html.children[3])
    end

    @testset "TreeViewNode" begin
        tree_node = TreeViewNode("foo")
        @test tree_node.label == "foo"
        @test !isempty(tree_node.id)

        tree_child = TreeViewNode("bar")
        push!(tree_node, tree_child)
        @test first(tree_node.children) == tree_child
    end

    @testset "TreeViewRoot" begin
        root = TreeViewRoot()
        push!(root, TreeViewNode("foo"))
        push!(root, TreeViewNode("bar"))
        @test length(root.nodes) == 2
    end

    @testset "ChildlessNodeToHTML" begin
        tree_node = TreeViewNode("foo")
        html = TreeViewWidget.tohtml(tree_node)
        @test html isa Node
        @test length(html.children) == 1
        test_node_html(tree_node, html)
    end

    @testset "NestedNodeToHTML" begin
        tree_node = TreeViewNode("parent_node")
        push!(tree_node, TreeViewNode("child1"))
        push!(tree_node, TreeViewNode("child2"))
        nr_tree_children = length(tree_node.children)

        html = TreeViewWidget.tohtml(tree_node)
        @test html isa Node
        test_nested_node_html(tree_node, html)
    end

    @testset "DoubleNestedNodeToHTML" begin
        tree_node = TreeViewNode("parent_node")
        push!(tree_node, TreeViewNode("child1"))
        child2 = TreeViewNode("child2")
        push!(tree_node, child2)
        push!(child2, TreeViewNode("grandchild1"))
        push!(child2, TreeViewNode("grandchild2"))
        nr_tree_children = length(tree_node.children)

        html = TreeViewWidget.tohtml(tree_node)
        @test html isa Node
        test_nested_node_html(tree_node, html)

        # explicitly test the 2nd level again to be sure, recursiveness can be difficult
        test_nested_node_html(tree_node.children[2], html.children[3].children[2])
    end

    @testset "TreeviewRootToHTML" begin
        root = TreeViewWidget.example_treeview_root()
        html = TreeViewWidget.tohtml(root)
        test_example_root_html(root, html)
    end

    @testset "TreeView" begin
        example_root = TreeViewWidget.example_treeview_root()
        treeview = TreeView(example_root)
        test_example_root_html(example_root, treeview.scope.dom.children[end])

        # Observerable behavior as used in Interact.jl etc
        @test treeview[] == treeview.selection
    end

end
