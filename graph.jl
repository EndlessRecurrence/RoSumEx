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
    
        Container{T}() where {T<:BaseTypes} = new{T}(Dict{Node{T}, Set{Int}}()) 
        Container(elements::AbstractArray{T}) where {T<:BaseTypes} = begin 
            initialAdjacencyMap =
                map(element -> Node(element), elements) |> 
                elements -> foldl((acc, x) -> merge!(acc, Dict(x => Set{Int}())), elements, init=Dict())
            new{T}(initialAdjacencyMap) 
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

    Base.show(io::IO, container::Container) = begin 
        println(string(typeof(container)) * " with " * string(length(container.adjacencyMap)) * " entries:")
        foreach(x -> println(string(x.first) * " -> " * string(x.second)), container.adjacencyMap)
    end

end