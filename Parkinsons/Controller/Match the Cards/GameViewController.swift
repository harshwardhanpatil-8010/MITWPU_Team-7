//import UIKit
//
//class GameViewController: UIViewController {
//
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    var selectedDate: Date!
//    var level: Int = 1
//
//    private var cards: [Card] = []
//    private var rows: Int = 0
//    private var columns: Int = 0
//
//    private var firstIndex: IndexPath?
//    private var secondIndex: IndexPath?
//    private var matchedPairs = 0
//    private var interactionsEnabled = true
//
//    private var timer: Timer?
//    private var secondsElapsed = 0
//
//    private let spacing: CGFloat = 12
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let nib = UINib(nibName: "MatchTheCardCollectionViewCell", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: "CardCell")
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.isScrollEnabled = false
//
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = spacing
//        layout.minimumInteritemSpacing = spacing
//        layout.estimatedItemSize = .zero
//        collectionView.collectionViewLayout = layout
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        startGame()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        updateLayout()
//    }
//
//    private func startGame() {
//        generateCards()
//        collectionView.reloadData()
//        revealCards()
//        startTimer()
//    }
//
//    private func gridForLevel(_ level: Int) -> (Int, Int) {
//        switch level {
//        case 1...3: return (2, 3)
//        case 4...6: return (2, 4)
//        case 7...9: return (3, 4)
//        case 10...12: return (4, 4)
//        case 13...15: return (3, 6)
//        case 16...18: return (4, 5)
//        case 19...21: return (4, 6)
//        case 22...24: return (5, 6)
//        case 25...27: return (5, 8)
//        default: return (6, 8)
//        }
//    }
//
//    private func generateCards() {
//        let symbols = [
//            "🤖","🔥","🌈","🐶","🚀","🍕","⚡️","🎧",
//            "🏖️","🌙","⭐️","🐰","🐢","🍎","🎈","🎉",
//            "🍀","🐠","🦋","🎮","🐸","🍩","🧠","🎯",
//            "🎲","🧩","🎵","🚴","🛸","🌋","🍔","🥑"
//        ]
//
//        let grid = gridForLevel(level)
//        rows = grid.0
//        columns = grid.1
//
//        let totalCards = rows * columns
//        let pairCount = totalCards / 2
//
//        var temp: [Card] = []
//        for i in 0..<pairCount {
//            temp.append(Card(identifier: i, content: symbols[i]))
//            temp.append(Card(identifier: i, content: symbols[i]))
//        }
//
//        cards = temp.shuffled()
//        matchedPairs = 0
//    }
//
//    private func updateLayout() {
//        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
//
//        let width = collectionView.bounds.width
//        let height = collectionView.bounds.height
//
//        let cellWidth = (width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
//        let cellHeight = (height - CGFloat(rows - 1) * spacing) / CGFloat(rows)
//
//        let side = floor(min(cellWidth, cellHeight))
//
//        let contentWidth = CGFloat(columns) * side + CGFloat(columns - 1) * spacing
//        let contentHeight = CGFloat(rows) * side + CGFloat(rows - 1) * spacing
//
//        let insetX = max(0, (width - contentWidth) / 2)
//        let insetY = max(0, (height - contentHeight) / 2)
//
//        layout.itemSize = CGSize(width: side, height: side)
//        layout.sectionInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
//
//        layout.invalidateLayout()
//    }
//
//    private func startTimer() {
//        secondsElapsed = 0
//        timeLabel.text = "0s"
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            self.secondsElapsed += 1
//            self.timeLabel.text = "\(self.secondsElapsed)s"
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//    }
//
//    private func revealCards() {
//        interactionsEnabled = false
//        for i in cards.indices { cards[i].isFlipped = true }
//        collectionView.reloadData()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            for i in self.cards.indices { self.cards[i].isFlipped = false }
//            self.collectionView.reloadData()
//            self.interactionsEnabled = true
//        }
//    }
//
//    private func checkMatch() {
//        guard let i1 = firstIndex, let i2 = secondIndex else { return }
//
//        if cards[i1.item].identifier == cards[i2.item].identifier {
//            cards[i1.item].isMatched = true
//            cards[i2.item].isMatched = true
//            matchedPairs += 1
//            resetSelection()
//
//            if matchedPairs == cards.count / 2 {
//                stopTimer()
//                DailyGameManager.shared.markCompleted(date: selectedDate)
//                goToSuccess()
//            }
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.cards[i1.item].isFlipped = false
//                self.cards[i2.item].isFlipped = false
//                self.collectionView.reloadItems(at: [i1, i2])
//                self.resetSelection()
//            }
//        }
//    }
//
//    private func resetSelection() {
//        firstIndex = nil
//        secondIndex = nil
//        interactionsEnabled = true
//    }
//
//    private func goToSuccess() {
//        let vc = storyboard!.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
//        vc.timeTaken = secondsElapsed
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        cards.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! MatchTheCardCollectionViewCell
//        cell.configure(with: cards[indexPath.item])
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        guard interactionsEnabled else { return }
//        if cards[indexPath.item].isMatched || cards[indexPath.item].isFlipped { return }
//
//        cards[indexPath.item].isFlipped = true
//        collectionView.reloadItems(at: [indexPath])
//
//        if firstIndex == nil {
//            firstIndex = indexPath
//        } else {
//            secondIndex = indexPath
//            interactionsEnabled = false
//            checkMatch()
//        }
//    }
//}


//Height increases on the basis of grid

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var selectedDate: Date!
    var level: Int = 1

    private var cards: [Card] = []
    private var rows: Int = 0
    private var columns: Int = 0

    private var firstIndex: IndexPath?
    private var secondIndex: IndexPath?
    private var matchedPairs = 0
    private var interactionsEnabled = true

    private var timer: Timer?
    private var secondsElapsed = 0

    private let spacing: CGFloat = 12

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "lightbulb"),
            style: .plain,
            target: self,
            action: #selector(showHint)
        )

        let nib = UINib(nibName: "MatchTheCardCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CardCell")

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.estimatedItemSize = .zero
        collectionView.collectionViewLayout = layout
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func startGame() {
        generateCards()
        collectionView.reloadData()
        revealCards()
        startTimer()
    }

    private func gridForLevel(_ level: Int) -> (Int, Int) {
        switch level {
        case 1...3: return (2, 3)
        case 4...6: return (2, 4)
        case 7...9: return (3, 4)
        case 10...12: return (4, 4)
        case 13...15: return (3, 6)
        case 16...18: return (4, 5)
        case 19...21: return (4, 6)
        case 22...24: return (5, 6)
        case 25...27: return (5, 8)
        default: return (6, 8)
        }
    }

    private func generateCards() {
        let symbols = [
            "🤖","🔥","🌈","🐶","🚀","🍕","⚡️","🎧",
            "🏖️","🌙","⭐️","🐰","🐢","🍎","🎈","🎉",
            "🍀","🐠","🦋","🎮","🐸","🍩","🧠","🎯",
            "🎲","🧩","🎵","🚴","🛸","🌋","🍔","🥑"
        ]

        let grid = gridForLevel(level)
        rows = grid.0
        columns = grid.1

        let totalCards = rows * columns
        let pairCount = totalCards / 2

        var temp: [Card] = []
        for i in 0..<pairCount {
            temp.append(Card(identifier: i, content: symbols[i]))
            temp.append(Card(identifier: i, content: symbols[i]))
        }

        cards = temp.shuffled()
        matchedPairs = 0
    }

    private func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let width = collectionView.bounds.width
        let height = collectionView.bounds.height

        let totalHorizontalSpacing = CGFloat(columns - 1) * spacing
        let totalVerticalSpacing = CGFloat(rows - 1) * spacing

        let cellWidth = floor((width - totalHorizontalSpacing) / CGFloat(columns))
        let cellHeight = floor((height - totalVerticalSpacing) / CGFloat(rows))

        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.sectionInset = .zero

        layout.invalidateLayout()
    }

    private func startTimer() {
        secondsElapsed = 0
        timeLabel.text = "0s"
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.secondsElapsed += 1
            self.timeLabel.text = "\(self.secondsElapsed)s"
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    private func revealCards() {
        interactionsEnabled = false
        for i in cards.indices { cards[i].isFlipped = true }
        collectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for i in self.cards.indices { self.cards[i].isFlipped = false }
            self.collectionView.reloadData()
            self.interactionsEnabled = true
        }
    }

    @objc private func showHint() {
        guard interactionsEnabled else { return }

        let unmatched = cards.enumerated().filter { !$0.element.isMatched }
        guard unmatched.count >= 2 else { return }

        let groups = Dictionary(grouping: unmatched, by: { $0.element.identifier })
        guard let pair = groups.values.first(where: { $0.count == 2 }) else { return }

        let first = pair[0].offset
        let second = pair[1].offset

        interactionsEnabled = false

        cards[first].isFlipped = true
        cards[second].isFlipped = true

        collectionView.reloadItems(at: [
            IndexPath(item: first, section: 0),
            IndexPath(item: second, section: 0)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.cards[first].isMatched = true
            self.cards[second].isMatched = true
            self.matchedPairs += 1
            self.collectionView.reloadItems(at: [
                IndexPath(item: first, section: 0),
                IndexPath(item: second, section: 0)
            ])
            self.interactionsEnabled = true

            if self.matchedPairs == self.cards.count / 2 {
                self.stopTimer()
                DailyGameManager.shared.markCompleted(date: self.selectedDate)
                self.goToSuccess()
            }
        }
    }

    private func checkMatch() {
        guard let i1 = firstIndex, let i2 = secondIndex else { return }

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
        let vc = storyboard!.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
        vc.timeTaken = secondsElapsed
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! MatchTheCardCollectionViewCell
        cell.configure(with: cards[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard interactionsEnabled else { return }
        if cards[indexPath.item].isMatched || cards[indexPath.item].isFlipped { return }

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
}
