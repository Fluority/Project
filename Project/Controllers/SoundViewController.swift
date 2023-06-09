//
//  SoundViewController.swift
//  Project
//
//  Created by liene.krista.neimane on 23/05/2023.
//

import UIKit
import AVFoundation

struct Sound: Codable {
    let name: String
    let filename: String
}


class SoundViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var sounds: [Sound] = []
    var selectedSounds: Set<String> = []
    var soundPlayers: [String: AVAudioPlayer] = [:]
    var allSounds: [Sound] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSounds()
        searchBar.delegate = self
        customizeSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = AppearanceManager.shared.backgroundColor
        customizeSearchBar()
    }
    
    
    // Search based on the entered text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSounds(query: searchText)
    }
    
    private func customizeSearchBar() {
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBar.barTintColor = AppearanceManager.shared.searchBarColor
        searchBarTextField?.textColor = AppearanceManager.shared.searchBarTextColor
    }
    
    // Clearing search
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchSounds(query: nil)
    }
    
    func searchSounds(query: String?) {
        if let query = query, !query.isEmpty {
            let filteredSounds = allSounds.filter {
                $0.name.lowercased().contains(query.lowercased())
            }
            displaySounds(filteredSounds)
        } else {
            // No query or empty query, display all sounds
            displaySounds(allSounds)
        }
    }

    
    func displaySounds(_ soundsToDisplay: [Sound]) {
        sounds = soundsToDisplay
        tableView.reloadData()
    }
    
    
    // All of the sounds
    func loadSounds() {
        let loadedSounds = [
            Sound(name: "Artic Wind", filename: "arctic-wind"),
            Sound(name: "Rain drips in a bucket", filename: "rain-drips-in-a-bucket"),
            Sound(name: "Forest Summer", filename: "forest-summer"),
            Sound(name: "Wind in trees with birds", filename: "wind-in-the-trees-with-birds"),
            Sound(name: "Birds in action", filename: "birds-in-action"),
            Sound(name: "Moderate Rain", filename: "rain-moderate-a"),
            Sound(name: "Bird Chirps", filename: "bird-chirps3"),
            Sound(name: "Rain and Thunder", filename: "rain-and-thunder-4"),
            Sound(name: "Bird whistling", filename: "bird-whistling-a")
        ]
        sounds = loadedSounds
        allSounds = loadedSounds
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath)
        let sound = sounds[indexPath.row]
        
        if let soundCell = cell as? SoundCell {
            let isSelected = SoundStateManager.shared.isSelected(sound.filename)
            soundCell.configure(with: sound, isSelected: isSelected)
            soundCell.isDarkModeEnabled = AppearanceManager.shared.isDarkModeEnabled
            
            // Making the switch size a bit smaller
            soundCell.soundSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            soundCell.soundSwitch.addTarget(self, action: #selector(soundSwitchChanged(_:)), for: .valueChanged)
            soundCell.soundSwitch.tag = indexPath.row
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }

    
    @objc func soundSwitchChanged(_ sender: UISwitch) {
        let sound = sounds[sender.tag]
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if sender.isOn {
            selectedSounds.insert(sound.filename)
            appDelegate.playSoundLoop(soundName: sound.filename)
        } else {
            selectedSounds.remove(sound.filename)
            appDelegate.stopSoundLoop(soundName: sound.filename)
        }
        
        // Updating the selected sounds
        SoundStateManager.shared.setSelectedSounds(selectedSounds)
        print("Selected sounds: \(selectedSounds)")
    }
    
}


class SoundStateManager {
    static let shared = SoundStateManager()
    
    private let selectedSoundsKey = "SelectedSounds"
    private var selectedSounds: Set<String> = []
    
    private init() {
        loadSelectedSounds()
    }
    
    func isSelected(_ soundName: String) -> Bool {
        return selectedSounds.contains(soundName)
    }
    
    func setSelectedSounds(_ sounds: Set<String>) {
        selectedSounds = sounds
        saveSelectedSounds()
    }
    
    private func saveSelectedSounds() {
        UserDefaults.standard.set(Array(selectedSounds), forKey: selectedSoundsKey)
    }
    
    private func loadSelectedSounds() {
        if let selectedSoundsArray = UserDefaults.standard.array(forKey: selectedSoundsKey) as? [String] {
            selectedSounds = Set(selectedSoundsArray)
        }
    }
}
