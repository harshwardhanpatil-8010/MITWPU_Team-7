//
//  CARDSSSViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import UIKit

class GameViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hintButton: UIButton!

    // MARK: - Game State
    var level: Int = 1
    var cards: [MemoryCard] = []
    var timer: Timer?
    var timeLeft: Int = 60

    var firstIndex: IndexPath?
    var secondIndex: IndexPath?

    var hintAvailable = true

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        startLevel()
    }

    func startLevel() {
        cards = LevelManager.shared.generateCards(for: level)
        hintAvailable = true
        timeLeft = max(20, 80 - (level * 2))
        updateTimeLabel()

        collectionView.reloadData()

        // Reveal all cards for 3 seconds for senior accessibility
        revealAllCardsTemporarily()
    }

    func updateTimeLabel() {
        timeLabel.text = "Time left: \(timeLeft)s"
    }

    // MARK: - Timer
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeLeft -= 1
            self.updateTimeLabel()

            if self.timeLeft <= 0 {
                self.timer?.invalidate()
                self.showAlert(title: "Time’s up!", message: "Try again.")
            }
        }
    }

    // MARK: - Reveal All (3 seconds)
    func revealAllCardsTemporarily() {
        cards.indices.forEach { cards[$0].isFlipped = true }
        collectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.cards.indices.forEach { self.cards[$0].isFlipped = false }
            self.collectionView.reloadData()
            self.startTimer()
        }
    }

    // MARK: - Hint
    @IBAction func hintTapped(_ sender: UIButton) {
        guard hintAvailable else { return }

        hintAvailable = false

        if let card = cards.first(where: { !$0.isMatched }) {
            card.isFlipped = true
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                card.isFlipped = false
                if let idx = self.cards.firstIndex(where: { $0.id == card.id }) {
                    self.collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
                }
            }
        }
    }

    // MARK: - Alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true)
    }

    func levelComplete() {
        timer?.invalidate()

        let alert = UIAlertController(
            title: "Great job!",
            message: "You completed level \(level)!",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Next Level", style: .default, handler: { _ in
            self.level += 1
            if self.level > 30 {
                self.level = 1
            }
            self.startLevel()
        }))

        present(alert, animated: true)
    }
}

// MARK: - Collection View
extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CardCell",
            for: indexPath
        ) as! MemoryCell

        cell.configure(with: cards[indexPath.item])
        return cell
    }

    // ADD BELOW THIS ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

    // **(2) CELL SIZE**
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let spacing: CGFloat = 10
        let itemsPerRow: CGFloat = 4
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow

        return CGSize(width: width, height: width * 1.3)
    }

    // **(3) SPACING**
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


