import FavorlyCore
import SwiftUI

struct PostRequestView: View {
    @State private var viewModel: PostRequestViewModel
    private let onPosted: (HelpRequest) -> Void

    init(environment: AppEnvironment, onPosted: @escaping (HelpRequest) -> Void) {
        _viewModel = State(initialValue: PostRequestViewModel(environment: environment))
        self.onPosted = onPosted
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $viewModel.title)
                    .accessibilityIdentifier("post.title")
                if let titleMessage = viewModel.titleMessage {
                    validationText(titleMessage, id: "post.titleMessage")
                }
                TextField("Details (optional)", text: $viewModel.details, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .accessibilityIdentifier("post.details")
                if let detailsMessage = viewModel.detailsMessage {
                    validationText(detailsMessage, id: "post.detailsMessage")
                }
            } header: {
                Text("What do you need?")
            }

            Section {
                Picker("Category", selection: $viewModel.category) {
                    ForEach(RequestCategory.allCases, id: \.self) { category in
                        Text(category.title).tag(category)
                    }
                }
                .accessibilityIdentifier("post.category")
            }

            Section("Location") {
                location
            }

            Section {
                if let submitError = viewModel.submitError {
                    validationText(submitError, id: "post.submitError")
                }
                Button("Post request") {
                    Task {
                        if let request = await viewModel.submit() {
                            onPosted(request)
                        }
                    }
                }
                .disabled(!viewModel.canSubmit)
                .accessibilityIdentifier("post.submit")
            }
        }
        .navigationTitle("Post")
        .task(id: viewModel.reloadKey) { await viewModel.loadLocation() }
    }

    @ViewBuilder
    private var location: some View {
        switch viewModel.locationState {
        case .loading:
            ProgressView()
                .accessibilityIdentifier("post.locationLoading")
        case .tagged:
            Label(viewModel.locationText ?? "", systemImage: "mappin.and.ellipse")
                .accessibilityIdentifier("post.location")
        case let .failed(message):
            Text(message)
                .accessibilityIdentifier("post.locationError")
            Button("Retry") {
                Task { await viewModel.loadLocation() }
            }
            .accessibilityIdentifier("post.locationRetry")
        }
    }

    private func validationText(_ message: String, id: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.red)
            .accessibilityIdentifier(id)
    }
}

#Preview {
    NavigationStack {
        PostRequestView(environment: .preview()) { _ in }
    }
}
