# Implementation Plan

## Phase 1: Exploration Tests (BEFORE Fix)

- [ ] 1. Write bug condition exploration tests
  - **Property 1: Bug Condition** - Workout Flow Bug Conditions
  - **CRITICAL**: These tests MUST FAIL on unfixed code - failure confirms the bugs exist
  - **DO NOT attempt to fix the tests or the code when they fail**
  - **NOTE**: These tests encode the expected behavior - they will validate the fix when they pass after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bugs exist
  - **Scoped PBT Approach**: For deterministic bugs, scope the properties to the concrete failing cases to ensure reproducibility
  
  - [ ] 1.1 Timer Leak Test
    - Test that navigating exercise → rest → countdown → exercise results in only ONE active timer
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (multiple timers running simultaneously)
    - Document counterexamples found (e.g., "3 timers active after navigation sequence")
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3_
  
  - [~] 1.2 Skip During Revisit Test
    - Test that skip button is disabled when `isRevisitingSkipped` is true
    - Simulate entering revisit mode, then attempt to tap skip button
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (skip is allowed during revisit mode)
    - Document counterexamples found (e.g., "Skip button functional during revisit, creating infinite loop")
    - _Requirements: 1.4, 1.5, 2.4, 2.5_
  
  - [~] 1.3 Premature Done Test
    - Test that done button only allows completion after 80% of timer elapsed
    - Simulate tapping Done button on 60-second warmup after only 10 seconds
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (exercise marked complete at 10 seconds)
    - Document counterexamples found (e.g., "Done button marks 60s exercise complete after 10s")
    - _Requirements: 1.8, 2.8_
  
  - [~] 1.4 Rapid Done Tap Test
    - Test that done button can only be tapped once (no duplicates)
    - Simulate tapping Done button 3 times rapidly
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (3 completion records created)
    - Document counterexamples found (e.g., "Rapid taps create 3 duplicate completion records")
    - _Requirements: 1.9, 2.9_
  
  - [~] 1.5 Previous Button State Test
    - Test that previous button properly restores skipped state
    - Skip exercise #2, go to #3, tap Previous, verify exercise #2 shows as skipped
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (exercise #2 shows as not skipped)
    - Document counterexamples found (e.g., "Previous button loses skipped state")
    - _Requirements: 1.11, 2.11_
  
  - [~] 1.6 Rapid Navigation Test
    - Test that navigation guards prevent duplicate pushes
    - Rapidly tap Done button 5 times
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (5 rest screens pushed onto navigation stack)
    - Document counterexamples found (e.g., "Rapid taps push 5 duplicate view controllers")
    - _Requirements: 1.15, 2.15_
  
  - [~] 1.7 Progress Bar Revisit Test
    - Test that progress bars show correct colors during revisit mode
    - Enter revisit mode and check progress bar colors for skipped exercises
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (skipped exercises show blue instead of gray)
    - Document counterexamples found (e.g., "Skipped exercises show blue during revisit")
    - _Requirements: 1.18, 2.18_
  
  - [~] 1.8 All Exercises Skipped Test
    - Test that completion requires minimum 1 exercise completed
    - Skip all 10 exercises
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (completion screen shown with 0 exercises done)
    - Document counterexamples found (e.g., "Completion screen accessible with 0 exercises")
    - _Requirements: 1.31, 2.31_
  
  - [~] 1.9 Infinite Rest Test
    - Test that rest time has maximum limit
    - Tap Add Time button 20 times
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (rest time exceeds 300 seconds)
    - Document counterexamples found (e.g., "Rest time unlimited, reached 400+ seconds")
    - _Requirements: 1.29, 2.29_
  
  - [~] 1.10 Duplicate Feedback Test
    - Test that feedback buttons can only be tapped once
    - Tap Easy button 3 times rapidly
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (3 feedback records created)
    - Document counterexamples found (e.g., "Rapid taps create 3 duplicate feedback records")
    - _Requirements: 1.32, 2.32_

## Phase 2: Preservation Tests (BEFORE Fix)

- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Normal Workout Flow Preservation
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs (normal workout flows)
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  
  - [~] 2.1 Normal Completion Flow Test
    - Observe: Completing all 10 exercises in sequence works correctly on unfixed code
    - Write property-based test: for all normal sequential completions, navigation flow matches expected pattern
    - Verify test passes on UNFIXED code
    - _Requirements: 3.1, 3.2_
  
  - [~] 2.2 Video Playback Test
    - Observe: Exercise videos loop smoothly using AVPlayerLooper on unfixed code
    - Write property-based test: for all exercise video displays, looping is seamless
    - Verify test passes on UNFIXED code
    - _Requirements: 3.3_
  
  - [~] 2.3 Voice Instructions Test
    - Observe: Voice instructions play after 0.35 second delay on unfixed code
    - Write property-based test: for all exercise loads, voice plays after 0.35s delay
    - Verify test passes on UNFIXED code
    - _Requirements: 3.9, 3.10_
  
  - [~] 2.4 Progress Bars Normal Mode Test
    - Observe: Progress bars show blue for completed, partial for current, empty for upcoming on unfixed code
    - Write property-based test: for all normal mode exercises, progress bar colors match expected pattern
    - Verify test passes on UNFIXED code
    - _Requirements: 3.4, 3.5, 3.6_
  
  - [~] 2.5 Timer Display Test
    - Observe: Timer-based exercises show countdown in "XX" format, rep-based show "-" on unfixed code
    - Write property-based test: for all exercise types, timer display format is correct
    - Verify test passes on UNFIXED code
    - _Requirements: 3.7, 3.8_
  
  - [~] 2.6 Workout Persistence Test
    - Observe: Workout state is saved using WorkoutManager.syncSessionPersistence() on unfixed code
    - Write property-based test: for all exercise completions/skips, state is persisted correctly
    - Verify test passes on UNFIXED code
    - _Requirements: 3.11, 3.12_
  
  - [~] 2.7 Feedback System Test
    - Observe: Feedback (Easy/Perfect/Hard) adjusts future workouts on unfixed code
    - Write property-based test: for all feedback submissions, future workouts are adjusted
    - Verify test passes on UNFIXED code
    - _Requirements: 3.13, 3.14_
  
  - [~] 2.8 Rest Screen Behavior Test
    - Observe: Rest screen shows breathing animation and auto-transitions on unfixed code
    - Write property-based test: for all rest periods, animation displays and auto-transition works
    - Verify test passes on UNFIXED code
    - _Requirements: 3.15, 3.16_
  
  - [~] 2.9 Completion Screen Test
    - Observe: Completion screen shows confetti, saves DailyWorkoutSummary, restores tab bar on unfixed code
    - Write property-based test: for all workout completions, completion screen behavior is correct
    - Verify test passes on UNFIXED code
    - _Requirements: 3.17, 3.18, 3.19_

## Phase 3: Implementation

- [ ] 3. Fix for workout flow bugs

  - [~] 3.1 Implement timer lifecycle management fixes in `10minworkoutViewController.swift`
    - Add consistent timer invalidation in `viewWillDisappear`
    - Ensure `timer?.invalidate()` and `timer = nil` are called
    - Use `[weak self]` in all timer closures to prevent retain cycles
    - _Bug_Condition: (input.eventType == "viewWillDisappear" AND input.timerNotInvalidated) OR (input.eventType == "navigation" AND input.timerNotInvalidated) OR (input.eventType == "timerCreated" AND NOT input.usesWeakSelf)_
    - _Expected_Behavior: For any screen transition or view disappearance, all active timers are invalidated, weak self references prevent retain cycles, only one timer active per screen_
    - _Preservation: Normal workout flow timer display and countdown behavior unchanged_
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.7, 3.8_

  - [~] 3.2 Implement navigation guards in `10minworkoutViewController.swift`
    - Add `private var isNavigating = false` property
    - Check `isNavigating` flag in `handleCompletion` and `goToRest` before navigation
    - Set `isNavigating = true` before navigation, reset in completion handlers
    - Disable buttons immediately during navigation
    - _Bug_Condition: (input.eventType == "buttonTapped" AND NOT input.hasNavigationGuard AND input.navigationInProgress) OR (input.eventType == "rapidButtonTaps" AND input.duplicateNavigationPushes)_
    - _Expected_Behavior: Navigation guards prevent race conditions, buttons disabled during navigation, no duplicate view controller pushes_
    - _Preservation: Normal sequential navigation flow unchanged_
    - _Requirements: 1.14, 1.15, 2.14, 2.15, 3.1_

  - [~] 3.3 Implement done button validation in `10minworkoutViewController.swift`
    - Add `private var isDoneProcessing = false` property
    - In `doneButtonTapped`, check if timer-based exercise and validate `timeLeft <= totalTime * 0.2`
    - Check `isDoneProcessing` flag and return early if true
    - Set `isDoneProcessing = true` at start, reset after completion
    - Disable done button immediately after first tap
    - _Bug_Condition: (input.eventType == "doneButtonTapped" AND input.isTimerBased AND input.timeRemaining > 0.2 * input.totalTime) OR (input.eventType == "doneButtonTapped" AND input.buttonNotDisabled AND input.alreadyProcessing)_
    - _Expected_Behavior: Done button only works after 80% timer completion, button disabled after first tap, no duplicate completions_
    - _Preservation: Normal done button behavior for rep-based exercises unchanged_
    - _Requirements: 1.8, 1.9, 2.8, 2.9, 3.1, 3.2_

  - [~] 3.4 Implement skip button validation in `10minworkoutViewController.swift`
    - In `skipButtonTapped`, check `isRevisitingSkipped` and show alert if true
    - Validate that `completedToday.count + skippedToday.count < exercises.count - 3` before allowing skip
    - Clean up stale skipped IDs at start of `checkForSkippedExercises`
    - Maintain accurate skipped state when using Previous button
    - _Bug_Condition: (input.eventType == "skipButtonTapped" AND input.isRevisitingSkipped AND input.skipAllowed) OR (input.eventType == "skipButtonTapped" AND input.remainingExercises < 3) OR (input.eventType == "previousButtonTapped" AND input.skippedStateNotRestored)_
    - _Expected_Behavior: Skip button disabled during revisit mode, minimum 3 exercises enforced, skipped state maintained with Previous button, stale IDs cleaned up_
    - _Preservation: Normal skip button behavior in main workout flow unchanged_
    - _Requirements: 1.4, 1.5, 1.6, 1.7, 2.4, 2.5, 2.6, 2.7, 3.1, 3.2_

  - [~] 3.5 Implement previous button state restoration in `10minworkoutViewController.swift`
    - In `previousButtonTapped`, after decrementing `currentIndex`, check if `exercises[currentIndex].id` is in `skippedToday`
    - Restore exact state including skipped status
    - Ensure `exerciseStartTime = Date()` is set correctly
    - Call `updateProgressBars()` and `updateTopLabels()` after all state changes
    - Maintain consistency between completed/skipped tracking and current index
    - _Bug_Condition: (input.eventType == "previousButtonTapped" AND input.skippedStateNotRestored) OR (input.eventType == "previousButtonTapped" AND input.exerciseStartTimeNotReset)_
    - _Expected_Behavior: Previous button restores exact state including skipped status, resets exercise start time, updates all UI immediately_
    - _Preservation: Normal previous button behavior unchanged_
    - _Requirements: 1.11, 1.12, 1.13, 2.11, 2.12, 2.13, 3.1_

  - [~] 3.6 Implement progress bar update logic fixes in `10minworkoutViewController.swift`
    - In `updateProgressBars`, add special handling for revisit mode
    - When `isRevisitingSkipped` is true, ensure skipped exercises show gray until completed
    - Update completed count labels immediately before navigation
    - Include both completed and skipped exercises in progress calculations
    - _Bug_Condition: (input.eventType == "progressBarUpdate" AND input.isRevisitingSkipped AND input.incorrectColors) OR (input.eventType == "exerciseCompleted" AND input.labelNotUpdatedImmediately)_
    - _Expected_Behavior: Progress bars show correct colors during revisit (blue for completed, gray for skipped), labels update immediately, progress includes all exercises_
    - _Preservation: Normal mode progress bar colors and behavior unchanged_
    - _Requirements: 1.18, 1.19, 1.20, 2.18, 2.19, 2.20, 3.4, 3.5, 3.6_

  - [~] 3.7 Implement skipped exercise revisit management in `10minworkoutViewController.swift`
    - In `checkForSkippedExercises`, add UI indicator (banner or label) when entering revisit mode
    - Set and maintain `hasHandledSkippedExercises = true` until workout completion
    - Prevent revisiting same exercises multiple times by checking flag
    - Disable skip button during revisit mode (covered in 3.4)
    - Display clear "Revisiting Skipped Exercises" indicator
    - _Bug_Condition: (input.eventType == "revisitModeComplete" AND NOT input.flagReset) OR (input.eventType == "revisitMode" AND input.allowsReSkipping) OR (input.eventType == "revisitMode" AND NOT input.userIndicatorShown)_
    - _Expected_Behavior: hasHandledSkippedExercises flag properly managed, no infinite loops, clear user indicator shown_
    - _Preservation: Normal workout flow without skipping unchanged_
    - _Requirements: 1.21, 1.22, 1.23, 1.24, 2.21, 2.22, 2.23, 2.24, 3.1, 3.2_

  - [~] 3.8 Implement state synchronization fixes across view controllers
    - Ensure `isRevisitingSkipped` and `hasHandledSkippedExercises` are passed to all view controllers
    - Add bidirectional synchronization when returning from rest/countdown screens
    - Reset `exerciseStartTime` when navigating to previous exercises
    - Verify all exercises processed before showing completion
    - _Bug_Condition: (input.eventType == "modeTransition" AND input.flagsNotSynchronized) OR (input.eventType == "previousButtonTapped" AND input.exerciseStartTimeNotReset)_
    - _Expected_Behavior: Flags synchronized across all view controllers, exercise start time reset correctly, completion only after all exercises processed_
    - _Preservation: Normal state management unchanged_
    - _Requirements: 1.25, 1.26, 1.27, 2.25, 2.26, 2.27, 3.1, 3.2, 3.11, 3.12_

  - [~] 3.9 Implement rest screen validation fixes in `RestScreenViewController.swift`
    - Add `private var minimumRestTime = 10` property
    - Add `private var maximumRestTime = 180` property
    - In `skipButtonTapped`, check if `60 - totalTime >= minimumRestTime` before allowing skip
    - In `addTimeButtonTapped`, check if `totalTime + 20 <= maximumRestTime` before adding time
    - Ensure timer lifecycle management (invalidate in `viewWillDisappear`, use weak self)
    - Record elapsed rest duration when app is backgrounded
    - _Bug_Condition: (input.eventType == "restScreenAppears" AND input.allowsImmediateSkip) OR (input.eventType == "addTimeButtonTapped" AND input.noMaximumLimit)_
    - _Expected_Behavior: Minimum 10s rest enforced, maximum 180s total rest enforced, rest duration recorded on background_
    - _Preservation: Normal rest screen behavior (animation, auto-transition) unchanged_
    - _Requirements: 1.28, 1.29, 1.30, 2.28, 2.29, 2.30, 3.15, 3.16_

  - [~] 3.10 Implement completion screen protection fixes in `10minworkoutGoodJobViewController.swift`
    - Add `private var feedbackSubmitted = false` property
    - In `saveFeedbackAndExit`, check `feedbackSubmitted` and return early if true
    - Set `feedbackSubmitted = true` at start of method
    - Disable all three feedback buttons immediately after first tap
    - Add validation in view controller that pushes to completion screen
    - Ensure `WorkoutManager.shared.completedToday.count >= 1` before showing completion
    - Use `popToRootViewController` for proper navigation cleanup
    - _Bug_Condition: (input.eventType == "feedbackButtonTapped" AND input.buttonsNotDisabled AND input.duplicateRecords) OR (input.eventType == "completionScreenDismissed" AND input.navigationStackNotCleaned)_
    - _Expected_Behavior: Feedback buttons disabled after first tap, minimum 1 exercise required for completion, navigation stack properly cleaned_
    - _Preservation: Normal completion screen behavior (confetti, Core Data saving, tab bar) unchanged_
    - _Requirements: 1.31, 1.32, 1.33, 2.31, 2.32, 2.33, 3.17, 3.18, 3.19_

  - [~] 3.11 Implement timer lifecycle fixes in `ExerciseCountdownViewController.swift`
    - Ensure `countdownTimer?.invalidate()` and `countdownTimer = nil` in `viewWillDisappear`
    - Verify `[weak self]` is used in timer closure
    - Ensure `hasNavigated` and `isCancelled` flags are properly managed
    - Verify state synchronization with next view controller
    - _Bug_Condition: (input.eventType == "viewWillDisappear" AND input.timerNotInvalidated) OR (input.eventType == "navigation" AND input.timerNotInvalidated)_
    - _Expected_Behavior: Timer properly invalidated on view disappear, navigation guards prevent duplicates, state synchronized_
    - _Preservation: Normal countdown behavior unchanged_
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1_

  - [~] 3.12 Implement stale skipped ID cleanup in `WorkoutManager.swift` (if needed)
    - Add method `cleanupStaleSkippedIDs()` that removes skipped IDs not in current `exercises` array
    - Call this method at start of workout session and before revisit logic
    - _Bug_Condition: (input.eventType == "skipButtonTapped" AND input.staleSkippedIDsExist)_
    - _Expected_Behavior: Stale skipped IDs cleaned up before processing_
    - _Preservation: Normal workout manager behavior unchanged_
    - _Requirements: 1.7, 2.7, 3.11, 3.12_

  - [~] 3.13 Verify bug condition exploration tests now pass
    - **Property 1: Expected Behavior** - Workout Flow Expected Behavior
    - **IMPORTANT**: Re-run the SAME tests from task 1 - do NOT write new tests
    - The tests from task 1 encode the expected behavior
    - When these tests pass, it confirms the expected behavior is satisfied
    - Run all bug condition exploration tests from Phase 1
    - **EXPECTED OUTCOME**: All tests PASS (confirms bugs are fixed)
    - _Requirements: All Expected Behavior Properties from design (2.1-2.33)_

  - [~] 3.14 Verify preservation tests still pass
    - **Property 2: Preservation** - Normal Workout Flow Preservation
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run all preservation property tests from Phase 2
    - **EXPECTED OUTCOME**: All tests PASS (confirms no regressions)
    - Confirm all tests still pass after fix (no regressions in normal workout flow)
    - _Requirements: All Preservation Requirements from design (3.1-3.19)_

- [~] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass (both bug condition and preservation tests)
  - Verify no regressions in normal workout flow
  - Ask the user if questions arise
