// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import UIKit
import AzureCommunicationChat
import AzureCore
import AzureCommunication
import AzureCommunicationSignaling


class LogInViewController: UIViewController {
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var userNameInputArea: UITextInput!
    
    @IBAction func connectButtonTapped(){
        let range = userNameInputArea.textRange(from: userNameInputArea.beginningOfDocument, to: userNameInputArea.endOfDocument)!
        let userName = userNameInputArea.text(in:range )
        if let unwrappedUserName = userName{
            if unwrappedUserName.trimmingCharacters(in: .whitespaces).isEmpty
            {
                showAlert(message: "user name cannot be empty", viewController: self)
                return
            }
            
            if let index = users.firstIndex(where: {user in user.name == unwrappedUserName}){
                currentUser = users[index]
                userNameInputArea.replace(range, withText: "")
                if let unwrappedCurrentUser = currentUser
                {
                    onStart(skypeToken: unwrappedCurrentUser.token)
                }
                else
                {
                    print("Unexpected failure happened initializing current user")
                }
                performSegue(withIdentifier: "SegueToThreadsViewController", sender: self)
            }
            else
            {
                showAlert(message: "user does not exist", viewController: self)
                return
            }
        }
        else {
            showAlert(message: "user name cannot be empty", viewController: self)
            return
        }
    }
    
    
    func getClient(credential: CommunicationTokenCredential? = nil) -> ChatClient {
        let scope = Constants.endpoint
        do {
            let options = AzureCommunicationChatClientOptions(logger: ClientLoggers.none)
            return try ChatClient(endpoint: scope, credential: credential!, withOptions: options)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func onStart (skypeToken: String)
    {
        let communicationUserCredential: CommunicationTokenCredential
        do {
            communicationUserCredential = try CommunicationTokenCredential(token:skypeToken)
        } catch {
            fatalError(error.localizedDescription)
        }
        chatClient = getClient(credential:communicationUserCredential)
        
        chatClient?.startRealTimeNotifications()
        
        chatClient?.on(event: "chatMessageReceived", listener:{
            (response, eventId)
            in
            let response = response as! ChatMessageReceivedEvent
            chatMessages.append(Message(from: ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message:response.content, topic: nil, participants: nil, initiator: nil), senderDisplayName: response.senderDisplayName , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil)))
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadMessages")))
        })
        
        chatClient?.on(event: "chatThreadCreated", listener:{
            (response, eventId)
            in
            let response = response as! ChatThreadCreatedEvent
            chatThreads.append(AzureCommunicationChat.Thread(from: ChatThread(id: response.threadId, topic: response.properties!.topic, createdOn: Iso8601Date(string:  response.createdOn)!, createdBy:(response.createdBy?.user!.communicationUserId)!, deletedOn:nil)))
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadThreads")))
        })
        
        chatClient?.on(event: "participantsAdded", listener:{
            (response, eventId)
            in
            let response = response as! ParticipantsAddedEvent
        })
        
        chatClient?.on(event: "participantsRemoved", listener:{
            (response, eventId)
            in
            let response = response as! ParticipantsRemovedEvent
        })
        
        chatClient?.on(event: "typingIndicatorReceived", listener:{
            (response, eventId)
            in
            let response = response as! TypingIndicatorReceivedEvent
        })
        chatClient?.on(event: "readReceiptReceived", listener:{
            (response, eventId)
            in
            let response = response as! ReadReceiptReceivedEvent
        })
        chatClient?.on(event: "chatMessageEdited", listener:{
            (response, eventId)
            in
            let response = response as! ChatMessageEditedEvent
        })
        chatClient?.on(event: "chatMessageDeleted", listener:{
            (response, eventId)
            in
            let response = response as! ChatMessageDeletedEvent
        })
        chatClient?.on(event: "chatThreadPropertiesUpdated", listener:{
            (response, eventId)
            in
            let response = response as! ChatThreadPropertiesUpdatedEvent
            if let unwrappedTopicName = response.properties?.topic
            {
                if let indexOfUpdatedThread = chatThreads.firstIndex(where: {$0.id == response.threadId}) {
                    chatThreads[indexOfUpdatedThread] = AzureCommunicationChat.Thread(from: ChatThread(id: chatThreads[indexOfUpdatedThread].id, topic: unwrappedTopicName, createdOn: chatThreads[indexOfUpdatedThread].createdOn, createdBy: chatThreads[indexOfUpdatedThread].createdBy.identifier, deletedOn: chatThreads[indexOfUpdatedThread].deletedOn))
                }
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadThreads")))
        })
        chatClient?.on(event: "chatThreadDeleted", listener:{
            (response, eventId)
            in
            let response = response as! ChatThreadDeletedEvent
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
