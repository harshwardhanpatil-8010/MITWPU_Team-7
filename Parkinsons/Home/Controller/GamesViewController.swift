import UIKit

class GamesViewController: UIViewController {

    private var collectionView: UICollectionView!

    let therapeuticGamesData: [TherapeuticGameModel] = [
        TherapeuticGameModel(title: "Mimic the Emoji", description: "Complete your daily challenge!", iconName: "face.smiling", iconColor: .systemOrange),
        TherapeuticGameModel(title: "Match the Cards", description: "Complete your daily challenge!", iconName: "brain.fill", iconColor: .systemPurple),
        TherapeuticGameModel(title: "StillSphere", description: "Complete your daily challenge!", iconName: "gyroscope", iconColor: .systemGreen)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        setupNavigationBar()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarAppearance()
        collectionView.reloadData()
    }

    private func setupNavigationBarAppearance() {
        let scrollAppearance = UINavigationBarAppearance()
        scrollAppearance.configureWithTransparentBackground()
        scrollAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: UIColor.label
        ]

        let titleString = "Therapeutic Games"
        let font = UIFont.systemFont(ofSize: 32, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let titleSize = titleString.size(withAttributes: attributes)
        
        let screenWidth = UIScreen.main.bounds.width
        let offset = -(screenWidth / 2) + (titleSize.width / 2) + 16
        scrollAppearance.titlePositionAdjustment = UIOffset(horizontal: offset, vertical: 0)

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        standardAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = scrollAppearance
    }

    private func setupNavigationBar() {
        title = "Therapeutic Games"
        
        let infoImage = UIImage(systemName: "info.circle")
        let infoButton = UIBarButtonItem(image: infoImage, style: .plain, target: self, action: #selector(showGamesInfoPopup))
        infoButton.tintColor = .black
        navigationItem.rightBarButtonItem = infoButton
    }

    @objc private func showGamesInfoPopup() {
        let alert = UIAlertController(
            title: "Therapeutic Games",
            message: "Daily games to enhance memory, focus and facial movement for people with Parkinson's disease. Mimic the Emoji boosts facial expression by copying emojis. Match the Cards improves memory and attention. StillSphere sharpens reaction time and hand-eye coordination. Play regularly to keep your mind active!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        self.present(alert, animated: true)
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        collectionView.dataSource = self
        collectionView.delegate = self

        // Register TherapeuticGameCell from the xib in Home/View
        collectionView.register(UINib(nibName: "TherapeuticGameCell", bundle: nil), forCellWithReuseIdentifier: "therapeutic_game_cell")
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
            section.interGroupSpacing = 10
            return section
        }
        return layout
    }

    private func handleGamesSelection(at row: Int) {
        switch row {
        case 2:
            let storyboard = UIStoryboard(name: "StillSphere", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "StillSphereLandingViewController") as? StillSphereLandingViewController else { return }
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as? LevelSelectionViewController else { return }
            navigationController?.pushViewController(vc, animated: true)
        case 0:
            let storyboard = UIStoryboard(name: "MimicTheEmoji", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "EmojiLandingScreenID") as? EmojiLandingScreen else { return }
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension GamesViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return therapeuticGamesData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "therapeutic_game_cell", for: indexPath) as! TherapeuticGameCell
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        let firstDayOfMonth = calendar.date(from: comps)!
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        let today = calendar.startOfDay(for: now)
        let completionText: String
        let isTodayCompleted: Bool

        switch indexPath.item {
        case 0:
            let completedCount = (0..<daysInMonth).filter { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
                return EmojiGameManager.shared.isCompleted(date: calendar.startOfDay(for: date))
            }.count
            completionText = "\(completedCount)/\(daysInMonth) daily challenges completed"
            isTodayCompleted = EmojiGameManager.shared.isCompleted(date: today)
        case 1:
            let completedCount = (0..<daysInMonth).filter { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
                return DailyGameManager.shared.isCompleted(date: calendar.startOfDay(for: date))
            }.count
            completionText = "\(completedCount)/\(daysInMonth) daily challenges completed"
            isTodayCompleted = DailyGameManager.shared.isCompleted(date: today)
        case 2:
            let completedCount = (0..<daysInMonth).filter { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
                return StillSphereManager.shared.isCompleted(date: calendar.startOfDay(for: date))
            }.count
            completionText = "\(completedCount)/\(daysInMonth) daily challenges completed"
            isTodayCompleted = StillSphereManager.shared.isCompleted(date: today)
        default:
            completionText = ""
            isTodayCompleted = false
        }
        cell.configure(with: therapeuticGamesData[indexPath.item], completionText: completionText, isTodayCompleted: isTodayCompleted)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleGamesSelection(at: indexPath.item)
    }
}
