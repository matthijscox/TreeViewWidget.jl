#!/usr/bin/env julia
using Test
using TreeViewWidget
using WebIO

@testset "TreeViewWidget.jl" begin

    function test_node_html(tree_node::TreeViewWidget.AbstractTreeViewNode, html::Node)
        # <li>
        #   <span id=tree_node.id>tree_node.label</span>
        # </li>
        @test html.children[1].props[:id] == tree_node.id
        @test html.children[1].children[1] == tree_node.label
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
        @test length(html.children) == 3

        # <li>
        #   <span class="caret-start"></span>
        #   <span id=tree_id>label</span>
        #   <ul class="nested">children</ul>
        # </li>
        test_node_html(tree_node, html.children[2])
        nested_list = html.children[3].children
        @test length(nested_list) == nr_tree_children
        for n=1:nr_tree_children
            test_node_html(tree_node.children[n], nested_list[n])
        end
    end

    @testset "TreeviewToHTML" begin
        treeview = TreeView(TreeViewWidget.example_treeview_root())
    end

end
