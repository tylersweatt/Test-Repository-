import Foundation
import SwiftData

// MARK: - SampleData

@MainActor
struct SampleData {

    static func insertAll(context: ModelContext) {

        // MARK: Series
        let series = Series(title: "Romans: The Gospel Unpacked")
        context.insert(series)

        // MARK: Sermon
        let sermon = Sermon(
            title: "No Condemnation",
            passageReference: "Romans 8:1-11",
            bookOfBible: BibleBook.romans
        )
        sermon.series = series
        sermon.status = SermonStatus.ready.rawValue
        sermon.datePrepared = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        sermon.bigIdea = "Because we are in Christ, we are completely freed from condemnation."
        sermon.aim = "Listeners will rest in Christ's righteousness rather than their own performance."
        context.insert(sermon)

        // MARK: Block 0 — Hook
        let hookBlock = SermonBlock(blockType: .hook, sortOrder: 0, sermon: sermon)
        hookBlock.content = "Have you ever felt weighed down by guilt that just wouldn't go away?"
        context.insert(hookBlock)

        // MARK: Block 1 — Scripture
        let scriptureBlock = SermonBlock(blockType: .scripture, sortOrder: 1, sermon: sermon)
        scriptureBlock.content = "Romans 8:1"
        var meta = ScriptureMetadata.empty()
        meta.book = BibleBook.romans.rawValue
        meta.chapter = 8
        meta.verseStart = 1
        meta.verseText = "There is therefore now no condemnation for those who are in Christ Jesus."
        meta.translation = "ESV"
        meta.isKeyVerse = true
        scriptureBlock.scriptureMetadata = meta
        context.insert(scriptureBlock)

        // MARK: Block 2 — Explanation
        let explanationBlock = SermonBlock(blockType: .explanation, sortOrder: 2, sermon: sermon)
        explanationBlock.content = "Paul has spent seven chapters building the case for the Gospel, and now he lands the plane with one of the most glorious declarations in all of Scripture."
        context.insert(explanationBlock)

        // MARK: Block 3 — Application
        let applicationBlock = SermonBlock(blockType: .application, sortOrder: 3, sermon: sermon)
        applicationBlock.content = "You don't have to perform for God's acceptance. Christ's righteousness covers you completely."
        context.insert(applicationBlock)

        // MARK: Additional sample sermon
        let sermon2 = Sermon(
            title: "The Grace of God",
            passageReference: "Ephesians 2:1-10",
            bookOfBible: BibleBook.ephesians
        )
        sermon2.status = SermonStatus.inProgress.rawValue
        context.insert(sermon2)

        let hook2 = SermonBlock(blockType: .hook, sortOrder: 0, sermon: sermon2)
        hook2.content = "What if the very worst thing about you was not a barrier to God, but the very place He chose to display His greatest grace?"
        context.insert(hook2)

        let scripture2 = SermonBlock(blockType: .scripture, sortOrder: 1, sermon: sermon2)
        scripture2.content = "Ephesians 2:8-9"
        var meta2 = ScriptureMetadata.empty()
        meta2.book = BibleBook.ephesians.rawValue
        meta2.chapter = 2
        meta2.verseStart = 8
        meta2.verseEnd = 9
        meta2.verseText = "For by grace you have been saved through faith. And this is not your own doing; it is the gift of God, not a result of works, so that no one may boast."
        meta2.translation = "ESV"
        meta2.isKeyVerse = true
        scripture2.scriptureMetadata = meta2
        context.insert(scripture2)

        // MARK: Illustration library items
        let illustration1 = IllustrationLibrary(
            title: "The Prodigal's Return",
            content: "A young man in the 1800s ran away from home after shaming his family. Years later, broken and destitute, he wrote a letter to his mother asking if he could come home. He said he would walk past the farm and she should hang a white handkerchief on the fence if he was welcome. As he rounded the bend, every tree, every post, every fence rail was wrapped in white cloth. That is grace.",
            illustrationType: .story,
            tags: ["grace", "forgiveness", "prodigal", "homecoming"],
            isFavorite: true
        )
        context.insert(illustration1)

        let illustration2 = IllustrationLibrary(
            title: "Substitutionary Debt",
            content: "Imagine standing before a judge guilty of a crime you committed. The fine is $10,000 — a debt you cannot pay. Then the judge steps down from the bench, removes his robe, and pays the fine himself. Justice is served; the debt is cleared. That is what Christ did at Calvary.",
            illustrationType: .analogy,
            tags: ["atonement", "substitution", "justice", "grace"],
            isFavorite: false
        )
        context.insert(illustration2)

        try? context.save()
    }
}
