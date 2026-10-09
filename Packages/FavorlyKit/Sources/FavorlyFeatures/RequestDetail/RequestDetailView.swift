import FavorlyCore
import SwiftUI

struct RequestDetailView: View {
    @State private var viewModel: RequestDetailViewModel
    @State private var isConfirmingPickUp = false

    init(requestID: RequestID, environment: AppEnvironment) {
        _viewModel = State(initialValue: RequestDetailViewModel(requestID: requestID, environment: environment))
    }

    var body: some View {
        List {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.section)
                    .plainListRow()
                    .accessibilityIdentifier("detail.loading")
            case let .loaded(request):
                summary(of: request)
                facts(of: request)
                actions
            case let .failed(message):
                MessageView(
                    systemImage: "exclamationmark.triangle",
                    message: message,
                    messageIdentifier: "detail.loadError",
                    retryIdentifier: "detail.retry"
                ) {
                    Task { await viewModel.load() }
                }
                .plainListRow()
            }
        }
        .navigationTitle("Request")
        .toolbarTitleDisplayMode(.inline)
        .confirmationDialog("Pick up this request?", isPresented: $isConfirmingPickUp, titleVisibility: .visible) {
            Button("Confirm pick up") {
                Task { await viewModel.pickUp() }
            }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("The requester will see that you picked it up.")
        }
        .task {
            await viewModel.load()
            await viewModel.observeChanges()
        }
    }

    private func summary(of request: HelpRequest) -> some View {
        Section {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                CategoryIcon(
                    systemImage: request.category.systemImage,
                    color: request.category.color,
                    isLarge: true
                )
                Text(request.title)
                    .font(.title2.bold())
                    .accessibilityIdentifier("detail.title")
                // The Status row below is what VoiceOver and the UI tests read.
                StatusBadge(text: viewModel.statusText, color: request.status.color)
                    .accessibilityHidden(true)
                if !request.details.isEmpty {
                    Text(request.details)
                        .lineSpacing(Theme.Spacing.small)
                        .accessibilityIdentifier("detail.details")
                }
            }
            .padding(.vertical, Theme.Spacing.medium)
        }
    }

    private func facts(of request: HelpRequest) -> some View {
        Section {
            fact("Category", request.category.title, id: "category", systemImage: "tag")
            fact("Location", request.location.label, id: "location", systemImage: "mappin")
            if let distanceText = viewModel.distanceText {
                fact("Distance", distanceText, id: "distance", systemImage: "ruler")
            }
            person(
                "Posted by",
                viewModel.isOwn ? "\(viewModel.requesterName) (you)" : viewModel.requesterName,
                id: "requester",
                systemImage: "person",
                userID: request.requesterID,
                score: viewModel.requesterScore
            )
            fact("Status", viewModel.statusText, id: "status", systemImage: "checkmark.seal")
            if let helperID = request.helperID, let helperName = viewModel.helperName {
                person(
                    "Helper",
                    helperName,
                    id: "helper",
                    systemImage: "hands.sparkles",
                    userID: helperID,
                    score: viewModel.helperScore
                )
            }
        }
    }

    /// Each action is its own section, so each full-width button gets the same corners as the cards above.
    private var actions: some View {
        Group {
            if let actionError = viewModel.actionError {
                Section {
                    ErrorBanner(message: actionError, identifier: "detail.error")
                        .plainListRow()
                }
                .compactSectionSpacing()
            }
            if viewModel.canPickUp {
                Section {
                    Button("Pick up") { isConfirmingPickUp = true }
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityIdentifier("detail.pickUp")
                        .plainListRow()
                }
                .compactSectionSpacing()
            }
            if viewModel.canComplete {
                Section {
                    Button("Mark completed") {
                        Task { await viewModel.complete() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("detail.complete")
                    .plainListRow()
                }
                .compactSectionSpacing()
            }
            if viewModel.canCancel {
                Section {
                    Button("Cancel request", role: .destructive) {
                        Task { await viewModel.cancel() }
                    }
                    .buttonStyle(SecondaryButtonStyle(color: Theme.Colors.statusCancelled))
                    .accessibilityIdentifier("detail.cancel")
                    .plainListRow()
                }
                .compactSectionSpacing()
            }
        }
        .disabled(viewModel.isWorking)
    }

    /// A requester or helper row with their Kindness score. Tapping it opens their profile.
    /// VoiceOver and the UI tests read the name as the value, as before; the score is in the hint.
    private func person(
        _ label: String,
        _ name: String,
        id: String,
        systemImage: String,
        userID: UserID,
        score: Int?
    ) -> some View {
        NavigationLink(value: userID) {
            HStack(spacing: Theme.Spacing.medium) {
                FactRow(label: label, value: name, systemImage: systemImage)
                if let score {
                    ScoreLabel(points: score)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(name)
        .accessibilityHint(score.map { "Kindness score \($0). Opens their profile." } ?? "Opens their profile.")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("detail.\(id)")
    }

    private func fact(_ label: String, _ value: String, id: String, systemImage: String) -> some View {
        FactRow(label: label, value: value, systemImage: systemImage)
            .accessibilityIdentifier("detail.\(id)")
    }
}
