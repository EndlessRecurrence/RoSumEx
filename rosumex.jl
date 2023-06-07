include("textrank.jl")
include("textrank_evaluation.jl")

if length(ARGS) != 2
    println("Usage: julia rosumex.jl [filename] [rate]")
    println("Args :")
    println("       filename -> The name of the file containing the Romanian text.")
    println("                   Please write a filename like [1-50].txt. Keep in  ")
    println("                   mind that file 43.txt does not exist, so it is an")
    println("                   invalid parameter.")
    println("           rate -> The compression rate of the text. It should be a ")
    println("                   number in the range (0, 1).")
    exit()
end

labels, sentences = TextRank.processLabelledSummarizationSampleText("Texts/Romanian/" * ARGS[1])
text = foldl((acc, x) -> acc * x * " ", sentences, init="")
IDs, ranks, resultSentences = TextRank.run(text, "ro", parse(Float64, ARGS[2]))
resultText = foldl((acc, x) -> acc * x * " ", resultSentences, init="")

jaccardIndex = TextRankEvaluation.computeJaccardIndex(labels[1][2], IDs)
sorensenDiceIndex = TextRankEvaluation.computeSorensenDiceIndex(labels[1][2], IDs)

println(resultText)
println("Jaccard index: " * string(jaccardIndex))
println("Sorensen-Dice index: " * string(sorensenDiceIndex))