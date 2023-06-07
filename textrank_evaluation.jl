module TextRankEvaluation 
    include("textrank.jl")

    function computeJaccardIndex(firstListOfIDs, secondListOfIDs) 
        setIntersection = intersect(Set(firstListOfIDs), Set(secondListOfIDs))
        setUnion = union(Set(firstListOfIDs), Set(secondListOfIDs))
        result = length(setIntersection) / length(setUnion)
        round(result, digits=4)
    end

    function computeMetricsForCompressionPercentX(percent)
        path = "Texts/Romanian/"
        filenames = readdir(path)
        jaccardIndexSum::Float64 = 0.0

        foreach(filename -> begin 
            labels, sentences = TextRank.processLabelledSummarizationSampleText(path * filename)
            text = foldl((acc, x) -> acc * x * " ", sentences, init="")
            IDs, ranks, resultSentences = TextRank.run(text, "ro", percent)
            println(filename)
            jaccardIndexSum += computeJaccardIndex(labels[1][2], IDs)
        end, filenames)

        averageJaccardIndex = jaccardIndexSum / length(filenames)
        println("Metrics for a " * string(round(Int64, percent * 100)) * "% compression rate:")
        println("Average Jaccard Index: " * string(round(averageJaccardIndex, digits=4)))
    end 

    function computeMetrics() 
        computeMetricsForCompressionPercentX(0.3)
    end
end