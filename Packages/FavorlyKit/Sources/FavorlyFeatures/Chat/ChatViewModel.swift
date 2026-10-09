import FavorlyCore
import Foundation
import Observation

/// A request's thread between the requester and the helper, as seen by the signed-in user.
@MainActor
@Observable
final class ChatViewModel {
    enum State: Equatable {
        case loading
        /// Oldest first.
        case loaded([ChatMessage])
        case failed(String)
    }

    let requestID: RequestID
    private(set) var state: State = .loading
    private(set) var request: HelpRequest?
    /// What the user is typing.
    var draft = ""
    private(set) var isSending = false
    /// Why the last send failed.
    private(set) var sendError: String?

    @ObservationIgnored private let environment: AppEnvironment
    @ObservationIgnored private var latestLoad = 0

    init(requestID: RequestID, environment: AppEnvironment) {
        self.requestID = requestID
        self.environment = environment
    }

    /// Changes when the user is switched, which should trigger a fresh load.
    var reloadKey: UserID {
        currentUserID
    }

    var messages: [ChatMessage]? {
        guard case let .loaded(messages) = state else { return nil }
        return messages
    }

    var title: String {
        request?.title ?? ""
    }

    /// The request is picked up and the signed-in user is one of the two people in it.
    var isOpenForSending: Bool {
        guard let request else { return false }
        return ChatRules.canSend(request: request, by: currentUserID)
    }

    /// Shown instead of the text field once the thread is read-only.
    var closedText: String? {
        guard let request, case .loaded = state, !isOpenForSending else { return nil }
        return switch request.status {
        case .cancelled: "This request was cancelled. The conversation is read-only."
        default: "This request is completed. The conversation is read-only."
        }
    }

    var canSend: Bool {
        isOpenForSending && !isSending && (try? ChatRules.validateText(draft)) != nil
    }

    /// "12 / 500", shown once the user starts typing.
    var draftCountText: String? {
        draft.isEmpty ? nil : "\(draft.count) / \(ChatRules.messageLengthRange.upperBound)"
    }

    /// What is wrong with the draft, once it is too long. An empty draft only disables Send.
    var draftMessage: String? {
        guard draft.count > ChatRules.messageLengthRange.upperBound else { return nil }
        do {
            try ChatRules.validateText(draft)
            return nil
        } catch {
            return ErrorMessage.text(for: error)
        }
    }

    func isMine(_ message: ChatMessage) -> Bool {
        message.senderID == currentUserID
    }

    /// "You", or the sender's name.
    func senderName(of message: ChatMessage) -> String {
        isMine(message) ? "You" : environment.session.displayName(for: message.senderID)
    }

    // MARK: Loading

    /// Loads the request and its thread. A thread already on screen stays visible while it reloads.
    func load() async {
        latestLoad += 1
        let load = latestLoad
        let user = currentUserID
        if case .failed = state {
            state = .loading
        }

        do {
            let request = try await environment.repository.request(id: requestID)
            let messages = try await environment.chat.messages(for: requestID, as: user)
            guard load == latestLoad else { return }
            self.request = request
            state = .loaded(messages)
        } catch is CancellationError {
            // A newer load replaced this one.
        } catch {
            guard load == latestLoad else { return }
            state = .failed(ErrorMessage.text(for: error))
        }
    }

    /// Reloads after every repository write, such as the other person's reply. Runs until the task is cancelled.
    func observeChanges() async {
        for await _ in environment.repository.changes() {
            await load()
        }
    }

    // MARK: Sending

    func send() async {
        guard canSend else { return }
        isSending = true
        defer { isSending = false }
        sendError = nil

        do {
            _ = try await environment.chat.send(draft, in: requestID, by: currentUserID)
            draft = ""
            await load()
        } catch is CancellationError {
            // The screen went away.
        } catch {
            sendError = ErrorMessage.text(for: error)
            await load()
        }
    }

    // MARK: Helpers

    private var currentUserID: UserID {
        environment.session.currentUser.id
    }
}
