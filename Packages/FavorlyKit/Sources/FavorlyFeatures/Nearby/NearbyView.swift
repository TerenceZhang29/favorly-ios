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
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.medium) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Theme.Colors.brand)
                            .accessibilityHidden(true)
                        Text(environment.debugSummary)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("nearby.debugSummary")
                    }
                    .font(.subheadline)
                    Picker("Radius", selection: $viewModel.radius) {
                        ForEach(RadiusOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("nearby.radiusPicker")
                }
                .padding(.vertical, Theme.Spacing.small)
            }

            Section {
                results
            } header: {
                if let countText = viewModel.countText {
                    Text(countText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primary)
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
                .padding(.vertical, Theme.Spacing.section)
                .plainListRow()
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
            MessageView(systemImage: "tray", message: viewModel.emptyMessage, messageIdentifier: "nearby.empty")
                .plainListRow()
        case let .failed(message):
            MessageView(
                systemImage: "wifi.exclamationmark",
                message: message,
                messageIdentifier: "nearby.error",
                retryIdentifier: "nearby.retry"
            ) {
                Task { await viewModel.load() }
            }
            .plainListRow()
        }
    }
}

#Preview {
    NavigationStack {
        NearbyView(environment: .preview())
    }
}
