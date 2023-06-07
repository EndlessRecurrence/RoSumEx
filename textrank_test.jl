module TextRankTest 
    include("textrank.jl")

    function testEnglishTextSummarization()
        println("Running testEnglishTextSummarization...")
        fileHandler = open("Texts/english.txt", "r")
        
        text = read(fileHandler, String)
        result = TextRank.run(text, "en", 5)
        @assert isequal(result, SubString{String}["The announcement came hours after Jim Mattis, the secretary of defense, said that he would resign from his position at the end of February after disagreeing with the president over his approach to policy in the Middle East.", "The whirlwind of troop withdrawals and the resignation of Mr. Mattis leave a murky picture for what is next in the United States’ longest war, and they come as Afghanistan has been troubled by spasms of violence afflicting the capital, Kabul, and other important areas.", "Senior Afghan officials and Western diplomats in Kabul woke up to the shock of the news on Friday morning, and many of them braced for chaos ahead.", "The fear that Mr. Trump might take impulsive actions, however, often loomed in the background of discussions with the United States, they said.", "They saw the abrupt decision as a further sign that voices from the ground were lacking in the debate over the war and that with Mr. Mattis’s resignation, Afghanistan had lost one of the last influential voices in Washington who channeled the reality of the conflict into the White House’s deliberations."])

        close(fileHandler)
        println("Test testEnglishTextSummarization passed.")
    end

    function runTests()
        println("Running TextRank tests...")
        testEnglishTextSummarization()
        println("All TextRank tests passed.")
    end

end