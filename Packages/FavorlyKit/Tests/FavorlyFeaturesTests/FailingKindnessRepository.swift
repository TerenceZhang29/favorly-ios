import FavorlyCore

/// A kindness repository whose every call throws `notFound`, for error states.
struct FailingKindnessRepository: KindnessRepository {
    func kindnessSummary(for _: UserID) async throws -> KindnessSummary {
        throw FavorlyError.notFound
    }

    func redemptions(by _: UserID) async throws -> [Redemption] {
        throw FavorlyError.notFound
    }

    func redeemGiftCard(by _: UserID) async throws -> Redemption {
        throw FavorlyError.notFound
    }
}
