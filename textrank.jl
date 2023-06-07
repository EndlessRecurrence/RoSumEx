module TextRank 
    using WordTokenizers
    using LinearAlgebra
    using LSHFunctions
    include("stopwords.jl")
    include("pagerank.jl")
    include("graph.jl")

    function processLabelledSummarizationSampleText(filename) 
        fileHandler = open(filename) 

        text = readlines(fileHandler) |> lines -> filter(line -> line != "", lines)
        textWithoutIndexesWithinTheString = 
            text[3:end] |>
            sentences -> map(x -> x[findfirst(": ", x)[1]+2:end], sentences)

        labels = 
            text[1:2] |> 
            labelLines -> map(x -> x[findfirst("%", x)[1]-3:end], labelLines) |>
            labelLinesWithoutUselessText -> map(x -> split(x, ":"), labelLinesWithoutUselessText) |>
            labelPairs -> map(x -> [strip(split(x[1], "%")[1]), x[2]], labelPairs) |>
            labelPairs -> map(x -> [parse(Float64, x[1]) / 100.0, replace(x[2], r"[Ss]|[^0-9 ]" => s"")], labelPairs) |>
            # labelPairs -> map(x -> [x[1], replace(x[2], r"," => s"")], labelPairs) |>
            labelPairs -> map(x -> [x[1], filter(token -> token != "", split(x[2], " "))], labelPairs) |>
            labelPairs -> map(x -> [x[1], map(indexAsString -> parse(Int64, indexAsString), x[2])], labelPairs)

        close(fileHandler)

        (labels, textWithoutIndexesWithinTheString)
    end

    function prepareTokenizedText(text) 
        sentences = 
            split_sentences(text) |> 
            sentences -> filter(sentence -> length(sentence) != 0, sentences)

        tokenizedText = 
            map(sentence -> replace(sentence, r"[^a-zA-Z0-9]" => s" "), sentences) |>
            sentences -> map(sentence -> lowercase(sentence), sentences) |>
            sentences -> tokenize.(sentences)
        
        (sentences, tokenizedText)
    end

    function computeCosineDistance(firstSentence, secondSentence, stopwords)
        words = union(Set(firstSentence), Set(secondSentence)) |> set -> [set...]
        v, u = zeros(length(words)), zeros(length(words))

        filter(word -> !(word in stopwords), firstSentence) |>
        filteredWords -> foreach(word -> v[findall(x -> x == word, words)[1]] += 1.0, filteredWords)
        filter(word -> !(word in stopwords), secondSentence) |>
        filteredWords -> foreach(word -> u[findall(x -> x == word, words)[1]] += 1.0, filteredWords)

        cosineDistance = 1 - dot(v, u) / (norm(v) * norm(u)) 
        if isnan(cosineDistance) 1.0 else cosineDistance end
    end

    function createSimilarityMatrix(sentences, stopwords) 
        similarityMatrix = zeros(length(sentences), length(sentences))
    
        for i in range(1, length(sentences))
            for j in range(1, length(sentences))
                if i != j 
                    similarityMatrix[i, j] = computeCosineDistance(sentences[i], sentences[j], stopwords)
                end
            end
        end

        similarityMatrix
    end

    function run(text, language="en", compressionRate::Float64=0.3)
        if compressionRate <= 0.0 || compressionRate >= 1 
            throw(ArgumentError("The compresssion rate should be a number in the range (0, 1)."))
        end
        sentences, tokenizedText = prepareTokenizedText(text) 
        top = round(Int64, length(sentences) * compressionRate)
        stopwords = if language == "ro" Stopwords.romanian else Stopwords.english end
        sentenceSimilarityMatrix = createSimilarityMatrix(tokenizedText, stopwords)
        graph = PageRank.Graph.Container(tokenizedText, sentenceSimilarityMatrix) 
        nodeRankPairs = PageRank.run(graph, sentenceSimilarityMatrix)

        nodeRankPairsSortedById = 
            nodeRankPairs[1:top] |>
            result -> sort(result, by = (x) -> x[1].id)
        
        resultSentences =
            nodeRankPairsSortedById |>
            result -> map(pair -> pair[1].id, result) |>
            sentenceIds -> map(id -> sentences[PageRank.getIndex(id, length(sentences))], sentenceIds)

        IDs = nodeRankPairsSortedById |> result -> map(pair -> PageRank.getIndex(pair[1].id, length(sentences)), result) 
        ranks = nodeRankPairsSortedById |> result -> map(pair -> pair[2], result)

        (IDs, ranks, resultSentences)
    end
    
end