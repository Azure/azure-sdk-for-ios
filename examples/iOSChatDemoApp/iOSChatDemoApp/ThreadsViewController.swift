//
//  ViewController.swift
//  iOSChatDemoApp
//
//  Created by Gloria Li on 2021-02-01.
//

import UIKit
import AzureCommunicationChat
import AzureCore
import AzureCommunication
import AzureCommunicationSignaling

class ThreadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var threadsTableView: UITableView!
    @IBAction func goToCreateNewThreadPageButtonTapped(){
        performSegue(withIdentifier: "SegueToCreateNewThreadViewController", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatThreads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = chatThreads[indexPath.row].topic
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        threadsTableView.deselectRow(at: indexPath, animated: true)
        do {
            chatThreadClient = try chatClient?.createClient(forThread: chatThreads[indexPath.row].id)
            performSegue(withIdentifier: "SegueToChatViewController", sender: self)
        } catch _ {
            print("Failed to initialize ChatThreadClient")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);
        if self.isMovingFromParent
        {
            chatThreads = []
            currentUser = nil
            loggedIn = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threadsTableView.delegate = self
        threadsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        threadsTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadThreads), name:  Notification.Name(rawValue: "newThread"), object: nil)
        listThreads ()
    }
    
    func listThreads ()
    {
        chatClient?.listThreads { result, _ in
            switch result {
            case let .success(threads):
                for thread in threads.items ?? []
                {
                    if thread.deletedOn == nil
                    {
                        chatThreads.append(AzureCommunicationChat.Thread(from:ChatThread(id: thread.id, topic: thread.topic, createdOn: Iso8601Date(), createdBy: "", deletedOn: thread.deletedOn)))
                    }
                }
                self.reloadThreads()
            case .failure:
                print("Unexpected failure happened in list chat threads")
            }
        }
    }
    
    @objc func reloadThreads() {
        DispatchQueue.main.async(execute: {
            self.threadsTableView.reloadData()
        })
    }
}

