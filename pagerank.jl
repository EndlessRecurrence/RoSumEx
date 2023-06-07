module PageRank 
    include("graph.jl")

    function getIndex(nodeId, numberOfNodes)
        remainder = mod(nodeId, numberOfNodes)
        if remainder == 0 numberOfNodes else remainder end
    end

    function computeSum(graph, sourceNode, prValues, costMatrix=nothing)
        incomingNeighboursIds = Graph.getIncomingNeighboursIds(graph, sourceNode)
        nodes = Graph.getAllNodes(graph)
        scaledNeighbourRanks =
            map(nodeId -> begin 
                node = Graph.getNodeById(graph, nodeId)
                outgoingNeighbours = Graph.getOutgoingNeighboursIds(graph, node)
                valueContainerIndex = findall(x -> x === node, nodes)[1]
                if costMatrix === nothing 
                    prValues[valueContainerIndex] / length(outgoingNeighbours)
                else 
                    i = getIndex(sourceNode.id, length(nodes))
                    j = getIndex(nodeId, length(nodes))
                    numerator = costMatrix[j, i] * prValues[valueContainerIndex]
                    denominator = sum(x -> costMatrix[j, getIndex(x, length(nodes))], outgoingNeighbours)
                    numerator / denominator
                end
            end, incomingNeighboursIds)
        if length(scaledNeighbourRanks) > 0 sum(scaledNeighbourRanks) else 0 end
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
    function run(graph::Graph.Container, costMatrix=nothing, alpha::Float64=0.85, epsilon::Float64=1e-6, iterations::Int64=-1) 
        nodes = Graph.getAllNodes(graph)
        numberOfNodes = length(nodes)
        oldPrValues, newPrValues = ones(numberOfNodes), zeros(numberOfNodes)
        epsilonVector = fill(epsilon, numberOfNodes)
        iterationIndex = 0

        while true
            for nodeIndex = 1:numberOfNodes 
                sumOfRanks = nodes[nodeIndex] |> u -> computeSum(graph, u, oldPrValues, costMatrix)
                newPrValues[nodeIndex] = (1 - alpha) / numberOfNodes + alpha * sumOfRanks
            end

            if (iterations == -1 && abs.(newPrValues .- oldPrValues) < epsilonVector) || (iterationIndex == iterations)
                break
            end
            
            iterationIndex += 1
            oldPrValues, newPrValues = newPrValues, oldPrValues
        end 

        scaledValues = newPrValues / minimum(newPrValues)
        finalRanks = scaledValues / sum(scaledValues)
        zip(nodes, finalRanks) |> 
            collect |>
            pairs -> sort(pairs, by = (x) -> x[2], rev=true)
    end

    export run
end