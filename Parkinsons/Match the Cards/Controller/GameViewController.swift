
import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var selectedDate: Date!
    var level: Int = 1

    private var cards: [Card] = []
    private var rows = 0
    private var columns = 0

    private var firstIndex: IndexPath?
    private var secondIndex: IndexPath?
    private var matchedPairs = 0
    private var interactionsEnabled = true

    private var timer: Timer?
    private var secondsElapsed = 0

    private let spacing: CGFloat = 12

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupCollectionView() {
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
        case 10...12: return (3, 6)
        case 13...15: return (4, 5)
        case 16...18: return (5, 6)
        default: return (6, 6)
        }
    }

    private func generateCards() {
        let symbols = [
            "🤖","🔥","🌈","🐶","🚀","🍕","⚡️","🎧",
            "🏖️","🌙","⭐️","🐰","🐢","🍎","🎈","🎉",
            "🍀","🐠","🦋","🎮","🐸","🍩","🧠","🎯",
            "🎲","🧩","🎵","🚴","🛸","🌋","🍔","🥑",
            "❤️","🧤","🌸"
        ]

        let grid = gridForLevel(level)
        rows = grid.0
        columns = grid.1

        let totalCards = rows * columns
        let pairCount = totalCards / 2

        cards = (0..<pairCount).flatMap {
            [Card(identifier: $0, content: symbols[$0]),
             Card(identifier: $0, content: symbols[$0])]
        }.shuffled()

        matchedPairs = 0
    }

    private func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let width = collectionView.bounds.width
        let height = collectionView.bounds.height

        let hSpacing = CGFloat(columns - 1) * spacing
        let vSpacing = CGFloat(rows - 1) * spacing

        layout.itemSize = CGSize(
            width: floor((width - hSpacing) / CGFloat(columns)),
            height: floor((height - vSpacing) / CGFloat(rows))
        )
        layout.sectionInset = .zero
        layout.invalidateLayout()
    }

    private func startTimer() {
        secondsElapsed = 0
        updateTimeLabel()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1
            self?.updateTimeLabel()
        }
    }

    private func runTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1
            self?.updateTimeLabel()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    private func updateTimeLabel() {
        timeLabel.text = "Time: \(secondsElapsed)s"
    }

    private func revealCards() {
        interactionsEnabled = false
        cards.indices.forEach { cards[$0].isFlipped = true }
        collectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.cards.indices.forEach { self.cards[$0].isFlipped = false }
            self.collectionView.reloadData()
            self.interactionsEnabled = true
        }
    }

    @IBAction func hintButtonTapped(_ sender: Any) {
        guard interactionsEnabled, matchedPairs < cards.count / 2 else { return }

        let unmatched = cards.enumerated().filter { !$0.element.isMatched }
        let groups = Dictionary(grouping: unmatched, by: { $0.element.identifier })
        guard let pair = groups.values.first(where: { $0.count == 2 }) else { return }

        let first = pair[0].offset
        let second = pair[1].offset
        let indexPaths = [IndexPath(item: first, section: 0),
                          IndexPath(item: second, section: 0)]

        interactionsEnabled = false
        cards[first].isFlipped = true
        cards[second].isFlipped = true
        collectionView.reloadItems(at: indexPaths)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.cards[first].isMatched = true
            self.cards[second].isMatched = true
            self.matchedPairs += 1
            self.collectionView.reloadItems(at: indexPaths)
            self.resetSelection()

            if self.matchedPairs == self.cards.count / 2 {
                self.stopTimer()
                DailyGameManager.shared.markCompleted(date: self.selectedDate)
                self.goToSuccess()
            }
        }
    }

    @IBAction func quitButtonTapped(_ sender: Any) {
        stopTimer()
        let previousState = interactionsEnabled
        interactionsEnabled = false

        let alert = UIAlertController(
            title: "Quit Game?",
            message: "Are you sure you want to quit? Your progress will not be saved.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        })

        alert.addAction(UIAlertAction(title: "Resume", style: .cancel) { _ in
            self.interactionsEnabled = previousState
            self.runTimer()
        })

        present(alert, animated: true)
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
        let vc = storyboard!.instantiateViewController(
            withIdentifier: "SuccessViewController"
        ) as! SuccessViewController
        vc.timeTaken = secondsElapsed
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        cards.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CardCell",
            for: indexPath
        ) as! MatchTheCardCollectionViewCell
        cell.configure(with: cards[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard interactionsEnabled else { return }
        guard !cards[indexPath.item].isMatched,
              !cards[indexPath.item].isFlipped else { return }

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

