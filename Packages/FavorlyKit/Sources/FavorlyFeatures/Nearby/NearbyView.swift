import FavorlyCore
import SwiftUI

struct NearbyView: View {
    private let environment: AppEnvironment
    @State private var viewModel: NearbyViewModel

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = State(initialValue: NearbyViewModel(environment: environment))
    }

    var body: some View {
        List {
            Section {
                Text(environment.debugSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("nearby.debugSummary")
                Picker("Radius", selection: $viewModel.radius) {
                    ForEach(RadiusOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("nearby.radiusPicker")
            }

            Section {
                results
            } header: {
                if let countText = viewModel.countText {
                    Text(countText)
                        .textCase(nil)
                        .accessibilityIdentifier("nearby.count")
                }
            }
        }
        .navigationTitle("Nearby")
        .navigationDestination(for: RequestID.self) { id in
            RequestDetailView(requestID: id, environment: environment)
        }
        .refreshable { await viewModel.load() }
        .task(id: viewModel.reloadKey) { await viewModel.load() }
        .task { await viewModel.observeChanges() }
    }

    @ViewBuilder
    private var results: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("nearby.loading")
        case let .loaded(items):
            ForEach(items) { item in
                NavigationLink(value: item.id) {
                    RequestRow(
                        item: item,
                        requesterName: viewModel.requesterName(for: item.request),
                        isOwn: viewModel.isOwn(item.request)
                    )
                }
                .accessibilityIdentifier("nearby.row.\(item.id.rawValue.uuidString)")
            }
        case .empty:
            Text(viewModel.emptyMessage)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("nearby.empty")
        case let .failed(message):
            Text(message)
                .accessibilityIdentifier("nearby.error")
            Button("Retry") {
                Task { await viewModel.load() }
            }
            .accessibilityIdentifier("nearby.retry")
        }
    }
}

#Preview {
    NavigationStack {
        NearbyView(environment: .preview())
    }
}
