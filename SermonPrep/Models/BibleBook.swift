import Foundation

enum BibleBook: String, Codable, CaseIterable, Identifiable {

    // MARK: - Old Testament

    // Law (Torah)
    case genesis = "Genesis"
    case exodus = "Exodus"
    case leviticus = "Leviticus"
    case numbers = "Numbers"
    case deuteronomy = "Deuteronomy"

    // History
    case joshua = "Joshua"
    case judges = "Judges"
    case ruth = "Ruth"
    case firstSamuel = "1 Samuel"
    case secondSamuel = "2 Samuel"
    case firstKings = "1 Kings"
    case secondKings = "2 Kings"
    case firstChronicles = "1 Chronicles"
    case secondChronicles = "2 Chronicles"
    case ezra = "Ezra"
    case nehemiah = "Nehemiah"
    case esther = "Esther"

    // Poetry & Wisdom
    case job = "Job"
    case psalms = "Psalms"
    case proverbs = "Proverbs"
    case ecclesiastes = "Ecclesiastes"
    case songOfSolomon = "Song of Solomon"

    // Major Prophets
    case isaiah = "Isaiah"
    case jeremiah = "Jeremiah"
    case lamentations = "Lamentations"
    case ezekiel = "Ezekiel"
    case daniel = "Daniel"

    // Minor Prophets
    case hosea = "Hosea"
    case joel = "Joel"
    case amos = "Amos"
    case obadiah = "Obadiah"
    case jonah = "Jonah"
    case micah = "Micah"
    case nahum = "Nahum"
    case habakkuk = "Habakkuk"
    case zephaniah = "Zephaniah"
    case haggai = "Haggai"
    case zechariah = "Zechariah"
    case malachi = "Malachi"

    // MARK: - New Testament

    // Gospels
    case matthew = "Matthew"
    case mark = "Mark"
    case luke = "Luke"
    case john = "John"

    // Acts
    case acts = "Acts"

    // Pauline Epistles
    case romans = "Romans"
    case firstCorinthians = "1 Corinthians"
    case secondCorinthians = "2 Corinthians"
    case galatians = "Galatians"
    case ephesians = "Ephesians"
    case philippians = "Philippians"
    case colossians = "Colossians"
    case firstThessalonians = "1 Thessalonians"
    case secondThessalonians = "2 Thessalonians"
    case firstTimothy = "1 Timothy"
    case secondTimothy = "2 Timothy"
    case titus = "Titus"
    case philemon = "Philemon"

    // General Epistles
    case hebrews = "Hebrews"
    case james = "James"
    case firstPeter = "1 Peter"
    case secondPeter = "2 Peter"
    case firstJohn = "1 John"
    case secondJohn = "2 John"
    case thirdJohn = "3 John"
    case jude = "Jude"

    // Apocalyptic
    case revelation = "Revelation"

    // MARK: - Identifiable

    var id: String { rawValue }

    // MARK: - Testament

    var testament: Testament {
        switch self {
        case .genesis, .exodus, .leviticus, .numbers, .deuteronomy,
             .joshua, .judges, .ruth, .firstSamuel, .secondSamuel,
             .firstKings, .secondKings, .firstChronicles, .secondChronicles,
             .ezra, .nehemiah, .esther,
             .job, .psalms, .proverbs, .ecclesiastes, .songOfSolomon,
             .isaiah, .jeremiah, .lamentations, .ezekiel, .daniel,
             .hosea, .joel, .amos, .obadiah, .jonah, .micah,
             .nahum, .habakkuk, .zephaniah, .haggai, .zechariah, .malachi:
            return .old
        case .matthew, .mark, .luke, .john,
             .acts,
             .romans, .firstCorinthians, .secondCorinthians, .galatians,
             .ephesians, .philippians, .colossians,
             .firstThessalonians, .secondThessalonians,
             .firstTimothy, .secondTimothy, .titus, .philemon,
             .hebrews, .james, .firstPeter, .secondPeter,
             .firstJohn, .secondJohn, .thirdJohn, .jude,
             .revelation:
            return .new
        }
    }

    // MARK: - Category

    var category: BookCategory {
        switch self {
        case .genesis, .exodus, .leviticus, .numbers, .deuteronomy:
            return .law
        case .joshua, .judges, .ruth, .firstSamuel, .secondSamuel,
             .firstKings, .secondKings, .firstChronicles, .secondChronicles,
             .ezra, .nehemiah, .esther:
            return .history
        case .job, .psalms, .proverbs, .ecclesiastes, .songOfSolomon:
            return .poetry
        case .isaiah, .jeremiah, .lamentations, .ezekiel, .daniel:
            return .majorProphets
        case .hosea, .joel, .amos, .obadiah, .jonah, .micah,
             .nahum, .habakkuk, .zephaniah, .haggai, .zechariah, .malachi:
            return .minorProphets
        case .matthew, .mark, .luke, .john:
            return .gospels
        case .acts:
            return .acts
        case .romans, .firstCorinthians, .secondCorinthians, .galatians,
             .ephesians, .philippians, .colossians,
             .firstThessalonians, .secondThessalonians,
             .firstTimothy, .secondTimothy, .titus, .philemon:
            return .paulineEpistles
        case .hebrews, .james, .firstPeter, .secondPeter,
             .firstJohn, .secondJohn, .thirdJohn, .jude:
            return .generalEpistles
        case .revelation:
            return .apocalyptic
        }
    }

    // MARK: - Abbreviation

    var abbreviation: String {
        switch self {
        case .genesis:            return "Gen"
        case .exodus:             return "Exo"
        case .leviticus:          return "Lev"
        case .numbers:            return "Num"
        case .deuteronomy:        return "Deu"
        case .joshua:             return "Jos"
        case .judges:             return "Jdg"
        case .ruth:               return "Rut"
        case .firstSamuel:        return "1Sa"
        case .secondSamuel:       return "2Sa"
        case .firstKings:         return "1Ki"
        case .secondKings:        return "2Ki"
        case .firstChronicles:    return "1Ch"
        case .secondChronicles:   return "2Ch"
        case .ezra:               return "Ezr"
        case .nehemiah:           return "Neh"
        case .esther:             return "Est"
        case .job:                return "Job"
        case .psalms:             return "Psa"
        case .proverbs:           return "Pro"
        case .ecclesiastes:       return "Ecc"
        case .songOfSolomon:      return "Sng"
        case .isaiah:             return "Isa"
        case .jeremiah:           return "Jer"
        case .lamentations:       return "Lam"
        case .ezekiel:            return "Eze"
        case .daniel:             return "Dan"
        case .hosea:              return "Hos"
        case .joel:               return "Joe"
        case .amos:               return "Amo"
        case .obadiah:            return "Oba"
        case .jonah:              return "Jon"
        case .micah:              return "Mic"
        case .nahum:              return "Nah"
        case .habakkuk:           return "Hab"
        case .zephaniah:          return "Zep"
        case .haggai:             return "Hag"
        case .zechariah:          return "Zec"
        case .malachi:            return "Mal"
        case .matthew:            return "Mat"
        case .mark:               return "Mar"
        case .luke:               return "Luk"
        case .john:               return "Joh"
        case .acts:               return "Act"
        case .romans:             return "Rom"
        case .firstCorinthians:   return "1Co"
        case .secondCorinthians:  return "2Co"
        case .galatians:          return "Gal"
        case .ephesians:          return "Eph"
        case .philippians:        return "Php"
        case .colossians:         return "Col"
        case .firstThessalonians: return "1Th"
        case .secondThessalonians:return "2Th"
        case .firstTimothy:       return "1Ti"
        case .secondTimothy:      return "2Ti"
        case .titus:              return "Tit"
        case .philemon:           return "Phm"
        case .hebrews:            return "Heb"
        case .james:              return "Jas"
        case .firstPeter:         return "1Pe"
        case .secondPeter:        return "2Pe"
        case .firstJohn:          return "1Jo"
        case .secondJohn:         return "2Jo"
        case .thirdJohn:          return "3Jo"
        case .jude:               return "Jud"
        case .revelation:         return "Rev"
        }
    }

    // MARK: - Chapter Count

    var chapterCount: Int {
        switch self {
        case .genesis:            return 50
        case .exodus:             return 40
        case .leviticus:          return 27
        case .numbers:            return 36
        case .deuteronomy:        return 34
        case .joshua:             return 24
        case .judges:             return 21
        case .ruth:               return 4
        case .firstSamuel:        return 31
        case .secondSamuel:       return 24
        case .firstKings:         return 22
        case .secondKings:        return 25
        case .firstChronicles:    return 29
        case .secondChronicles:   return 36
        case .ezra:               return 10
        case .nehemiah:           return 13
        case .esther:             return 10
        case .job:                return 42
        case .psalms:             return 150
        case .proverbs:           return 31
        case .ecclesiastes:       return 12
        case .songOfSolomon:      return 8
        case .isaiah:             return 66
        case .jeremiah:           return 52
        case .lamentations:       return 5
        case .ezekiel:            return 48
        case .daniel:             return 12
        case .hosea:              return 14
        case .joel:               return 3
        case .amos:               return 9
        case .obadiah:            return 1
        case .jonah:              return 4
        case .micah:              return 7
        case .nahum:              return 3
        case .habakkuk:           return 3
        case .zephaniah:          return 3
        case .haggai:             return 2
        case .zechariah:          return 14
        case .malachi:            return 4
        case .matthew:            return 28
        case .mark:               return 16
        case .luke:               return 24
        case .john:               return 21
        case .acts:               return 28
        case .romans:             return 16
        case .firstCorinthians:   return 16
        case .secondCorinthians:  return 13
        case .galatians:          return 6
        case .ephesians:          return 6
        case .philippians:        return 4
        case .colossians:         return 4
        case .firstThessalonians: return 5
        case .secondThessalonians:return 3
        case .firstTimothy:       return 6
        case .secondTimothy:      return 4
        case .titus:              return 3
        case .philemon:           return 1
        case .hebrews:            return 13
        case .james:              return 5
        case .firstPeter:         return 5
        case .secondPeter:        return 3
        case .firstJohn:          return 5
        case .secondJohn:         return 1
        case .thirdJohn:          return 1
        case .jude:               return 1
        case .revelation:         return 22
        }
    }
}

// MARK: - Testament

enum Testament: String, CaseIterable {
    case old = "Old Testament"
    case new = "New Testament"
}

// MARK: - BookCategory

enum BookCategory: String, CaseIterable {
    case law              = "Law"
    case history          = "History"
    case poetry           = "Poetry & Wisdom"
    case majorProphets    = "Major Prophets"
    case minorProphets    = "Minor Prophets"
    case gospels          = "Gospels"
    case acts             = "Acts"
    case paulineEpistles  = "Pauline Epistles"
    case generalEpistles  = "General Epistles"
    case apocalyptic      = "Apocalyptic"
}
