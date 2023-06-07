module TextRankEvaluation 
    include("textrank.jl")
    using ProgressBars

    function computeJaccardIndex(firstListOfIDs, secondListOfIDs) 
        setIntersection = intersect(Set(firstListOfIDs), Set(secondListOfIDs))
        setUnion = union(Set(firstListOfIDs), Set(secondListOfIDs))
        result = length(setIntersection) / length(setUnion)
        round(result, digits=4)
    end

    function computeSorensenDiceIndex(firstListOfIDs, secondListOfIDs) 
        setIntersection = intersect(Set(firstListOfIDs), Set(secondListOfIDs))
        sumOfCardinalities = length(firstListOfIDs) + length(secondListOfIDs)
        result = 2 * length(setIntersection) / sumOfCardinalities
        round(result, digits=4)
    end

    function computeMetricsForCompressionPercentX(percent)
        println("Loading the metrics for a " * string(round(Int64, percent * 100)) * "% compression rate...")
        path = "Texts/Romanian/"
        filenames = readdir(path)
        jaccardIndexSum::Float64 = 0.0
        sorensenDiceIndexSum::Float64 = 0.0

        for testCaseIndex in ProgressBar(1:length(filenames))
            filename = filenames[testCaseIndex]
            labels, sentences = TextRank.processLabelledSummarizationSampleText(path * filename)
            text = foldl((acc, x) -> acc * x * " ", sentences, init="")
            IDs, ranks, resultSentences = TextRank.run(text, "ro", percent)
            jaccardIndexSum += computeJaccardIndex(labels[1][2], IDs)
            sorensenDiceIndexSum += computeSorensenDiceIndex(labels[1][2], IDs)
        end

        averageJaccardIndex = jaccardIndexSum / length(filenames)
        averageSorensenDiceIndex = sorensenDiceIndexSum / length(filenames)
        println("Average Jaccard index: " * string(round(averageJaccardIndex, digits=4)))
        println("Average Sorensen-Dice index: " * string(round(averageSorensenDiceIndex, digits=4)))
    end 

    function computeMetrics() 
        computeMetricsForCompressionPercentX(0.3)
        computeMetricsForCompressionPercentX(0.5)
    end
end