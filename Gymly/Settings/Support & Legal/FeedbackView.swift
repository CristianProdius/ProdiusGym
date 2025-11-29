//
//  FeedbackView.swift
//  ShadowLift
//
//  Created by Claude Code on 29.11.2024.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showMailAlert = false
    @State private var selectedFeedbackType: FeedbackType = .general

    enum FeedbackType: String, CaseIterable {
        case general = "General Feedback"
        case feature = "Feature Suggestion"
        case improvement = "App Improvement"
        case praise = "Share Love"

        var email: String {
            return "sebastian.kucera@icloud.com"
        }

        var subject: String {
            switch self {
            case .general:
                return "ShadowLift Feedback"
            case .feature:
                return "Feature Suggestion: [Your Idea]"
            case .improvement:
                return "ShadowLift Improvement Suggestion"
            case .praise:
                return "ShadowLift - Positive Feedback"
            }
        }

        var icon: String {
            switch self {
            case .general:
                return "bubble.left.and.bubble.right.fill"
            case .feature:
                return "lightbulb.fill"
            case .improvement:
                return "wand.and.stars"
            case .praise:
                return "heart.fill"
            }
        }

        var color: Color {
            switch self {
            case .general:
                return .blue
            case .feature:
                return .yellow
            case .improvement:
                return .purple
            case .praise:
                return .pink
            }
        }

        var description: String {
            switch self {
            case .general:
                return "Share your thoughts about the app"
            case .feature:
                return "Suggest a new feature you'd love to see"
            case .improvement:
                return "Help us make ShadowLift even better"
            case .praise:
                return "Let us know what you love!"
            }
        }
    }

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.accent(scheme, accentColor: appearanceManager.accentColor))
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundColor(appearanceManager.accentColor.color)

                        Text("Send Feedback")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Your feedback helps us improve!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // Feedback Type Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's on your mind?")
                            .font(.headline)
                            .padding(.horizontal, 24)

                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            Button(action: {
                                selectedFeedbackType = type
                                openEmailComposer()
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(type.color)
                                        .frame(width: 40)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(type.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text(type.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)

                    Divider()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)

                    // Quick Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("We Value Your Input")
                            .font(.headline)
                            .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 12) {
                            FeedbackInfoRow(
                                icon: "envelope.fill",
                                text: "Every message is read personally",
                                color: .blue
                            )

                            FeedbackInfoRow(
                                icon: "sparkles",
                                text: "Your ideas shape future updates",
                                color: .yellow
                            )

                            FeedbackInfoRow(
                                icon: "heart.fill",
                                text: "We love hearing from our users",
                                color: .pink
                            )
                        }
                        .padding(.horizontal, 24)
                    }

                    // Response Info
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.secondary)
                            Text("Response Time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("We'll get back to you as soon as possible")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Send Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Email Not Available", isPresented: $showMailAlert) {
            Button("Copy Email", action: {
                UIPasteboard.general.string = selectedFeedbackType.email
            })
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please send an email to \(selectedFeedbackType.email) from your mail app. The email address has been copied to your clipboard.")
        }
    }

    private func openEmailComposer() {
        // Get device info for feedback email
        let deviceModel = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        let body = """


        ---
        Device Information (Please don't remove):
        Device: \(deviceModel)
        iOS Version: \(osVersion)
        App Version: \(appVersion) (Build \(buildNumber))
        """

        let urlString = "mailto:\(selectedFeedbackType.email)?subject=\(selectedFeedbackType.subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback if mail app not available
            UIPasteboard.general.string = selectedFeedbackType.email
            showMailAlert = true
        }
    }
}

// MARK: - Feedback Info Row Component
struct FeedbackInfoRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    FeedbackView()
        .environmentObject(AppearanceManager())
}
