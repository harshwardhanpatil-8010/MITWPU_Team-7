#!/usr/bin/env ruby
require 'xcodeproj'

PROJECT_PATH = 'ParkEase.xcodeproj'
TARGET_NAME  = 'ParkEase'
PARKINSONS   = 'Parkinsons'

project = Xcodeproj::Project.open(PROJECT_PATH)
target  = project.targets.find { |t| t.name == TARGET_NAME }

# Files that need to be added — created after the initial project sync
new_files = [
  'Parkinsons/JigsawPuzzle/Models/PuzzlePiece.swift',
  'Parkinsons/JigsawPuzzle/ViewModels/PuzzleViewModel.swift',
  'Parkinsons/JigsawPuzzle/Services/PuzzleGeneratorService.swift',
  'Parkinsons/JigsawPuzzle/Services/HapticService.swift',
  'Parkinsons/JigsawPuzzle/Views/PuzzleHomeView.swift',
  'Parkinsons/JigsawPuzzle/Views/PuzzleGameView.swift',
  'Parkinsons/JigsawPuzzle/Views/PuzzleBoardView.swift',
  'Parkinsons/JigsawPuzzle/Views/PuzzlePreviewOverlay.swift',
  'Parkinsons/JigsawPuzzle/Views/PuzzlePieceShape.swift',
]

# Find or create the JigsawPuzzle group under Parkinsons
def find_or_create_group(parent, name)
  parent.groups.find { |g| g.name == name || g.path == name } ||
    parent.new_group(name, name)
end

# Navigate to the right group for a file path like
# 'Parkinsons/JigsawPuzzle/Models/PuzzlePiece.swift'
def group_for_path(project, path_parts)
  # path_parts: ['Parkinsons', 'JigsawPuzzle', 'Models']
  group = project.main_group
  path_parts.each do |part|
    group = find_or_create_group(group, part)
  end
  group
end

added = 0
new_files.each do |rel_path|
  # Skip if already referenced
  already = project.files.any? { |f| f.real_path.to_s.end_with?(rel_path) rescue false }
  if already
    puts "  already in project: #{rel_path}"
    next
  end

  parts     = rel_path.split('/')
  file_name = parts.last
  dir_parts = parts[0..-2]

  group = group_for_path(project, dir_parts)

  # Add file reference
  file_ref = group.new_file(file_name)
  file_ref.path = file_name
  file_ref.source_tree = '<group>'

  # Add to target's Sources build phase
  phase = target.source_build_phase
  unless phase.files_references.any? { |r| r == file_ref }
    phase.add_file_reference(file_ref)
  end

  added += 1
  puts "  added: #{rel_path}"
end

project.save
puts "Done — #{added} file(s) added to #{PROJECT_PATH}"
