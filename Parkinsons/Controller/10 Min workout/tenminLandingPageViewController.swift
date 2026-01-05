//
//  tenminLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class tenminLandingPageViewController: UIViewController {
    var exercises: [Exercise] = []
    @IBOutlet weak var UICollectionViewOutlet: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        exercises = WorkoutManager.shared.getTodayWorkout()
        // Do any additional setup after loading the view.
        registerCells()
    }
    
   
    
func registerCells() {
        
        UICollectionViewOutlet.register(UINib(nibName: "ExerciseListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "exerciseList_cell")
    }
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, env in
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            if section == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                return section
            } else if section == 1 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                return section
            } else {
                
            }
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

}

extension tenminLandingPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exerciseList_cell", for: indexPath) as! ExerciseListCollectionViewCell
        cell.configureExercise(exercise: Exercise, state: )
        return cell
    }
    
    
}
