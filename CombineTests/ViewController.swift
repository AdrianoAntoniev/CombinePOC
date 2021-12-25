//
//  ViewController.swift
//  CombineTests
//
//  Created by Adriano Rodrigues Vieira on 25/12/21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    let dummyColors: [UIColor] = [.cyan, .magenta, .brown, .gray, .purple, .systemPink]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        view = UIView(frame: UIScreen.main.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .orange
    }
    
    private var cancellable: AnyCancellable?
    
    private var bands: [Band] = .emptyArray {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let stack = UIStackView(frame: .zero)
                stack.translatesAutoresizingMaskIntoConstraints = false
                stack.axis = .vertical
                stack.spacing = 10
                stack.distribution = .fillEqually
                
                self.view.addSubview(stack)
                NSLayoutConstraint.activate(
                    [
                        stack.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
                        stack.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                        stack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                        stack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
                    ]
                )
                
                self.bands.forEach { [weak self] band in
                    guard let name = band.name, let hitSong = band.hitSong else { return }
                    let label = UILabel(frame: .zero)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.backgroundColor = self?.dummyColors.randomElement() ?? .yellow
                    label.textAlignment = .center
                    label.clipsToBounds = true
                    label.layer.cornerRadius = 10
                    label.text = "\(name)'s hit song is \(hitSong)!"
                    stack.addArrangedSubview(label)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let urlString = "http://my-json-server.typicode.com/AdrianoAntoniev/CombineTests-repo/bands"
        if let url = URL(string: urlString) {
            self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: [Band].self, decoder: JSONDecoder())
                .replaceError(with: .emptyArray)
                .eraseToAnyPublisher()
                .assign(to: \.bands, on: self)
        }
    }
}

struct Band: Codable {
    let name: String?
    let hitSong: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "id"
        case hitSong = "hit"
    }
}

extension Array where Element == Band {
    static let emptyArray = Array<Element>()
}
