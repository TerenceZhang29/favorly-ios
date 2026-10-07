import FavorlyCore

public enum DemoUsers {
    public static let alex = user("user-alex", "Alex", "Roosevelt Island")
    public static let bea = user("user-bea", "Bea", "Roosevelt Island")
    public static let chen = user("user-chen", "Chen", "Long Island City")
    public static let dana = user("user-dana", "Dana", "Midtown East")

    public static let all = [alex, bea, chen, dana]

    private static func user(_ id: String, _ displayName: String, _ neighborhood: String) -> UserProfile {
        UserProfile(id: UserID(rawValue: id), displayName: displayName, neighborhood: neighborhood)
    }
}
