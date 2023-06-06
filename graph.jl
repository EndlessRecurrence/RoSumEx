module Graph 

    BaseTypes = Union{Number, AbstractString, AbstractArray, AbstractDict}

    let id :: BigInt = 0
        struct Node{T <: BaseTypes} 
            id :: BigInt
            content :: T 

            Node(content :: T) where {T <: BaseTypes} = begin 
                id += 1
                new{T}(id, content)
            end

            getType() = typeof(content)
        end
    end

    struct Container{T <: BaseTypes} 
        adjacencyMap :: Dict{Node, Vector}
    
        initializeNode(graph::Container{T}, node::Node{T}) where {T <: BaseTypes} = graph.adjacencyMap[node] = []

        Container{T}() where {T <: BaseTypes} = new{T}(Dict{Node{T}, Vector{Node{T}}}()) 
        Container(elements :: AbstractArray{T}) where {T <: BaseTypes} = begin 
            initialAdjacencyMap =
                map(element -> Node(element), elements) |> 
                elements -> foldl((acc, x) -> merge!(acc, Dict(x => [])), elements, init=Dict())
            new{T}(initialAdjacencyMap) 
        end
    end

    Base.show(io::IO, container :: Container) = begin 
        println(string(typeof(container)) * " with " * string(length(container.adjacencyMap)) * " entries:")
        foreach(x -> println(string(x.first) * " -> " * string(x.second)), container.adjacencyMap)
    end

end