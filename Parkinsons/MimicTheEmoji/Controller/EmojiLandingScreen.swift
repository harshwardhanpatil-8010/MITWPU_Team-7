import UIKit
extension Notification.Name {
    static let didUpdateGameCompletion = Notification.Name("didUpdateGameCompletion")
}
class EmojiLandingScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var monthAndYearOutlet: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var completedLabel: UILabel!
    // MARK: - Properties
    // Match Code 1: Force Gregorian and Monday start (2)
    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }()

    private let today = Calendar(identifier: .gregorian).startOfDay(for: Date())
    private var firstDayOfMonth: Date!
    private var daysInMonth = 0
    private var firstWeekdayOffset = 0
    private var selectedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(refreshUI),
                name: .didUpdateGameCompletion,
                object: nil
            )
        
        updateCompletionCount()
        collectionView.reloadData()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        setupMonth()
        configureLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    // EmojiLandingScreen.swift
    @objc private func refreshUI() {
        updateCompletionCount()
        collectionView.reloadData()
    }
    private func updateCompletionCount() {
            let completedCount = (0..<daysInMonth).filter { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
                return EmojiGameManager.shared.isCompleted(date: calendar.startOfDay(for: date))
            }.count

            completedLabel.text = "\(completedCount)/\(daysInMonth) Completed"
        }
    
    private func configureLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = collectionView.bounds.width / 7
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }

    private func setupMonth() {
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)

        firstDayOfMonth = calendar.date(from: comps)!
        daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count

        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        firstWeekdayOffset = (weekday - calendar.firstWeekday + 7) % 7

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthAndYearOutlet.text = formatter.string(from: firstDayOfMonth)

        selectedDate = today
        collectionView.reloadData()
    }

    // MARK: - CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth + firstWeekdayOffset
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        
        guard indexPath.item >= firstWeekdayOffset else {
            cell.configureEmpty()
            return cell
        }

        let day = indexPath.item - firstWeekdayOffset + 1
        let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        let cellDate = calendar.startOfDay(for: date)

        let isToday = calendar.isDate(cellDate, inSameDayAs: today)
        let isFuture = cellDate > today
        let isSelected = selectedDate.map { calendar.isDate(cellDate, inSameDayAs: $0) } ?? false

        
        let isCompleted = EmojiGameManager.shared.isCompleted(date: cellDate)
        
        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isCompleted: isCompleted, 
            showTodayOutline: isToday && !isSelected,
            enabled: !isFuture
        )

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item >= firstWeekdayOffset else { return }

        let day = indexPath.item - firstWeekdayOffset + 1
        let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        let cellDate = calendar.startOfDay(for: date)

        // Block future dates like Code 1
        guard cellDate <= today else { return }

        selectedDate = cellDate
        collectionView.reloadData()
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "MimicTheEmoji", bundle: nil)
        guard let gameVC = storyboard.instantiateViewController(withIdentifier: "EmojiGameViewController") as? EmojiGameViewController else { return }
        
        // Pass the selected date to the game
        gameVC.selectedDate = selectedDate
        
        if let nav = self.navigationController {
            nav.pushViewController(gameVC, animated: true)
        } else {
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
}
