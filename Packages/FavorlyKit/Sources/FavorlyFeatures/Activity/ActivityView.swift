import FavorlyCore
import SwiftUI

struct ActivityView: View {
    private let environment: AppEnvironment
    /// The request that was just posted, shown highlighted.
    private let highlightedRequestID: RequestID?
    @State private var viewModel: ActivityViewModel

    init(environment: AppEnvironment, highlightedRequestID: RequestID?) {
        self.environment = environment
        self.highlightedRequestID = highlightedRequestID
        _viewModel = State(initialValue: ActivityViewModel(environment: environment))
    }

    var body: some View {
        List {
            Section {
                Picker("Show", selection: $viewModel.segment) {
                    ForEach(ActivitySegment.allCases) { segment in
                        Text(segment.title).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("activity.segment")
            }

            Section {
                results
            }
        }
        .navigationTitle("My Activity")
        .navigationDestination(for: RequestID.self) { id in
            RequestDetailView(requestID: id, environment: environment)
        }
        .refreshable { await viewModel.load() }
        .task(id: viewModel.reloadKey) { await viewModel.load() }
        .task { await viewModel.observeChanges() }
        .onChange(of: highlightedRequestID, initial: true) { _, highlighted in
            if highlighted != nil {
                viewModel.segment = .posted
            }
        }
    }

    @ViewBuilder
    private var results: some View {
        if case let .failed(message) = viewModel.state {
            Text(message)
                .accessibilityIdentifier("activity.error")
            Button("Retry") {
                Task { await viewModel.load() }
            }
            .accessibilityIdentifier("activity.retry")
        } else if let items = viewModel.items {
            if items.isEmpty {
                Text(viewModel.segment.emptyMessage)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("activity.empty")
            }
            ForEach(items) { request in
                let isNew = request.id == highlightedRequestID
                NavigationLink(value: request.id) {
                    ActivityRow(request: request, subtitle: viewModel.subtitle(for: request), isNew: isNew)
                }
                .listRowBackground(isNew ? Color.accentColor.opacity(0.12) : nil)
                .accessibilityIdentifier("activity.row.\(request.id.rawValue.uuidString)")
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("activity.loading")
        }
    }
}

#Preview {
    NavigationStack {
        ActivityView(environment: .preview(), highlightedRequestID: nil)
    }
}
