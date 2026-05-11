# Workout Flow Done/Skip Handling Bugfix Design

## Overview

The 10-minute workout flow contains multiple critical bugs affecting timer management, button handling (Done/Skip/Previous), navigation flow, state management, and progress tracking. These bugs lead to memory leaks, inconsistent state, incorrect progress tracking, and poor user experience. The fix approach involves systematic cleanup of timer lifecycle management, implementing navigation guards to prevent race conditions, adding validation logic for button actions, and ensuring proper state synchronization across view controllers. The strategy focuses on minimal, targeted changes that address root causes while preserving existing functionality for normal workout flows.

## Glossary

- **Bug_Condition (C)**: The conditions that trigger bugs - including improper timer cleanup, missing navigation guards, lack of button validation, and inconsistent state management
- **Property (P)**: The desired behavior - timers properly invalidated, navigation protected by guards, buttons validated before action, state synchronized across screens
- **Preservation**: Existing normal workout flow behavior that must remain unchanged - exercise progression, video playback, voice instructions, progress tracking, completion flow
- **WorkoutManager**: The singleton in `WorkoutManager.swift` that manages workout state including `completedToday`, `skippedToday`, and `exercises` arrays
- **hasHandledSkippedExercises**: A flag that tracks whether the skipped exercise revisit prompt has been shown to prevent infinite loops
- **isRevisitingSkipped**: A flag indicating the user is currently in the skipped exercise revisit phase
- **skippedIndicesToRevisit**: An array of exercise indices that the user chose to revisit after skipping them initially
- **Timer Lifecycle**: The pattern of creating timers in `viewDidAppear`/`viewDidLoad`, invalidating in `viewWillDisappear`, and using weak self references
- **Navigation Guard**: A boolean flag (e.g., `isNavigating`, `isCompleting`) that prevents duplicate navigation actions

## Bug Details

### Bug Condition

The bugs manifest across multiple scenarios in the workout flow. The primary bug conditions are:

1. **Timer Management**: Timers are not properly invalidated when navigating between screens or when views disappear
2. **Skip Button Edge Cases**: Skip button allows re-skipping during revisit mode and doesn't validate minimum completed exercises
3. **Done Button Edge Cases**: Done button allows premature completion of timer-based exercises and duplicate taps
4. **Previous Button**: Previous button doesn't properly restore exercise state or update progress
5. **Navigation Flow**: Rapid button taps cause duplicate navigation pushes and stack corruption
6. **Progress Tracking**: Progress bars show incorrect states during skipped exercise revisit
7. **Skipped Exercise Revisit**: Revisit mode allows infinite loops and doesn't provide clear user feedback
8. **State Management**: Flags like `isRevisitingSkipped` and `hasHandledSkippedExercises` are not synchronized across view controllers
9. **Rest Screen**: Rest can be skipped immediately and time can be extended infinitely
10. **Completion Screen**: Feedback buttons can be tapped multiple times creating duplicate records

**Formal Specification:**

```
FUNCTION isBugCondition(input)
  INPUT: input of type WorkoutFlowEvent
  OUTPUT: boolean
  
  RETURN (
    // Timer bugs
    (input.eventType == "viewWillDisappear" AND input.timerNotInvalidated) OR
    (input.eventType == "navigation" AND input.timerNotInvalidated) OR
    (input.eventType == "timerCreated" AND NOT input.usesWeakSelf) OR
    
    // Skip button bugs
    (input.eventType == "skipButtonTapped" AND input.isRevisitingSkipped AND input.skipAllowed) OR
    (input.eventType == "skipButtonTapped" AND input.remainingExercises < 3) OR
    (input.eventType == "previousButtonTapped" AND input.skippedStateNotRestored) OR
    
    // Done button bugs
    (input.eventType == "doneButtonTapped" AND input.isTimerBased AND input.timeRemaining > 0.2 * input.totalTime) OR
    (input.eventType == "doneButtonTapped" AND input.buttonNotDisabled AND input.alreadyProcessing) OR
    
    // Navigation bugs
    (input.eventType == "buttonTapped" AND NOT input.hasNavigationGuard AND input.navigationInProgress) OR
    (input.eventType == "rapidButtonTaps" AND input.duplicateNavigationPushes) OR
    
    // Progress tracking bugs
    (input.eventType == "progressBarUpdate" AND input.isRevisitingSkipped AND input.incorrectColors) OR
    (input.eventType == "exerciseCompleted" AND input.labelNotUpdatedImmediately) OR
    
    // Skipped exercise revisit bugs
    (input.eventType == "revisitModeComplete" AND NOT input.flagReset) OR
    (input.eventType == "revisitMode" AND input.allowsReSkipping) OR
    (input.eventType == "revisitMode" AND NOT input.userIndicatorShown) OR
    
    // State management bugs
    (input.eventType == "modeTransition" AND input.flagsNotSynchronized) OR
    (input.eventType == "previousButtonTapped" AND input.exerciseStartTimeNotReset) OR
    
    // Rest screen bugs
    (input.eventType == "restScreenAppears" AND input.allowsImmediateSkip) OR
    (input.eventType == "addTimeButtonTapped" AND input.noMaximumLimit) OR
    
    // Completion screen bugs
    (input.eventType == "feedbackButtonTapped" AND input.buttonsNotDisabled AND input.duplicateRecords) OR
    (input.eventType == "completionScreenDismissed" AND input.navigationStackNotCleaned)
  )
END FUNCTION
```

### Examples

**Timer Management:**
- Navigate from exercise screen → rest screen → countdown screen: Multiple timers run simultaneously, causing memory leaks
- User backgrounds the app during exercise: Timer continues running in background, wasting resources
- Expected: Each timer is invalidated before navigation, only one timer active at a time

**Skip Button:**
- User skips exercise #3, later revisits it, and skips it again: Creates infinite loop in revisit logic
- User skips 9 out of 10 exercises: Workout completes with only 1 exercise done
- Expected: Skip button disabled during revisit mode, minimum 3 exercises must be completed

**Done Button:**
- User taps Done on 60-second warmup after only 10 seconds: Exercise marked complete prematurely
- User rapidly taps Done button 3 times: Exercise marked complete 3 times with duplicate records
- Expected: Done button only works after 80% of timer complete, button disabled after first tap

**Previous Button:**
- User skips exercise #2, goes to #3, then taps Previous: Exercise #2 shows as not skipped (incorrect state)
- User goes back to exercise #1: Progress bars show stale information
- Expected: Previous button restores exact state including skipped status and updates all UI

**Navigation Flow:**
- User rapidly taps Done button: Multiple rest screens pushed onto navigation stack
- User taps Close during revisit mode: Navigation stack corrupted, can't return properly
- Expected: Navigation guards prevent duplicate pushes, Close button properly cleans up state

**Progress Tracking:**
- During revisit mode, skipped exercises show blue instead of gray: Incorrect visual feedback
- Exercise completed but label still shows "3 of 10" instead of "4 of 10": Stale label
- Expected: Progress bars show correct colors (blue=completed, gray=skipped), labels update immediately

**Skipped Exercise Revisit:**
- User completes revisit mode but `hasHandledSkippedExercises` not reset: Future workouts can't show revisit prompt
- User in revisit mode with no clear indication: Confusing user experience
- Expected: Flag properly managed, clear "Revisiting Skipped Exercises" banner shown

**Edge Case - All Exercises Skipped:**
- User skips all 10 exercises: Reaches completion screen with 0 exercises done
- Expected: System requires minimum 1 exercise completed before showing completion

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Normal workout flow (exercise → rest → countdown → next exercise) must continue to work exactly as before
- Exercise video playback with AVPlayerLooper must remain smooth and seamless
- Voice instructions must continue to play after 0.35 second delay
- Progress bars must continue to show blue for completed, partial for current, empty for upcoming (in normal mode)
- Workout persistence using WorkoutManager.syncSessionPersistence() must remain unchanged
- Feedback adjustment system (Easy/Perfect/Hard) must continue to work
- Pain/fatigue quit flow that reduces exercise intensity must remain unchanged
- Rest screen breathing animation must continue to work
- Completion screen confetti animation must continue to display
- Core Data saving of DailyWorkoutSummary must remain unchanged
- Tab bar hiding/showing behavior must remain unchanged

**Scope:**
All inputs that do NOT involve the specific bug conditions (timer cleanup failures, rapid button taps, skip during revisit, etc.) should be completely unaffected by this fix. This includes:
- Normal sequential exercise completion without skipping
- Normal rest periods that complete naturally
- Normal completion flow when all exercises are done
- Video playback and voice instruction systems
- Workout persistence and feedback systems

## Hypothesized Root Cause

Based on the bug description and code analysis, the most likely issues are:

### 1. **Timer Lifecycle Management**
The view controllers create timers but don't consistently invalidate them in `viewWillDisappear`. This causes:
- Multiple timers running simultaneously when navigating between screens
- Timers continuing to run in background when app is backgrounded
- Memory leaks from timer retain cycles (not using weak self)

**Evidence**: In `10minworkoutViewController.swift`, the timer is created in `startCountdown` but only invalidated in specific scenarios, not consistently in `viewWillDisappear`. In `RestScreenViewController.swift`, the timer is invalidated in `viewWillDisappear` but the pattern is inconsistent across all view controllers.

### 2. **Missing Navigation Guards**
The navigation methods don't use flags to prevent duplicate navigation actions. This causes:
- Rapid button taps pushing multiple view controllers onto the stack
- Race conditions during screen transitions
- Navigation stack corruption

**Evidence**: In `handleCompletion` and `goToRest` methods, there's no check for `isNavigating` flag before pushing new view controllers. The `RestScreenViewController.finishRest` method has an `isCompleting` guard, but this pattern isn't used consistently.

### 3. **Insufficient Button Validation**
The Done and Skip buttons don't validate state before executing actions. This causes:
- Timer-based exercises completing prematurely
- Exercises being skipped during revisit mode
- Duplicate completion records from rapid taps

**Evidence**: In `doneButtonTapped`, there's no check for timer completion percentage. In `skipButtonTapped`, there's no check for `isRevisitingSkipped` flag or minimum completed exercise count.

### 4. **State Synchronization Issues**
Flags like `isRevisitingSkipped` and `hasHandledSkippedExercises` are not consistently passed between view controllers. This causes:
- Revisit mode state lost during navigation
- Infinite revisit loops
- Incorrect UI states

**Evidence**: In `ExerciseCountdownViewController`, the `isRevisitingSkipped` flag is passed to `_0minworkoutViewController`, but the synchronization isn't bidirectional. The `hasHandledSkippedExercises` flag is only managed in `_0minworkoutViewController` and not passed to other screens.

### 5. **Progress Bar Update Logic**
The progress bar update logic doesn't account for revisit mode states. This causes:
- Skipped exercises showing as completed (blue) during revisit
- Progress bars not updating immediately after state changes

**Evidence**: In `updateProgressBars`, the logic checks `completedToday` and `skippedToday` but doesn't have special handling for revisit mode where skipped exercises should remain gray even when being revisited.

### 6. **Incomplete Previous Button Implementation**
The Previous button doesn't properly restore exercise state or reset timing. This causes:
- Skipped state not restored correctly
- Exercise start time not reset leading to incorrect duration calculations
- Progress bars showing stale information

**Evidence**: In `previousButtonTapped`, the method decrements `currentIndex` and reconfigures the exercise, but doesn't check or restore the skipped state from `WorkoutManager.shared.skippedToday`. The `exerciseStartTime` is reset, but this happens after potential state inconsistencies.

### 7. **Skipped Exercise Revisit Logic Gaps**
The revisit logic doesn't prevent re-skipping or provide clear user feedback. This causes:
- Infinite loops when exercises are skipped again during revisit
- User confusion about being in revisit mode
- `hasHandledSkippedExercises` flag not properly managed

**Evidence**: In `checkForSkippedExercises`, the `hasHandledSkippedExercises` flag is set when entering revisit mode, but there's no mechanism to prevent skipping during revisit. There's also no UI indicator showing the user is in revisit mode.

### 8. **Rest Screen Validation Gaps**
The rest screen allows immediate skip and infinite time extension. This causes:
- Users bypassing rest periods entirely
- Users pausing indefinitely by repeatedly adding time

**Evidence**: In `RestScreenViewController`, the `skipButtonTapped` method immediately calls `finishRest` with no minimum time check. The `addTimeButtonTapped` method adds 20 seconds with no maximum limit check.

### 9. **Completion Screen Button Handling**
The feedback buttons don't disable after first tap. This causes:
- Duplicate feedback records in the database
- Multiple alert presentations

**Evidence**: In `_0minworkoutGoodJobViewController`, the `saveFeedbackAndExit` method is called directly from button actions with no guard to prevent multiple invocations.

## Correctness Properties

Property 1: Bug Condition - Timer Lifecycle Management

_For any_ screen transition or view disappearance event in the workout flow, the system SHALL invalidate all active timers before the transition completes, use weak self references in timer closures to prevent retain cycles, and ensure only one timer is active per screen at any time.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Bug Condition - Skip Button Validation

_For any_ skip button tap event, the system SHALL disable the skip button when `isRevisitingSkipped` is true, validate that at least 3 exercises will remain non-skipped before allowing the skip, maintain accurate skipped state when using Previous button, and clean up stale skipped IDs before processing.

**Validates: Requirements 2.4, 2.5, 2.6, 2.7**

Property 3: Bug Condition - Done Button Validation

_For any_ done button tap event on timer-based exercises, the system SHALL only allow completion if the timer has reached zero or is at least 80% complete, disable the button immediately after first tap to prevent duplicates, and use atomic operations for duration tracking.

**Validates: Requirements 2.8, 2.9, 2.10**

Property 4: Bug Condition - Previous Button State Restoration

_For any_ previous button tap event, the system SHALL restore the exact state of the previous exercise including skipped status, reset the exercise start time, maintain consistency between completed/skipped tracking and current index, and immediately update all progress bars.

**Validates: Requirements 2.11, 2.12, 2.13**

Property 5: Bug Condition - Navigation Flow Protection

_For any_ navigation action (Done, Skip, Next, Previous, Close buttons), the system SHALL use navigation guards to prevent race conditions, disable buttons immediately during navigation, properly handle back button during revisit mode, and clean up all state when Close is tapped.

**Validates: Requirements 2.14, 2.15, 2.16, 2.17**

Property 6: Bug Condition - Progress Tracking Accuracy

_For any_ progress bar update or exercise completion event, the system SHALL show correct colors during revisit mode (blue for completed, gray for skipped), update completed count labels immediately before navigation, and include both completed and skipped exercises in progress calculations.

**Validates: Requirements 2.18, 2.19, 2.20**

Property 7: Bug Condition - Skipped Exercise Revisit Management

_For any_ skipped exercise revisit flow, the system SHALL set and maintain `hasHandledSkippedExercises = true` until workout completion, prevent revisiting the same exercises multiple times, disable skip button during revisit mode, and display a clear "Revisiting Skipped Exercises" indicator.

**Validates: Requirements 2.21, 2.22, 2.23, 2.24**

Property 8: Bug Condition - State Synchronization

_For any_ transition between workout modes or view controllers, the system SHALL pass `isRevisitingSkipped` flag through all navigation methods, reset `exerciseStartTime` when navigating to previous exercises, and verify all exercises are processed before showing completion.

**Validates: Requirements 2.25, 2.26, 2.27**

Property 9: Bug Condition - Rest Screen Validation

_For any_ rest screen interaction, the system SHALL enforce a minimum rest time of 10 seconds before allowing skip, enforce a maximum total rest time of 180 seconds for time extensions, and record elapsed rest duration when app is backgrounded.

**Validates: Requirements 2.28, 2.29, 2.30**

Property 10: Bug Condition - Completion Screen Protection

_For any_ completion screen interaction, the system SHALL require a minimum of 1 completed exercise before showing the screen, disable all feedback buttons immediately after first tap, and use proper navigation cleanup when dismissing.

**Validates: Requirements 2.31, 2.32, 2.33**

Property 11: Preservation - Normal Workout Flow

_For any_ workout session where exercises are completed in normal sequence without skipping, the system SHALL produce exactly the same navigation flow, video playback, voice instructions, progress tracking, and completion behavior as the original unfixed code.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13, 3.14, 3.15, 3.16, 3.17, 3.18, 3.19**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct, the following changes are needed:

#### File: `Parkinsons/10_min_workout/Controller/10minworkoutViewController.swift`

**Function**: `_0minworkoutViewController` class

**Specific Changes**:

1. **Timer Lifecycle Management**:
   - Add consistent timer invalidation in `viewWillDisappear`
   - Ensure `timer?.invalidate()` and `timer = nil` are called
   - Use `[weak self]` in all timer closures

2. **Navigation Guards**:
   - Add `private var isNavigating = false` property
   - Check `isNavigating` flag in `handleCompletion` and `goToRest` before navigation
   - Set `isNavigating = true` before navigation, reset in completion handlers

3. **Done Button Validation**:
   - Add `private var isDoneProcessing = false` property
   - In `doneButtonTapped`, check if timer-based exercise and validate `timeLeft <= totalTime * 0.2`
   - Check `isDoneProcessing` flag and return early if true
   - Set `isDoneProcessing = true` at start, reset after completion

4. **Skip Button Validation**:
   - In `skipButtonTapped`, check `isRevisitingSkipped` and show alert if true
   - Validate that `completedToday.count + skippedToday.count < exercises.count - 3` before allowing skip
   - Clean up stale skipped IDs at start of `checkForSkippedExercises`

5. **Previous Button State Restoration**:
   - In `previousButtonTapped`, after decrementing `currentIndex`, check if `exercises[currentIndex].id` is in `skippedToday`
   - If skipped, update UI to reflect skipped state (though this is complex - may need to reconsider Previous button behavior during skipped exercises)
   - Ensure `exerciseStartTime = Date()` is set correctly
   - Call `updateProgressBars()` and `updateTopLabels()` after all state changes

6. **Progress Bar Update Logic**:
   - In `updateProgressBars`, add special handling for revisit mode
   - When `isRevisitingSkipped` is true, ensure skipped exercises that are being revisited show gray until completed

7. **Skipped Exercise Revisit Logic**:
   - In `checkForSkippedExercises`, add UI indicator (banner or label) when entering revisit mode
   - Ensure `hasHandledSkippedExercises` flag is properly maintained
   - Add check in `skipButtonTapped` to prevent skipping during revisit

8. **State Synchronization**:
   - Ensure `isRevisitingSkipped` and `hasHandledSkippedExercises` are passed to all view controllers
   - Add bidirectional synchronization when returning from rest/countdown screens

#### File: `Parkinsons/10_min_workout/Controller/RestScreenViewController.swift`

**Function**: `RestScreenViewController` class

**Specific Changes**:

1. **Timer Lifecycle Management**:
   - Ensure `restTimer?.invalidate()` and `restTimer = nil` in `viewWillDisappear`
   - Use `[weak self]` in timer closure

2. **Rest Validation**:
   - Add `private var minimumRestTime = 10` property
   - Add `private var maximumRestTime = 180` property
   - In `skipButtonTapped`, check if `60 - totalTime >= minimumRestTime` before allowing skip
   - In `addTimeButtonTapped`, check if `totalTime + 20 <= maximumRestTime` before adding time

3. **Navigation Guards**:
   - The `isCompleting` flag is already present - ensure it's used consistently
   - Verify all navigation paths check this flag

#### File: `Parkinsons/10_min_workout/Controller/ExerciseCountdownViewController.swift`

**Function**: `ExerciseCountdownViewController` class

**Specific Changes**:

1. **Timer Lifecycle Management**:
   - Ensure `countdownTimer?.invalidate()` and `countdownTimer = nil` in `viewWillDisappear`
   - Use `[weak self]` in timer closure (already present)

2. **Navigation Guards**:
   - The `hasNavigated` flag is already present - ensure it's used consistently
   - Verify `isCancelled` flag is properly managed

3. **State Synchronization**:
   - Ensure `isRevisitingSkipped` and `skippedIndicesToRevisit` are properly passed to next view controller

#### File: `Parkinsons/10_min_workout/Controller/10minworkoutGoodJobViewController.swift`

**Function**: `_0minworkoutGoodJobViewController` class

**Specific Changes**:

1. **Feedback Button Protection**:
   - Add `private var feedbackSubmitted = false` property
   - In `saveFeedbackAndExit`, check `feedbackSubmitted` and return early if true
   - Set `feedbackSubmitted = true` at start of method
   - Disable all three feedback buttons immediately after first tap

2. **Completion Validation**:
   - Add validation in the view controller that pushes to this screen
   - Ensure `WorkoutManager.shared.completedToday.count >= 1` before showing completion

3. **Navigation Cleanup**:
   - Ensure `popToRootViewController` is used consistently
   - Verify navigation stack is properly cleaned up

#### File: `Parkinsons/10_min_workout/Model/WorkoutManager.swift` (if needed)

**Function**: `WorkoutManager` class

**Specific Changes**:

1. **Stale Skipped ID Cleanup**:
   - Add method `cleanupStaleSkippedIDs()` that removes skipped IDs not in current `exercises` array
   - Call this method at start of workout session and before revisit logic

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bugs on unfixed code, then verify the fixes work correctly and preserve existing behavior. Testing will focus on unit tests for individual bug conditions, property-based tests for state management and preservation, and integration tests for full workout flows.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bugs BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write tests that simulate the bug conditions and observe failures on the UNFIXED code. Use XCTest framework to create test cases that trigger each bug category.

**Test Cases**:

1. **Timer Leak Test**: Create a test that navigates exercise → rest → countdown → exercise and checks if multiple timers are active (will fail on unfixed code - expect 3+ timers running simultaneously)

2. **Skip During Revisit Test**: Simulate entering revisit mode, then tapping skip button - should fail by allowing the skip (will fail on unfixed code - expect skip to be allowed)

3. **Premature Done Test**: Simulate tapping Done button on 60-second warmup after only 10 seconds - should fail by marking complete (will fail on unfixed code - expect exercise marked complete at 10 seconds)

4. **Rapid Done Tap Test**: Simulate tapping Done button 3 times rapidly - should fail by creating duplicate completions (will fail on unfixed code - expect 3 completion records)

5. **Previous Button State Test**: Skip exercise #2, go to #3, tap Previous - should fail by showing incorrect skipped state (will fail on unfixed code - expect exercise #2 to show as not skipped)

6. **Rapid Navigation Test**: Rapidly tap Done button 5 times - should fail by pushing multiple view controllers (will fail on unfixed code - expect 5 rest screens in navigation stack)

7. **Progress Bar Revisit Test**: Enter revisit mode and check progress bar colors - should fail by showing blue instead of gray (will fail on unfixed code - expect skipped exercises to show blue)

8. **All Exercises Skipped Test**: Skip all 10 exercises - should fail by showing completion screen (will fail on unfixed code - expect completion screen with 0 exercises done)

9. **Infinite Rest Test**: Tap Add Time button 20 times - should fail by allowing unlimited time (will fail on unfixed code - expect rest time > 300 seconds)

10. **Duplicate Feedback Test**: Tap Easy button 3 times rapidly - should fail by creating duplicate records (will fail on unfixed code - expect 3 feedback records)

**Expected Counterexamples**:
- Multiple timers running simultaneously causing memory leaks
- Skip button functional during revisit mode
- Done button marking exercises complete prematurely
- Duplicate navigation pushes from rapid taps
- Incorrect progress bar colors during revisit
- Completion screen shown with 0 exercises completed
- Possible causes: missing timer invalidation, no navigation guards, insufficient validation, state synchronization gaps

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed code produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := workoutFlow_fixed(input)
  ASSERT expectedBehavior(result)
END FOR
```

**Test Plan**: After implementing fixes, run the same test cases and verify they now pass with correct behavior.

**Test Cases**:

1. **Timer Lifecycle Test**: Navigate between screens and verify only one timer is active, all timers invalidated on disappear
2. **Skip Validation Test**: Verify skip button disabled during revisit, minimum 3 exercises enforced
3. **Done Validation Test**: Verify done button only works after 80% timer completion, no duplicates
4. **Previous Button Test**: Verify state properly restored including skipped status
5. **Navigation Guard Test**: Verify rapid taps don't create duplicate navigation pushes
6. **Progress Bar Test**: Verify correct colors during revisit mode
7. **Revisit Management Test**: Verify no infinite loops, clear user indicators
8. **Rest Validation Test**: Verify minimum 10s rest, maximum 180s total
9. **Completion Validation Test**: Verify minimum 1 exercise required
10. **Feedback Protection Test**: Verify buttons disabled after first tap

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed code produces the same result as the original code.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT workoutFlow_original(input) = workoutFlow_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Observe behavior on UNFIXED code first for normal workout flows, then write property-based tests capturing that behavior.

**Test Cases**:

1. **Normal Completion Flow**: Observe that completing all 10 exercises in sequence works correctly on unfixed code, then write test to verify this continues after fix
2. **Video Playback**: Observe that exercise videos loop smoothly on unfixed code, then write test to verify this continues after fix
3. **Voice Instructions**: Observe that voice instructions play after 0.35s delay on unfixed code, then write test to verify this continues after fix
4. **Progress Bars Normal Mode**: Observe that progress bars show correct colors in normal mode on unfixed code, then write test to verify this continues after fix
5. **Workout Persistence**: Observe that workout state is saved correctly on unfixed code, then write test to verify this continues after fix
6. **Feedback System**: Observe that feedback adjusts future workouts on unfixed code, then write test to verify this continues after fix
7. **Pain/Fatigue Quit**: Observe that quitting reduces exercise intensity on unfixed code, then write test to verify this continues after fix
8. **Rest Animation**: Observe that breathing animation works on unfixed code, then write test to verify this continues after fix
9. **Completion Confetti**: Observe that confetti displays on unfixed code, then write test to verify this continues after fix
10. **Tab Bar Behavior**: Observe that tab bar hides/shows correctly on unfixed code, then write test to verify this continues after fix

### Unit Tests

- Test timer invalidation in each view controller's `viewWillDisappear`
- Test navigation guard flags prevent duplicate navigation
- Test done button validation for timer-based exercises
- Test skip button validation during revisit mode and minimum exercise count
- Test previous button state restoration
- Test progress bar color logic for all states (completed, skipped, current, upcoming, revisit)
- Test stale skipped ID cleanup logic
- Test rest screen minimum/maximum time validation
- Test completion screen feedback button protection
- Test state flag synchronization across view controllers

### Property-Based Tests

- Generate random workout sequences (varying exercise counts, skip patterns) and verify timer cleanup
- Generate random button tap sequences and verify no duplicate navigation
- Generate random exercise completion patterns and verify progress tracking accuracy
- Generate random revisit scenarios and verify no infinite loops
- Test that all normal workout flows (no skipping, no rapid taps) produce identical results before and after fix

### Integration Tests

- Test full workout flow: start → exercise → rest → countdown → next exercise → ... → completion
- Test skip and revisit flow: skip 3 exercises → complete others → revisit prompt → complete skipped → completion
- Test previous button flow: complete exercise 1 → go to 2 → go back to 1 → verify state
- Test quit flow: start workout → quit mid-exercise → verify state saved → resume → verify state restored
- Test all exercises skipped flow: skip all → verify completion not shown or minimum enforced
- Test rapid interaction flow: rapidly tap buttons → verify no crashes or duplicate navigation
- Test background/foreground flow: start exercise → background app → foreground → verify timer state
- Test rest screen flow: rest → add time → skip → verify time limits enforced
- Test completion flow: finish workout → tap feedback → verify single record → dismiss → verify navigation clean
