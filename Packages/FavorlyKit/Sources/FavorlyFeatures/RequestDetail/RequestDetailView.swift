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
                    .accessibilityIdentifier("detail.loading")
            case let .loaded(request):
                summary(of: request)
                facts(of: request)
                actions
            case let .failed(message):
                Text(message)
                    .accessibilityIdentifier("detail.loadError")
                Button("Retry") {
                    Task { await viewModel.load() }
                }
                .accessibilityIdentifier("detail.retry")
            }
        }
        .navigationTitle("Request")
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
            Text(request.title)
                .font(.headline)
                .accessibilityIdentifier("detail.title")
            if !request.details.isEmpty {
                Text(request.details)
                    .accessibilityIdentifier("detail.details")
            }
        }
    }

    private func facts(of request: HelpRequest) -> some View {
        Section {
            fact("Category", request.category.title, id: "category")
            fact("Location", request.location.label, id: "location")
            if let distanceText = viewModel.distanceText {
                fact("Distance", distanceText, id: "distance")
            }
            fact(
                "Posted by",
                viewModel.isOwn ? "\(viewModel.requesterName) (you)" : viewModel.requesterName,
                id: "requester"
            )
            fact("Status", viewModel.statusText, id: "status")
            if let helperName = viewModel.helperName {
                fact("Helper", helperName, id: "helper")
            }
        }
    }

    @ViewBuilder
    private var actions: some View {
        let hasActions = viewModel.canPickUp || viewModel.canComplete || viewModel.canCancel
        if hasActions || viewModel.actionError != nil {
            Section {
                if let actionError = viewModel.actionError {
                    Text(actionError)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("detail.error")
                }
                if viewModel.canPickUp {
                    Button("Pick up") { isConfirmingPickUp = true }
                        .accessibilityIdentifier("detail.pickUp")
                }
                if viewModel.canComplete {
                    Button("Mark completed") {
                        Task { await viewModel.complete() }
                    }
                    .accessibilityIdentifier("detail.complete")
                }
                if viewModel.canCancel {
                    Button("Cancel request", role: .destructive) {
                        Task { await viewModel.cancel() }
                    }
                    .accessibilityIdentifier("detail.cancel")
                }
            }
            .disabled(viewModel.isWorking)
        }
    }

    private func fact(_ label: String, _ value: String, id: String) -> some View {
        FactRow(label: label, value: value)
            .accessibilityIdentifier("detail.\(id)")
    }
}
