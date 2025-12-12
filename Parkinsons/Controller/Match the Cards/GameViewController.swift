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
    
    let maxLevel = 30
    let preGameRevealDuration: TimeInterval = 4.0
    let mismatchDelay: TimeInterval = 1.5
    
    var level = 1
    var cards = [Card]()
    var matchedPairs = 0
    var firstIndexPath: IndexPath?
    var secondIndexPath: IndexPath?
    var interactionsEnabled: Bool = true
    var hasInitializedLevel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MatchTheCardCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        startNewLevel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasInitializedLevel && cards.count > 0 {
            hasInitializedLevel = true
            collectionView.layoutIfNeeded()
            showAllCardsBriefly()
        }
    }
    func startNewLevel() {
        if level > maxLevel {
            goToNextScreen()
            return
        }
        hasInitializedLevel = false
        resetState()
        generateCards()
        collectionView.reloadData()
    }
    private func resetState() {
        cards.removeAll()
        matchedPairs = 0
        firstIndexPath = nil
        secondIndexPath = nil
        interactionsEnabled = false
    }
    private func generateCards() {
        let maxPairs = 4 + min(level - 1, 11)
        let numberOfPairs = min(maxPairs, 15)
        let available = [ "🤖", "🔥", "🌈", "🐶", "🚀", "🍕", "⚡️", "🎧", "🏖️", "🌙", "⭐️"]
        let set = Array(available.prefix( numberOfPairs))
        var data: [(Int, String)] = []
        for (id, c) in set.enumerated() {
            data.append((id,c))
            data.append((id,c))
        }
        data.shuffle()
        for d in data {
            cards.append(Card(identifier: d.0, content: d.1))
        }
    }
    
    private func showAllCardsBriefly() {
        for i in 0..<cards.count {
            cards[i].isFlipped = true
            let ip = IndexPath(item: i, section: 0)
            if let cell = collectionView.cellForItem(at: ip) as? MatchTheCardCollectionViewCell {
                cell.flip(toFront: true, animated: false)
                
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + preGameRevealDuration) {
            for i in 0..<self.cards.count {
                self.cards[i].isFlipped = false
                let ip = IndexPath(item: i, section: 0)
                if let cell = self.collectionView.cellForItem(at: ip) as? MatchTheCardCollectionViewCell {
                    cell.flip(toFront: false, animated: true)
                    
                }
            }
            self.interactionsEnabled = true
        }
    }
    private func checkForMatch() {
        guard let ip1 = firstIndexPath, let ip2 = secondIndexPath else {
            resetSelection()
            return
        }
        let c1 = cards[ip1.item]
        let c2 = cards[ip2.item]
        if c1.identifier == c2.identifier {
            cards[ip1.item].isMatched = true
            cards[ip2.item].isMatched = true
            matchedPairs += 1
            if matchedPairs == cards.count / 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.goToNextScreen()
                }
                
            }
            if let cell1 = collectionView.cellForItem(at: ip1) as? MatchTheCardCollectionViewCell {
                cell1.configure(with: cards[ip1.item])
            }
            if let cell2 = collectionView.cellForItem(at: ip2) as? MatchTheCardCollectionViewCell {
                cell2.configure(with: cards[ip2.item])
            }
            resetSelection()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + mismatchDelay) {
                self.cards[ip1.item].isFlipped = false
                self.cards[ip2.item].isFlipped = false
                if let cell1 = self.collectionView.cellForItem(at: ip1) as? MatchTheCardCollectionViewCell {
                    cell1.flip(toFront: false, animated: true)
                }
                if let cell2 = self.collectionView.cellForItem(at: ip2) as? MatchTheCardCollectionViewCell {
                    cell2.flip(toFront: false, animated: true)
                }
                self.resetSelection()
            }
        }
        
    }
    private func resetSelection() {
        firstIndexPath = nil
        secondIndexPath = nil
        interactionsEnabled = true
    }
    
    private func goToNextScreen() {
        // 1. Load the next view controller from storyboard
        let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "SuccessViewController") as? SuccessViewController {
            
            // 2. Push navigation
            navigationController?.pushViewController(nextVC, animated: true)
            
            // Or if your game uses fullscreen modals:
            // present(nextVC, animated: true)
        }
    }

   
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! MatchTheCardCollectionViewCell
        cell.configure(with: cards[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard interactionsEnabled else { return }
        let card = cards[indexPath.item]
        if card.isMatched || card.isFlipped{
            return
        }
        interactionsEnabled = false
        cards[indexPath.item].isFlipped = true
        if let cell = collectionView.cellForItem(at: indexPath) as? MatchTheCardCollectionViewCell {
            cell.flip(toFront: true, animated: true)
        }
        if firstIndexPath == nil {
            firstIndexPath = indexPath
            interactionsEnabled = true
        } else if secondIndexPath == nil {
            secondIndexPath = indexPath
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.checkForMatch()
            }
        }
    }
}
extension GameViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let total = cards.count
        
        // AUTO-CALCULATE number of columns based on total cards
        // This ensures cards shrink when more are added
        var columns = Int(sqrt(Double(total))) + 1
        columns = min(columns, 6)   // maximum 6 per row
        columns = max(columns, 3)   // minimum 3 per row

        let sidePadding: CGFloat = 12
        let spacing: CGFloat = 12

        let totalSpacing = sidePadding * 2 + spacing * CGFloat(columns - 1)
        let availableWidth = collectionView.bounds.width - totalSpacing

        let cellWidth = floor(availableWidth / CGFloat(columns))

        return CGSize(width: cellWidth, height: cellWidth)
    }


}

