import UIKit

extension Notification.Name {
    static let didUpdateGameCompletion = Notification.Name("didUpdateGameCompletion")
}

class EmojiLandingScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var monthAndYearOutlet: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var completedLabel: UILabel!

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

        setupInfoButton()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshUI),
            name: .didUpdateGameCompletion,
            object: nil
        )

        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        setupMonth()
        updateCompletionCount()

        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        view.layer.addSublayer(gradient)

        configureLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true

        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)

        view.layer.addSublayer(gradient)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
    }

    private func setupInfoButton() {

        let infoButton = UIButton(type: .system)

        let config = UIImage.SymbolConfiguration(
            pointSize: 18,
            weight: .semibold
        )

        let image = UIImage(
            systemName: "questionmark.circle",
            withConfiguration: config
        )

        infoButton.setImage(image, for: .normal)

        infoButton.tintColor = .label

        infoButton.addTarget(
            self,
            action: #selector(openInfoScreen),
            for: .touchUpInside
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: infoButton
        )
    }

    @objc private func openInfoScreen() {

        let storyboard = UIStoryboard(
            name: "MimicTheEmoji",
            bundle: nil
        )

        guard let infoVC = storyboard.instantiateViewController(
            withIdentifier: "InfoMimicTheEmojiViewController"
        ) as? InfoMimicTheEmojiViewController else {

            print("Failed to load InfoMimicTheEmojiViewController")
            return
        }

        infoVC.modalPresentationStyle = .pageSheet

        present(infoVC, animated: true)
    }

    @objc private func refreshUI() {

        updateCompletionCount()
        collectionView.reloadData()
    }

    private func updateCompletionCount() {

        let completedCount = (0..<daysInMonth).filter { offset in

            guard let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: firstDayOfMonth
            ) else {
                return false
            }

            return EmojiGameManager.shared.isCompleted(
                date: calendar.startOfDay(for: date)
            )

        }.count

        completedLabel.text = "\(completedCount)/\(daysInMonth) Completed"
    }

    private func configureLayout() {

        guard let layout = collectionView.collectionViewLayout
                as? UICollectionViewFlowLayout else {
            return
        }

        let size = collectionView.bounds.width / 7

        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero
    }

    private func setupMonth() {

        let now = Date()

        let comps = calendar.dateComponents(
            [.year, .month],
            from: now
        )

        firstDayOfMonth = calendar.date(from: comps)!

        daysInMonth = calendar.range(
            of: .day,
            in: .month,
            for: firstDayOfMonth
        )!.count

        let weekday = calendar.component(
            .weekday,
            from: firstDayOfMonth
        )

        firstWeekdayOffset = (
            weekday - calendar.firstWeekday + 7
        ) % 7

        let formatter = DateFormatter()

        formatter.dateFormat = "MMMM yyyy"

        monthAndYearOutlet.text = formatter.string(
            from: firstDayOfMonth
        )

        selectedDate = today

        collectionView.reloadData()
    }

    private var navGradientOverlay: CAGradientLayer {

        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor(hex: "FF9500")
                .withAlphaComponent(0.30)
                .cgColor,

            UIColor(hex: "FF9500")
                .withAlphaComponent(0.0)
                .cgColor
        ]

        gradient.startPoint = CGPoint(x: 0.5, y: 0)

        gradient.endPoint = CGPoint(x: 0.5, y: 1)

        return gradient
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return daysInMonth + firstWeekdayOffset
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DateCell",
            for: indexPath
        ) as! DateCell

        guard indexPath.item >= firstWeekdayOffset else {

            cell.configureEmpty()
            return cell
        }

        let day = indexPath.item - firstWeekdayOffset + 1

        let date = calendar.date(
            byAdding: .day,
            value: day - 1,
            to: firstDayOfMonth
        )!

        let cellDate = calendar.startOfDay(for: date)

        let isToday = calendar.isDate(
            cellDate,
            inSameDayAs: today
        )

        let isFuture = cellDate > today

        let isSelected = selectedDate.map {
            calendar.isDate(cellDate, inSameDayAs: $0)
        } ?? false

        let isCompleted = EmojiGameManager.shared.isCompleted(
            date: cellDate
        )

        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isCompleted: isCompleted,
            showTodayOutline: isToday && !isSelected,
            enabled: !isFuture,
            themeColor: UIColor(hex: "FF9500")
        )

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        guard indexPath.item >= firstWeekdayOffset else {
            return
        }

        let day = indexPath.item - firstWeekdayOffset + 1

        let date = calendar.date(
            byAdding: .day,
            value: day - 1,
            to: firstDayOfMonth
        )!

        let cellDate = calendar.startOfDay(for: date)

        guard cellDate <= today else {
            return
        }

        selectedDate = cellDate

        collectionView.reloadData()
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let date = selectedDate else { return }

        if EmojiGameManager.shared.isCompleted(date: date) {
            let alert = UIAlertController(
                title: "Challenge Completed",
                message: "You have already completed this daily challenge. Do you want to play again?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                self.navigateToGame(with: date)
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            present(alert, animated: true)
        } else {
            navigateToGame(with: date)
        }
    }

    private func navigateToGame(with date: Date) {
        let storyboard = UIStoryboard(
            name: "MimicTheEmoji",
            bundle: nil
        )

        guard let gameVC = storyboard.instantiateViewController(
            withIdentifier: "EmojiGameViewController"
        ) as? EmojiGameViewController else {
            return
        }

        gameVC.selectedDate = date

        if let nav = self.navigationController {
            nav.pushViewController(gameVC, animated: true)
        } else {
            gameVC.modalPresentationStyle = .fullScreen
            present(gameVC, animated: true)
        }
    }
}
