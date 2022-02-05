//
//  ChatViewController.swift
//  ProgrammingStart
//
//  Created by g002270 on 2022/02/03.

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatViewController: MessagesViewController, MessagesDataSource, MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    let colors = Colors()
    private var userId = ""
    private var firestoreData:[FirestoreData] = []
    private var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Firestore.firestore().collection("Messages").document().setData([
            "date": Date(),
            "senderId": "testId",
            "text": "testText",
            "userName": "testName"
        ])
        Firestore.firestore().collection("Messages").getDocuments(completion: {
            (document, error) in
            if error != nil {
                print("ChatViewController : Line(\(#line) : error : \(error!)")
            } else {
                if let document = document {
                    print("document.count :  \(document.count)"  )
                    for i in 0..<document.count {
                        var storeData = FirestoreData()
                        storeData.date = (document.documents[i].get("date")! as! Timestamp).dateValue()
                        storeData.senderId = document.documents[i].get("senderId")! as? String
                        storeData.text = document.documents[i].get("text")! as? String
                        storeData.userName = document.documents[i].get("userName")! as? String
                        self.firestoreData.append(storeData)
                    }
                }
                self.messages = self.getMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
        })

        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            userId = uuid
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.contentInset.top = 70
        
        let uiView = UIView()
        uiView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        view.addSubview(uiView)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = colors.white
        label.text = "Doctor"
        label.frame = CGRect(x: 0, y: 20, width: 100, height: 40)
        label.center.x = view.center.x
        label.textAlignment = .center
        uiView.addSubview(label)
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        gradientLayer.colors = [colors.bluePurple.cgColor, colors.blue.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        uiView.layer.insertSublayer(gradientLayer, at: 0)
    }

    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }

    func currentSender() -> SenderType {
        return Sender(senderId: userId, displayName: "MyName")
    }
    func otherSender() -> SenderType {
        return Sender(senderId: "-1", displayName: "OtherName")
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func createMessage(text: String, date: Date, _ senderId: String) -> Message {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        let sender = (senderId == userId) ? currentSender() : otherSender()
        return Message(attributedText: attributedText, sender: sender as! Sender, messageId: UUID().uuidString, date: date)
    }

    func getMessages() -> [Message] {
        var messageArray:[Message] = []
        for i in 0..<firestoreData.count {
            messageArray.append(createMessage(text: firestoreData[i].text!, date: firestoreData[i].date!, firestoreData[i].senderId!))
        }
        messageArray.sort(by: {
            a, b -> Bool in
                return a.sentDate < b.sentDate
        })
        return messageArray
    }
    
    // MARK : MessagesDisplayDelgate
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? colors.blueGreen : colors.redOrange
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar: Avatar
        avatar = Avatar(image: UIImage(named: isFromCurrentSender(message: message) ? "me" : "doctor"))
        avatarView.set(avatar: avatar)
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for componet in inputBar.inputTextView.components {
            if let text = componet as? String {
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
                let message = Message(attributedText: attributedText, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: Date())
                messages.append(message)
                messagesCollectionView.insertSections([messages.count - 1])
                sendToFirestore(message: text)
            }
        }
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
    }
    
    func sendToFirestore(message: String) {
        Firestore.firestore().collection("Messages").document().setData([
            "date" : Date(),
            "senderId": userId,
            "text": message,
            "userName": userId
        ], merge: false) { err in
            if let err = err {
                print("Error writing documet: \(err)")
            }
        }
        
    }
}
