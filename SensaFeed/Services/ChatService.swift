import Foundation

@Observable
final class ChatService {
    var messages: [ChatMessage] = []
    var isResponding = false

    func send(_ text: String) async {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)

        isResponding = true

        // Placeholder: simulate AI response delay
        try? await Task.sleep(for: .seconds(1))

        let placeholder = ChatMessage(
            role: .assistant,
            content: "AI integration coming soon. You asked: \"\(text)\""
        )
        messages.append(placeholder)
        isResponding = false
    }

    func clear() {
        messages = []
    }
}
