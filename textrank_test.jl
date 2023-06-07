module TextRankTest 
    include("textrank.jl")

    function testEnglishTextSummarization()
        println("Running testEnglishTextSummarization...")
        fileHandler = open("Texts/English/english.txt", "r")
        
        text = read(fileHandler, String)
        result = TextRank.run(text, "en")
        @assert isequal(result, SubString{String}["The announcement came hours after Jim Mattis, the secretary of defense, said that he would resign from his position at the end of February after disagreeing with the president over his approach to policy in the Middle East.", "Senior Afghan officials and Western diplomats in Kabul woke up to the shock of the news on Friday morning, and many of them braced for chaos ahead.", "The fear that Mr. Trump might take impulsive actions, however, often loomed in the background of discussions with the United States, they said."])

        close(fileHandler)
        println("Test testEnglishTextSummarization passed.")
    end

    function testRomanianSummaryTextPreprocessing()
        println("Running testRomanianSummaryTextPreprocessing...")
        labels, sentences = TextRank.processLabelledSummarizationSampleText("Texts/Romanian/1.7 arțar - Sut George.txt")
        @assert labels == [[0.3, [1, 8, 9, 12, 13]], [0.5, [1, 4, 8, 9, 11, 12, 13]]]
        @assert sentences == ["Arțarul este un arbore înalt de până la 20 m.", "Trunchiul este neregulat, cu scoarță netedă, cenușie-verzuie.", "Coroana este neregulată.", "Frunzele sunt imparipenat compuse, cu 3-5 foliole.", "Arțarul Japonez este un arbore mic sau arbust cu un frunzis foarte decorativ.", "Toamna, culoarea frunzișului devine roșu carmin.", "Arțarul, arbore înalt, ce ajunge până la 25 m.", "Trunchiul este drept și înalt, cu scoarță cenușie.", "Coroana este larg ovoidală, frunzele sunt mari, palmat-lobate cu vârfuri ascuțite și sinusurile dintre lobi rotunjite.", "Petiolii au latex alb, Florile verzi-galbui, înflorirea are loc înainte de înfrunzire.", "Scoarța este cenușie, iar coroana largă, ovoidal rotunjită.", "Arbore viguros, ce ajunge la înălțimi de 30-40 m.", "Speciile de artar nu necesită îngrijiri deosebite, reușind să se adapteze ușor la condițiile de mediu. ", "Se recomandă ca tăierile de întreținere să se facă în perioada de repaus vegetativ: toamna, după căderea frunzelor sau primăvara devreme."]
        println("Test testRomanianSummaryTextPreprocessing passed.")
    end

    function testRomanianTextSummarization()
        println("Running testRomanianTextSummarization...")
        labels, sentences = TextRank.processLabelledSummarizationSampleText("Texts/Romanian/1.7 arțar - Sut George.txt")
        text = foldl((acc, x) -> acc * x * " ", sentences, init="")
        result = TextRank.run(text, "ro")
        println(result)
        println("Test testRomanianTextSummarization passed.")
    end

    function runTests()
        println("Running TextRank tests...")
        testEnglishTextSummarization()
        testRomanianSummaryTextPreprocessing()
        # testRomanianTextSummarization()
        println("All TextRank tests passed.")
    end

end