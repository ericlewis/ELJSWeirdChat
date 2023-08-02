import InputBarAccessoryView
import MessageKit
import SwiftUI
import SwiftData
import OpenAI
import WebKit
import OSLog

struct ChatMessagesView: UIViewControllerRepresentable {
    
    final class MessageSwiftUIVC: MessagesViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            becomeFirstResponder()
            additionalBottomInset = 10
            messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    final class Coordinator {
        init(
            api: OpenAI,
            systemMessage: String,
            messages: [Message],
            plugins: [Plugin],
            context: ModelContext,
            model: Model,
            logger: Logger = Logger()
        ) {
            self.api = api
            self.system = systemMessage
            self.messages = messages
            self.plugins = plugins
            self.context = context
            self.manager = WKWebView()
            self.model = model
            self.logger = logger
        }
        
        var messages: [Message]
        var plugins: [Plugin]
        let context: ModelContext
        let api: OpenAI
        let system: String
        let manager: WKWebView
        let model: Model
        let logger: Logger
    }
    
    @State
    private var initialized = false
        
    @Query
    private var plugins: [Plugin]
    
    @Environment(\.modelContext)
    private var context
    
    @Environment(\.openai)
    private var api
    
    @Environment(\.systemMessage)
    private var systemMessage
    
    @Environment(\.model)
    private var model
    
    var messages: [Message]
    
    func makeUIViewController(context: Context) -> MessagesViewController {
        let messagesVC = MessageSwiftUIVC()
        messagesVC.setupMessageView(context: context)
        messagesVC.scrollsToLastItemOnKeyboardBeginsEditing = true
        return messagesVC
    }
    
    func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
        context.coordinator.messages = messages
        context.coordinator.plugins = plugins
        uiViewController.messagesCollectionView.reloadData()
        scrollToBottom(uiViewController)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(api: api,
                    systemMessage: systemMessage,
                    messages: messages,
                    plugins: plugins,
                    context: context,
                    model: model
        )
    }
    
    private func scrollToBottom(_ uiViewController: MessagesViewController) {
        DispatchQueue.main.async {
            uiViewController.messagesCollectionView.scrollToLastItem(animated: self.initialized)
            self.initialized = true
        }
    }
}

extension MessagesViewController {
    func setupMessageView(context: ChatMessagesView.Context) {
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)))
        messagesCollectionView.messagesDisplayDelegate = context.coordinator
        messagesCollectionView.messagesLayoutDelegate = context.coordinator
        messagesCollectionView.messagesDataSource = context.coordinator
        messageInputBar.delegate = context.coordinator
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, animated: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(isHidden, animated: animated, whilePerforming: updates) { [weak self] success in
            if success {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
}

extension ChatMessagesView.Coordinator: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: SenderType {
        Sender(senderId: Chat.Role.user.rawValue, displayName: Chat.Role.user.rawValue)
    }
    
    func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in _: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        guard let message = message as? Message else {
            return nil
        }
        
        return NSAttributedString(
            string: (message.asChat.name ?? ""),
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]
        )
    }
    
    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        guard let message = message as? Message, message.sender.senderId == "function" else {
            return 0
        }
        
        return 16
    }
}

extension ChatMessagesView.Coordinator: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let userMessage = Message(role: .user, content: inputBar.inputTextView.text)
        context.insert(userMessage)
        inputBar.inputTextView.text = ""
        inputBar.sendButton.startAnimating()
        Task {
            do {
                let functions = plugins.filter(\.isEnabled).map { $0.functionDeclaration }
                let result = try await api.chats(query: .init(
                    model: model,
                    messages: [.init(role: .system, content: system)] + messages.map({ $0.asChat }) + [.init(role: .user, content: userMessage.content)],
                    functions: functions.isEmpty ? nil : functions
                ))
                
                guard let firstChoice = result.choices.first,
                      let finishReason = firstChoice.finishReason else { return }
                
                if finishReason == "function_call" {
                    try await handleFunctionCall(firstChoice, inputBar)
                } else {
                    await handleResultMessage(result)
                }
            } catch {
                context.insert(Message(role: .assistant, content: "\(error)"))
            }
            await inputBar.sendButton.stopAnimating()
        }
    }
    
    private func handleFunctionCall(_ choice: ChatResult.Choice, _ inputBar: InputBarAccessoryView) async throws {
        guard let functionCall = choice.message.functionCall,
              let functionName = functionCall.name,
              let plugin = plugins.filter(\.isEnabled).first(where: { $0.name == functionName }) else {
            return
        }
        
        logger.info("[PLUGIN] running \(functionName)")
        let functionRun = try await manager.callAsyncJavaScript(
            plugin.code,
            arguments: JSONSerialization.jsonObject(with: (functionCall.arguments ?? "{}").data(using: .utf8)!) as! Dictionary,
            contentWorld: .world(name: functionName)
        )
        let content = String(describing: functionRun!)
        logger.info("[PLUGIN] result for \(functionName): \(content)")
        
        let assistantMessage = Message(role: .assistant, functionCall: functionCall)
        let functionMessage = Message(role: .function, content: content, name: functionName)
        context.insert(assistantMessage)
        context.insert(functionMessage)
        
        let functions = plugins.filter(\.isEnabled).map { $0.functionDeclaration }
        let summaryResult = try await api.chats(query: .init(
            model: model,
            messages: [.init(role: .system, content: system)] + messages.map({ $0.asChat }) + [
                .init(role: .assistant, functionCall: functionCall),
                .init(role: .function, content: content, name: functionName)
            ],
            functions: functions.isEmpty ? nil : functions
        ))
        
        await handleResultMessage(summaryResult)
    }
    
    private func handleResultMessage(_ result: ChatResult) async {
        await MainActor.run {
            if let resultMessage = result.choices.first?.message {
                context.insert(Message(role: resultMessage.role, content: resultMessage.content ?? "error :("))
            } else {
                context.insert(Message(role: .assistant, content: "WHYYY"))
            }
        }
    }
}

#Preview {
    ChatMessagesView(messages: [])
        .modelContainer(for: [Plugin.self, Message.self], inMemory: true)
}
