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
    
    var selectedDate: Date!
    var level: Int = 1
    
    private var cards = [Card]()
    private var matchedPairs = 0
    private var firstIndex: IndexPath?
    private var secondIndex: IndexPath?
    private var interactionsEnabled: Bool = true
    
    private var timer: Timer?
    private var secondsElapsed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let nib = UINib(nibName: "MatchTheCardCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        collectionView.collectionViewLayout = layout

        configureLayout()
        level = min(max(level, 1), 30)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
            layout.estimatedItemSize = .zero
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cards.isEmpty {
            startGame()
        }
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactionsEnabled = true
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        tabBarController?.tabBar.isHidden = false
    }

    
    private struct Difficulty {
        let pairs: Int
        let revealTime: TimeInterval
    }

    private func difficulty(for level: Int) -> Difficulty {
        switch level {
        case 1...3:
            return Difficulty(pairs: 3, revealTime: 4)
        case 4...6:
            return Difficulty(pairs: 4, revealTime: 4)
        case 7...9:
            return Difficulty(pairs: 5, revealTime: 3.5)
        case 10...12:
            return Difficulty(pairs: 6, revealTime: 3)
        case 13...15:
            return Difficulty(pairs: 7, revealTime: 3)
        case 16...18:
            return Difficulty(pairs: 8, revealTime: 2.5)
        case 19...21:
            return Difficulty(pairs: 9, revealTime: 2.5)
        case 22...24:
            return Difficulty(pairs: 10, revealTime: 2)
        case 25...27:
            return Difficulty(pairs: 11, revealTime: 2)
        default:
            return Difficulty(pairs: 12, revealTime: 1.5)
        }
    }
    private func configureLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
    }


    private func startGame() {
        generateCards()

           collectionView.reloadData()
           collectionView.layoutIfNeeded()
           revealCards()
           startTimer()
        
    }
private func startTimer() {
        secondsElapsed = 0
        timeLabel.text = "0s"
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.secondsElapsed += 1
            self.timeLabel.text = "\(self.secondsElapsed)s"}
    
}
    private func stopTimer() {
        timer?.invalidate()
}
  
    
    private func generateCards() {
        let symbols = [
            "🤖", "🔥", "🌈", "🐶", "🚀", "🍕", "⚡️", "🎧",
            "🏖️", "🌙", "⭐️", "🐰", "🐢", "🍎", "🎈", "🎉",
            "🍀", "🐠", "🦋", "🎮"
        ]

        let difficulty = difficulty(for: level)
        let pairCount = min(difficulty.pairs, symbols.count)

        var temp: [Card] = []

        for i in 0..<pairCount {
            let card1 = Card(identifier: i, content: symbols[i], isFlipped: false, isMatched: false)
            let card2 = Card(identifier: i, content: symbols[i], isFlipped: false, isMatched: false)
            temp.append(card1)
            temp.append(card2)
        }

        cards = temp.shuffled()
    }

    
    private func revealCards() {
        let revealTime = difficulty(for: level).revealTime

        interactionsEnabled = false
        cards.indices.forEach { cards[$0].isFlipped = true }
        collectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + revealTime) {
            self.cards.indices.forEach { self.cards[$0].isFlipped = false }
            self.collectionView.reloadData()
            self.interactionsEnabled = true
        }
    }


private func checkMatch() {
    guard let i1 = firstIndex, let i2 = secondIndex else {
        resetSelection()
        return
    }
    if cards[i1.item].identifier == cards[i2.item].identifier {
        cards[i1.item].isMatched = true
        cards[i2.item].isMatched = true
        matchedPairs += 1
        resetSelection()
        if matchedPairs == cards.count / 2 {
            
            stopTimer()
            DailyGameManager.shared.markCompleted(date: selectedDate)
            goToSuccess()
        }
    } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.cards[i1.item].isFlipped = false
            self.cards[i2.item].isFlipped = false
            self.collectionView.reloadItems(at: [i1, i2])
            self.resetSelection()
        }
    }
}


    private func resetSelection() {
        firstIndex = nil
        secondIndex = nil
        interactionsEnabled = true
    }

    private func goToSuccess() {
        let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
        vc.timeTaken = secondsElapsed
        navigationController?.pushViewController(vc, animated: true)
    
}
  

}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CardCell",
            for: indexPath
        ) as! MatchTheCardCollectionViewCell

        if indexPath.item < cards.count {
            cell.configure(with: cards[indexPath.item])
            cell.alpha = 1.0
            cell.isUserInteractionEnabled = true
        } else {
            // Placeholder cell (keeps grid intact)
            cell.showEmpty()
            cell.alpha = 0.15   // or 0.0 if you want invisible
            cell.isUserInteractionEnabled = false
        }

        return cell
    }


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard indexPath.item < cards.count else { return }
        guard interactionsEnabled else { return }

        if cards[indexPath.item].isMatched || cards[indexPath.item].isFlipped {
            return
        }

        cards[indexPath.item].isFlipped = true
        collectionView.reloadItems(at: [indexPath])

        if firstIndex == nil {
            firstIndex = indexPath
        } else {
            secondIndex = indexPath
            interactionsEnabled = false
            checkMatch()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let columns: CGFloat = 4
        let spacing: CGFloat = 12
        let horizontalInsets: CGFloat = 24 // 12 left + 12 right

        let totalSpacing = spacing * (columns - 1)
        let availableWidth =
            collectionView.bounds.width - totalSpacing - horizontalInsets

        let side = floor(availableWidth / columns)
        return CGSize(width: side, height: side)
    }




    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12
    }

    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        12
    }

}
