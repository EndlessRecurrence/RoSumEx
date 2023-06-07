module Graph 

    BaseTypes = Union{Number, AbstractString, AbstractArray, AbstractDict}

    let id::Int = 0
        struct Node{T<:BaseTypes} 
            id::Int
            content::T 

            Node(content::T) where {T<:BaseTypes} = begin 
                id += 1
                new{T}(id, content)
            end
        end
    end

    struct Container{T<:BaseTypes} 
        adjacencyMap::Dict{Node{T}, Set{Int}}
        costMatrix::Union{Matrix{Float64}, Nothing}
    
        Container{T}() where {T<:BaseTypes} = new{T}(Dict{Node{T}, Set{Int}}()) 
        Container(elements::AbstractArray{T}) where {T<:BaseTypes} = begin 
            initialAdjacencyMap =
                map(element -> Node(element), elements) |> 
                elements -> foldl((acc, x) -> merge!(acc, Dict(x => Set{Int}())), elements, init=Dict())
            new{T}(initialAdjacencyMap, nothing) 
        end
        Container(elements::AbstractArray{T}, costs::Matrix{Float64}) where {T<:BaseTypes} = begin 
            if size(elements)[1] != size(costs)[1] 
                println(size(elements)[1])
                println(size(costs)[1])
                throw(ArgumentError("The sizes of the element array and the cost matrix should be equal."))
            end

            nodes = map(element -> Node(element), elements) 
            nodeIds = nodes |> xs -> map(x -> x.id, xs) |> xs -> Set(xs)

            initialAdjacencyMap =
                nodes |>
                elements -> foldl((acc, x) -> merge!(acc, Dict(x => setdiff(nodeIds, Set(x.id)))), elements, init=Dict())

            new{T}(initialAdjacencyMap, costs) 
        end
    end

    addNodeValue(graph::Container{T}, value::T) where {T<:BaseTypes} = begin 
        node = Node(value)
        graph.adjacencyMap[node] = Set{Int}()
        node
    end

    addEdge(graph::Container{T}, firstNode::Node{T}, secondNode::Node{T}) where {T<:BaseTypes} = push!(graph.adjacencyMap[firstNode], secondNode.id) 

    getNodeById(graph::Container{T}, id::Int) where {T<:BaseTypes} = begin
        keys(graph.adjacencyMap) |>
        keySet -> [keySet...] |>
        keyVector -> filter(pair -> pair.id == id, keyVector) |>
        result -> result[1]
    end

    getAllNodes(graph::Container{T}) where {T<:BaseTypes} = begin 
        keys(graph.adjacencyMap) |> 
        keySet -> [keySet...] |>
        nodes -> sort(nodes, by = (x) -> x.id)
    end

    getOutgoingNeighboursIds(graph::Container{T}, node::Node{T}) where {T<:BaseTypes} = begin 
        graph.adjacencyMap[node] |>
        set -> [set...]
    end

    getOutgoingNeighbours(graph::Container{T}, node::Node{T}) where {T<:BaseTypes} = begin 
        graph.adjacencyMap[node] |>
        set -> [set...] |>
        vector -> map(x -> Graph.getNodeById(graph, x), vector)
    end

    getIncomingNeighbours(graph::Container{T}, node::Node{T}) where {T<:BaseTypes} = begin 
        keys(graph.adjacencyMap) |>
        keySet -> [keySet...] |>
        keyVector -> filter(x -> in(node.id, Graph.getOutgoingNeighboursIds(graph, x)) == true, keyVector)
    end

    getIncomingNeighboursIds(graph::Container{T}, node::Node{T}) where {T<:BaseTypes} = begin 
        getIncomingNeighbours(graph, node) |> 
        neighbours -> map(x -> x.id, neighbours)
    end

    getIndex(nodeId, numberOfNodes) = begin
        remainder = mod(nodeId, numberOfNodes)
        if remainder == 0 numberOfNodes else remainder end
    end

    Base.show(io::IO, container::Container) = begin 
        println(string(typeof(container)) * " with " * string(length(container.adjacencyMap)) * " entries:")
        foreach(x -> println(string(x.first) * " -> " * string(x.second)), container.adjacencyMap)
    end

    export getIndex 
end