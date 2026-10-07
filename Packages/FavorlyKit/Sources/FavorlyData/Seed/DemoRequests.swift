import FavorlyCore
import Foundation

public enum DemoRequests {
    /// The seed set: fixed IDs, timestamps relative to `now`, and none posted by Alex.
    ///
    /// Six are within 0.5 mi of Cornell Tech, three at 0.5–1.5 mi and three over 3 mi.
    public static func all(now: Date = Date()) -> [HelpRequest] {
        let bea = DemoUsers.bea.id
        let chen = DemoUsers.chen.id
        let dana = DemoUsers.dana.id

        return [
            // Within 0.5 mi of Cornell Tech
            Seed(1, "Need 2 eggs for a cake", "Baking tonight and the store is closed.", .ingredient, chen,
                 "Roosevelt Island", 40.7560, -73.9555, minutesAgo: 12),
            Seed(2, "Borrow a cup of rice", "Any kind works. I can return it tomorrow.", .ingredient, bea,
                 "Roosevelt Island", 40.7570, -73.9548, minutesAgo: 25),
            Seed(3, "Help carrying a couch up 3 floors", "Two people needed, about 15 minutes.", .movingHelp, bea,
                 "Roosevelt Island", 40.7580, -73.9540, minutesAgo: 40),
            Seed(4, "Jump start for a dead battery", "I have cables but no second car.", .carHelp, dana,
                 "Roosevelt Island", 40.7600, -73.9520, minutesAgo: 55),
            Seed(5, "Pick up a prescription bag from the pharmacy counter", "It is paid for and ready.", .errand, chen,
                 "Roosevelt Island", 40.7610, -73.9510, minutesAgo: 70),
            Seed(6, "Hold a ladder while I change a bulb", "Five minutes, hallway ceiling light.", .other, dana,
                 "Roosevelt Island", 40.7540, -73.9570, minutesAgo: 90, status: .claimed, helper: chen),

            // 0.5–1.5 mi away
            Seed(7, "Walk my dog this evening", "Friendly beagle, 20 minutes around the block.", .errand, dana,
                 "Midtown East", 40.7555, -73.9690, minutesAgo: 30),
            Seed(8, "Borrow a hand truck for an hour", "Moving a small fridge down the hall.", .movingHelp, chen,
                 "Long Island City", 40.7447, -73.9485, minutesAgo: 45),
            Seed(9, "Need a phone charger cable", "USB-C, just for the afternoon.", .other, bea,
                 "Roosevelt Island north", 40.7700, -73.9430, minutesAgo: 60),

            // Over 3 mi away
            Seed(10, "Help moving boxes to storage", "Ten boxes, one elevator ride.", .movingHelp, dana,
                 "Harlem", 40.8116, -73.9465, minutesAgo: 120),
            Seed(11, "Spare tire needs air", "Looking for a portable pump.", .carHelp, chen,
                 "Flushing", 40.7675, -73.8331, minutesAgo: 150),
            Seed(12, "Need a pinch of saffron", "For a paella, a few threads is plenty.", .ingredient, dana,
                 "Downtown Brooklyn", 40.6929, -73.9857, minutesAgo: 240, status: .completed, helper: bea),
        ].map { $0.request(now: now) }
    }

    private struct Seed {
        let number: UInt8
        let title: String
        let details: String
        let category: RequestCategory
        let requester: UserID
        let label: String
        let latitude: Double
        let longitude: Double
        let minutesAgo: Double
        let status: RequestStatus
        let helper: UserID?

        init(
            _ number: UInt8,
            _ title: String,
            _ details: String,
            _ category: RequestCategory,
            _ requester: UserID,
            _ label: String,
            _ latitude: Double,
            _ longitude: Double,
            minutesAgo: Double,
            status: RequestStatus = .open,
            helper: UserID? = nil
        ) {
            self.number = number
            self.title = title
            self.details = details
            self.category = category
            self.requester = requester
            self.label = label
            self.latitude = latitude
            self.longitude = longitude
            self.minutesAgo = minutesAgo
            self.status = status
            self.helper = helper
        }

        func request(now: Date) -> HelpRequest {
            let createdAt = now.addingTimeInterval(-minutesAgo * 60)
            return HelpRequest(
                id: RequestID(rawValue: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, number))),
                title: title,
                details: details,
                category: category,
                location: TaggedLocation(point: GeoPoint(latitude: latitude, longitude: longitude), label: label),
                requesterID: requester,
                helperID: helper,
                status: status,
                createdAt: createdAt,
                // Seeded claims happened halfway between posting and now.
                claimedAt: helper == nil ? nil : now.addingTimeInterval(-minutesAgo * 30)
            )
        }
    }
}
