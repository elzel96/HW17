//
//  ViewController.swift
//  HW17
//
//  Created by Helena on 23.09.2023.
//

import UIKit

class ViewController: UIViewController {
    
    let queue = DispatchQueue.global(qos: .utility)
    
    var generatedPassword = ""
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var changeColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change background color", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var generatePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate password", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(passwordGenerated), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = "Type password here"
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        return passwordField
    }()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        
    }
    
    // MARK: - Setups

    private func setupHierarchy() {
        view.addSubview(changeColorButton)
        view.addSubview(generatePasswordButton)
        view.addSubview(passwordField)
        view.addSubview(passwordLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            passwordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (0.2 * (view.bounds.height))),
            
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            
            generatePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generatePasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            
            changeColorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeColorButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (-0.1 * (view.bounds.height)))
        ])
    }
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password: String = ""

        let workItem = DispatchWorkItem {
            while password != passwordToUnlock {
                password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
                DispatchQueue.main.sync {
                    self.passwordLabel.text = "Is \(password) your password?"
                }
            }
        }
        
        let notifyView = DispatchWorkItem {
            DispatchQueue.main.sync {
                self.passwordLabel.text = "Done! Your password is \(password)"
            }
        }
        
        workItem.notify(queue: queue) {
            notifyView.perform()
        }
        
        queue.async(execute: workItem)
    }
    
    // MARK: - Action
    
    @objc func buttonTapped() {
        isBlack.toggle()
    }
    
    @objc func passwordGenerated() {
        generatedPassword = generateRandomPassword()
        passwordField.text = generatedPassword
        print(generatedPassword)
        queue.async {
            self.bruteForce(passwordToUnlock: self.generatedPassword)
        }
    }
}




