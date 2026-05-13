import UIKit

class WhackAMoleLandingViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let iconImageView = UIImageView()
    private let dailyChallengeLabel = UILabel()
    private let monthLabel = UILabel()
    private let completedLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private var collectionView: UICollectionView!
    private let dayHeaderStack = UIStackView()

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

    private let themeColor = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Whack-a-Mole"
        setupInfoButton()
        setupUI()
        setupMonth()
        updateCompletionCount()
        addGradientOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        updateCompletionCount()
        collectionView.reloadData()
        addGradientOverlay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - UI Setup

    private func setupUI() {

        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .medium)
        iconImageView.image = UIImage(systemName: "hand.tap.fill", withConfiguration: config)
        iconImageView.tintColor = themeColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconImageView)

        dailyChallengeLabel.text = "Daily Challenge"
        dailyChallengeLabel.font = .systemFont(ofSize: 22, weight: .bold)
        dailyChallengeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dailyChallengeLabel)

        monthLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(monthLabel)

        completedLabel.font = .systemFont(ofSize: 15, weight: .medium)
        completedLabel.textColor = .secondaryLabel
        completedLabel.textAlignment = .right
        completedLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completedLabel)

        dayHeaderStack.axis = .horizontal
        dayHeaderStack.distribution = .fillEqually
        dayHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for name in dayNames {
            let lbl = UILabel()
            lbl.text = name
            lbl.font = .systemFont(ofSize: 13, weight: .medium)
            lbl.textColor = .secondaryLabel
            lbl.textAlignment = .center
            dayHeaderStack.addArrangedSubview(lbl)
        }
        view.addSubview(dayHeaderStack)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        var btnConfig = UIButton.Configuration.filled()
        btnConfig.title = "Play"
        btnConfig.baseBackgroundColor = .systemBlue
        btnConfig.baseForegroundColor = .white
        btnConfig.cornerStyle = .capsule
        btnConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 60, bottom: 14, trailing: 60)
        playButton.configuration = btnConfig
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)

        NSLayoutConstraint.activate([

            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 130),
            iconImageView.widthAnchor.constraint(equalToConstant: 130),

            dailyChallengeLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            dailyChallengeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            monthLabel.topAnchor.constraint(equalTo: dailyChallengeLabel.bottomAnchor, constant: 4),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            completedLabel.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            completedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            dayHeaderStack.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 12),
            dayHeaderStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dayHeaderStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: dayHeaderStack.bottomAnchor, constant: 4),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 6.0/7.0),

            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }

    private func addGradientOverlay() {
        view.layer.sublayers?.removeAll(where: { $0.name == "whackGradient" })
        let gradient = CAGradientLayer()
        gradient.name = "whackGradient"
        gradient.colors = [
            themeColor.withAlphaComponent(0.30).cgColor,
            themeColor.withAlphaComponent(0.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupInfoButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "questionmark.circle", withConfiguration: config), for: .normal)
        btn.tintColor = .label
        btn.addTarget(self, action: #selector(openInfo), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }

    // MARK: - Month Setup

    private func setupMonth() {
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        firstDayOfMonth = calendar.date(from: comps)!
        daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count

        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        firstWeekdayOffset = (weekday - calendar.firstWeekday + 7) % 7

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: firstDayOfMonth)

        selectedDate = today
        collectionView.reloadData()
    }

    private func updateCompletionCount() {
        let stats = WhackAMoleGameManager.shared.completedCountThisMonth()
        completedLabel.text = "\(stats.completed)/\(stats.total) Completed"
    }

    // MARK: - Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        daysInMonth + firstWeekdayOffset
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
        let isCompleted = WhackAMoleGameManager.shared.isCompleted(date: cellDate)
        let isSelected = selectedDate.map { calendar.isDate(cellDate, inSameDayAs: $0) } ?? false

        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isCompleted: isCompleted,
            showTodayOutline: isToday && !isSelected,
            enabled: !isFuture,
            themeColor: themeColor
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let s = collectionView.bounds.width / 7
        return CGSize(width: s, height: s)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item >= firstWeekdayOffset else { return }
        let day = indexPath.item - firstWeekdayOffset + 1
        let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        let cellDate = calendar.startOfDay(for: date)
        guard cellDate <= today else { return }
        selectedDate = cellDate
        collectionView.reloadData()
    }

    // MARK: - Actions

    @objc private func playTapped() {
        guard let date = selectedDate else { return }

        if WhackAMoleGameManager.shared.isCompleted(date: date) {
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
        let gameVC = WhackAMoleGameViewController()
        gameVC.selectedDate = date
        navigationController?.pushViewController(gameVC, animated: true)
    }

    @objc private func openInfo() {
        let infoVC = InfoWhackAMoleViewController()
        infoVC.modalPresentationStyle = .pageSheet
        present(infoVC, animated: true)
    }
}
