module PageRank 
    include("graph.jl")

    function costFreeVariant(graph::Graph.Container, alpha::Float64, epsilon::Float64, iterations::Int64)
        nodes = Graph.getAllNodes(graph)
        numberOfNodes = length(nodes)
        oldPrValues, newPrValues = ones(numberOfNodes), zeros(numberOfNodes)
        epsilonVector = fill(epsilon, numberOfNodes)
        iterationIndex = 0

        while true
            for nodeIndex = 1:numberOfNodes 
                u = nodes[nodeIndex]
                Bu = Graph.getIncomingNeighboursIds(graph, u) 
                scaledNeighbourRanks =
                    map(nodeId -> begin 
                        node = Graph.getNodeById(graph, nodeId)
                        outgoingNeighbours = Graph.getOutgoingNeighboursIds(graph, node)
                        valueContainerIndex = findall(x -> x === node, nodes)[1]
                        oldPrValues[valueContainerIndex] / length(outgoingNeighbours)
                    end, Bu)
                sumOfRanks = if length(scaledNeighbourRanks) > 0 sum(scaledNeighbourRanks) else 0 end
                newPrValues[nodeIndex] = (1 - alpha) / numberOfNodes + alpha * sumOfRanks
            end

            if (iterations == -1 && abs.(newPrValues .- oldPrValues) < epsilonVector) || (iterationIndex == iterations)
                break
            end
            
            iterationIndex += 1
            oldPrValues, newPrValues = newPrValues, oldPrValues
        end 

        scaledValues = newPrValues / minimum(newPrValues)
        scaledValues / sum(scaledValues)
    end 


    function costBasedVariant()

    end


    """
        Description:
            The function computes the PageRank rankings indicating the level of relevance/importance
            of the nodes within the given graph, based on the incoming/outgoing edges of the graph.

        Parameters:
            graph :: Graph.Container -> The graph on which the PageRank algorithm is executed
            alpha :: Float64         -> The damping factor representing the probability that, at 
                                        any step, the "random surfer" will continue following links.
                                        It is set to 0.85 by default.
            epsilon :: Float64       -> The error approximation which determines whether the algorithm
                                        stops or continues. Once |Pr(t)-Pr(t-1)| < ε, the algorithm stops
                                        and convergence is assumed.
    """
    function run(graph::Graph.Container, alpha::Float64=0.85, epsilon::Float64=1e-6, iterations::Int64=-1) 
        costFreeVariant(graph, alpha, epsilon, iterations) 
    end

    export run
end