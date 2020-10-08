#!/usr/bin/env julia
using Test
using TreeViewWidget
using WebIO

@testset "TreeViewWidget.jl" begin

    @testset "TreeViewNode" begin
        tree_node = TreeViewNode("foo")
        @test tree_node.text == "foo"
        @test !isempty(tree_node.id)

        tree_child = TreeViewNode("bar")
        push!(tree_node, tree_child)
        @test first(tree_node.children) == tree_child
    end

    @testset "ChildlessNodeToHTML" begin
        tree_node = TreeViewNode("foo")
        html = TreeViewWidget.tohtml(tree_node)
        @test html isa Node
        @test length(html.children) == 1
        @test html.children[1].props[:id] == tree_node.id
        @test html.children[1].children[1] == tree_node.text
    end

    @testset "TreeViewRoot" begin
        root = TreeViewRoot()
        push!(root, TreeViewNode("foo"))
        push!(root, TreeViewNode("bar"))
        @test length(root.nodes) == 2
    end

    @testset "TreeView" begin
        treeview = TreeView(TreeViewWidget.example_treeview_root())
    end

end
