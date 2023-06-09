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
        rankNodePairs = PageRank.run(graph, nothing, 0.85, 1e-6, 100)
        ranks = map(pair -> pair[2], rankNodePairs)
        @assert [0.520869350456903, 0.28155100024697455,0.1975796492961225] == ranks
        println("Test testCostFreePageRank_withIterations passed.")
    end

    function testCostFreePageRank_withEpsilonConvergence() 
        println("Running testCostFreePageRank_withEpsilonConvergence...")
        graph = PageRank.Graph.Container([123, 456, 789])
        nodes = PageRank.Graph.getAllNodes(graph)
        PageRank.Graph.addEdge(graph, nodes[1], nodes[2])
        PageRank.Graph.addEdge(graph, nodes[1], nodes[3])
        PageRank.Graph.addEdge(graph, nodes[2], nodes[3])
        rankNodePairs = PageRank.run(graph)
        ranks = map(pair -> pair[2], rankNodePairs)
        @assert [0.7966457023060797, 0.11949685534591196, 0.0838574423480084] == ranks
        println("Test testCostFreePageRank_withEpsilonConvergence passed.")
    end

    function testCostBasedPageRank_withIterations() 
        println("Running testCostBasedPageRank_withIterations...")
        costMatrix = [1 0.5 0.3;
                      0.2 1 0.45;
                      0.75 0.12 1]         
        graph = PageRank.Graph.Container([123, 456, 789], costMatrix)
        rankNodePairs = PageRank.run(graph, costMatrix, 0.85, 1e-6, 100)
        ranks = map(pair -> pair[2], rankNodePairs)
        @assert [0.3734036821457481, 0.3385352707437439, 0.28806104711050806] == ranks
        println("Test testCostBasedPageRank_withIterations passed.")
    end

    function testCostBasedPageRank_withEpsilonConvergence() 
        println("Running testCostBasedPageRank_withEpsilonConvergence...")
        costMatrix = [1 0.5 0.3;
                      0.2 1 0.45;
                      0.75 0.12 1]         
        graph = PageRank.Graph.Container([123, 456, 789], costMatrix)
        rankNodePairs = PageRank.run(graph, costMatrix)
        ranks = map(pair -> pair[2], rankNodePairs)
        @assert [0.37340375489921773, 0.3385352646595182, 0.2880609804412642] == ranks
        println("Test testCostBasedPageRank_withEpsilonConvergence passed.")
    end

    function runTests()
        println("Running PageRank tests...")
        testCostFreePageRank_withIterations()
        testCostFreePageRank_withEpsilonConvergence()
        testCostBasedPageRank_withIterations()
        testCostBasedPageRank_withEpsilonConvergence()
        println("All PageRank tests passed.")
    end

    export runTests
end