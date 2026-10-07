import FavorlyCore
import Testing

struct DraftValidatorTests {
    private func draft(title: String, details: String = "") -> NewRequestDraft {
        NewRequestDraft(
            title: title,
            details: details,
            category: .other,
            location: TaggedLocation(point: GeoPoint(latitude: 40.7553, longitude: -73.9562), label: "Cornell Tech")
        )
    }

    @Test(arguments: [3, 80])
    func titleAtTheLimitsIsValid(length: Int) throws {
        try DraftValidator.validate(draft(title: String(repeating: "a", count: length)))
    }

    @Test(arguments: [0, 2])
    func titleShorterThanThreeCharactersIsRejected(length: Int) {
        #expect(throws: FavorlyError.validation("Title must be at least 3 characters.")) {
            try DraftValidator.validate(draft(title: String(repeating: "a", count: length)))
        }
    }

    @Test func titleLongerThanEightyCharactersIsRejected() {
        #expect(throws: FavorlyError.validation("Title must be 80 characters or fewer.")) {
            try DraftValidator.validate(draft(title: String(repeating: "a", count: 81)))
        }
    }

    @Test(arguments: ["     ", " \n\t ", "  ab  "])
    func whitespaceDoesNotCountTowardTheTitleLength(title: String) {
        #expect(throws: FavorlyError.validation("Title must be at least 3 characters.")) {
            try DraftValidator.validate(draft(title: title))
        }
    }

    @Test func titleAndDetailsAreTrimmed() throws {
        let normalized = try DraftValidator.validate(draft(title: "  Need rice \n", details: "\tOne cup  "))
        #expect(normalized.title == "Need rice")
        #expect(normalized.details == "One cup")
    }

    @Test(arguments: [0, 500])
    func detailsAtTheLimitsAreValid(length: Int) throws {
        try DraftValidator.validate(draft(title: "Need rice", details: String(repeating: "d", count: length)))
    }

    @Test func detailsLongerThanFiveHundredCharactersAreRejected() {
        #expect(throws: FavorlyError.validation("Details must be 500 characters or fewer.")) {
            try DraftValidator.validate(draft(title: "Need rice", details: String(repeating: "d", count: 501)))
        }
    }
}
