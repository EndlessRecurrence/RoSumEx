module TextRank 
    using WordTokenizers
    using LinearAlgebra
    using LSHFunctions
    include("stopwords.jl")
    include("pagerank.jl")

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
        # cossim(v, u)
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

    function run(text, language="en", top=5)
        sentences, tokenizedText = prepareTokenizedText(text) 
        stopwords = if language == "ro" Stopwords.romanian else Stopwords.english end
        sentenceSimilarityMatrix = createSimilarityMatrix(tokenizedText, stopwords)
        graph = PageRank.Graph.Container(tokenizedText, sentenceSimilarityMatrix) 

        PageRank.run(graph, sentenceSimilarityMatrix) |> 
        nodeRankPairs -> nodeRankPairs[1:top] |>
        result -> sort(result, by = (x) -> x[1].id) |>
        result -> map(pair -> pair[1].id, result) |>
        sentenceIds -> map(id -> sentences[id], sentenceIds)
    end
    
end