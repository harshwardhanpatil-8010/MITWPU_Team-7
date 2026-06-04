import UIKit

class WhackAMoleLandingViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let iconImageView = UIImageView()
    private let moleHoleImageView = UIImageView()
    private let dailyChallengeLabel = UILabel()
    private let calendarContainerView = UIView()
    private let monthLabel = UILabel()
    private let completedLabel = UILabel()
    private let completedStackView = UIStackView()
    private let completedIconView = UIImageView()
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

    private let themeColor = UIColor(hex: "#D4B15A")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Whack a Mole"
        setupInfoButton()
        setupUI()
        setupMonth()
        updateCompletionCount()
        addGradientOverlay()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        // Game icon
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .medium)
        iconImageView.image = UIImage(systemName: "hammer.fill", withConfiguration: config)
        iconImageView.tintColor = themeColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconImageView)

        let holeConfig = UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)
        moleHoleImageView.image = UIImage(systemName: "oval.fill", withConfiguration: holeConfig)
        moleHoleImageView.tintColor = themeColor
        moleHoleImageView.contentMode = .scaleToFill
        moleHoleImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(moleHoleImageView)

        // "Daily Challenge" label
        dailyChallengeLabel.text = "Daily Challenge"
        dailyChallengeLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        dailyChallengeLabel.numberOfLines = 0
        dailyChallengeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dailyChallengeLabel)

        calendarContainerView.backgroundColor = .systemBackground
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarContainerView)

        // Month + Completed row
        monthLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(monthLabel)

        completedIconView.image = UIImage(systemName: "checkmark.circle.fill")
        completedIconView.tintColor = .white
        completedIconView.contentMode = .scaleAspectFit
        completedIconView.translatesAutoresizingMaskIntoConstraints = false

        completedLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        completedLabel.textColor = .label
        completedLabel.textAlignment = .natural
        completedLabel.translatesAutoresizingMaskIntoConstraints = false

        completedStackView.axis = .horizontal
        completedStackView.alignment = .center
        completedStackView.spacing = 0
        completedStackView.translatesAutoresizingMaskIntoConstraints = false
        completedStackView.addArrangedSubview(completedIconView)
        completedStackView.addArrangedSubview(completedLabel)
        calendarContainerView.addSubview(completedStackView)

        // Day headers (Mon Tue Wed ...)
        dayHeaderStack.axis = .horizontal
        dayHeaderStack.distribution = .equalCentering
        dayHeaderStack.isBaselineRelativeArrangement = true
        dayHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for name in dayNames {
            let lbl = UILabel()
            lbl.text = name
            lbl.font = .systemFont(ofSize: 17, weight: .regular)
            lbl.textColor = .systemGray
            lbl.textAlignment = .center
            dayHeaderStack.addArrangedSubview(lbl)
        }
        calendarContainerView.addSubview(dayHeaderStack)

        // Collection View
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(collectionView)

        var btnConfig = UIButton.Configuration.filled()
        btnConfig.title = "Play"
        btnConfig.baseBackgroundColor = .systemBlue
        btnConfig.baseForegroundColor = .white
        btnConfig.cornerStyle = .capsule
        playButton.configuration = btnConfig
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)

        NSLayoutConstraint.activate([
            // Icon
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.5),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 140),
            iconImageView.widthAnchor.constraint(equalToConstant: 180),

            moleHoleImageView.widthAnchor.constraint(equalToConstant: 105),
            moleHoleImageView.heightAnchor.constraint(equalToConstant: 18),
            moleHoleImageView.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 0),
            moleHoleImageView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: -8),

            // Daily Challenge
            dailyChallengeLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 32.5),
            dailyChallengeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dailyChallengeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            calendarContainerView.topAnchor.constraint(equalTo: dailyChallengeLabel.bottomAnchor, constant: 3),
            calendarContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            calendarContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            calendarContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -46),

            // Month label
            monthLabel.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: 16),

            // Completed label
            completedStackView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor, constant: 1),
            completedStackView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -16),
            completedIconView.widthAnchor.constraint(equalToConstant: 16),
            completedIconView.heightAnchor.constraint(equalToConstant: 16),

            // Day headers
            dayHeaderStack.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 2),
            dayHeaderStack.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: 16),
            dayHeaderStack.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -16),

            // Calendar
            collectionView.topAnchor.constraint(equalTo: dayHeaderStack.bottomAnchor, constant: 3.33),
            collectionView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarContainerView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 50),

            // Play button
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 178),
            playButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
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
