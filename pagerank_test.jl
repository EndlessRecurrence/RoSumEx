module PageRankTest  
    include("pagerank.jl")
    using .PageRank

    function testCostFreePageRank_withIterations() 
        println("Running testCostFreePageRank_withIterations...")
        graph = PageRank.Graph.Container([123, 456, 789])
        nodes = PageRank.Graph.getAllNodes(graph)
        PageRank.Graph.addEdge(graph, nodes[1], nodes[2])
        PageRank.Graph.addEdge(graph, nodes[1], nodes[3])
        PageRank.Graph.addEdge(graph, nodes[2], nodes[3])
        ranks = PageRank.run(graph, 0.85, 1e-6, 100)
        @assert [0.1975796492961225, 0.28155100024697455, 0.520869350456903] == ranks
        println("Test testCostFreePageRank_withIterations passed.")
    end

    function testCostFreePageRank_withEpsilonConvergence() 
        println("Running testCostFreePageRank_withEpsilonConvergence...")
        graph = PageRank.Graph.Container([123, 456, 789])
        nodes = PageRank.Graph.getAllNodes(graph)
        PageRank.Graph.addEdge(graph, nodes[1], nodes[2])
        PageRank.Graph.addEdge(graph, nodes[1], nodes[3])
        PageRank.Graph.addEdge(graph, nodes[2], nodes[3])
        ranks = PageRank.run(graph)
        @assert [0.0838574423480084, 0.11949685534591196, 0.7966457023060797] == ranks
        println("Test testCostFreePageRank_withEpsilonConvergence passed.")
    end

    function runTests()
        println("Running tests...")
        testCostFreePageRank_withIterations()
        testCostFreePageRank_withEpsilonConvergence()
        println("All tests passed.")
    end

    export runTests
end