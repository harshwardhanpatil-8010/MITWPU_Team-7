# Bugfix Requirements Document

## Introduction

The 10-minute workout flow contains multiple critical bugs related to timer management, button handling (Done/Skip/Previous), navigation flow, state management, and progress tracking. These issues lead to memory leaks, inconsistent state, incorrect progress tracking, and poor user experience. The bugs affect the core workout experience across multiple view controllers including the main exercise screen, rest screen, countdown screen, and completion screen.

## Bug Analysis

### Current Behavior (Defect)

#### Timer Management Issues

1.1 WHEN navigating between screens (exercise → rest → countdown → exercise) THEN the system fails to invalidate timers properly, causing multiple timers to run simultaneously and creating memory leaks

1.2 WHEN the view disappears (user navigates away or app backgrounds) THEN the system continues running timers in the background, wasting resources and causing incorrect time calculations

1.3 WHEN timer references are not cleaned up THEN the system accumulates stale timer objects leading to memory leaks over multiple workout sessions

#### Skip Button Edge Cases

1.4 WHEN a user skips an exercise and later revisits it during the skipped exercise revisit phase THEN the system allows the exercise to be skipped again, creating potential infinite loops

1.5 WHEN a user skips exercises THEN the system does not validate whether all exercises have been skipped, allowing completion with zero exercises done

1.6 WHEN a user goes back using the Previous button after skipping an exercise THEN the system does not properly track the skipped state, leading to inconsistent skipped exercise lists

1.7 WHEN stale skipped IDs exist (from exercises no longer in the workout) THEN the system does not clean them up consistently, causing incorrect progress calculations

#### Done Button Edge Cases

1.8 WHEN a user taps the Done button on timer-based exercises (warmup/cooldown) before the timer completes THEN the system marks the exercise as complete without validating minimum time elapsed

1.9 WHEN a user rapidly taps the Done button multiple times THEN the system can mark the exercise as done multiple times, creating duplicate completion records

1.10 WHEN a user rapidly switches between exercises THEN the system records inaccurate duration due to race conditions in start time tracking

#### Previous Button Issues

1.11 WHEN a user taps the Previous button after skipping an exercise THEN the system does not properly restore the skipped exercise state, showing incorrect UI state

1.12 WHEN a user goes back and then forward through exercises THEN the system creates inconsistent state between completed/skipped tracking and current index

1.13 WHEN a user goes backwards through exercises THEN the system does not update progress bars correctly, showing stale progress information

#### Navigation Flow Issues

1.14 WHEN navigating between countdown → exercise → rest screens THEN the system experiences race conditions that can cause navigation stack corruption

1.15 WHEN buttons are tapped rapidly (Done, Skip, Next, Previous) THEN the system allows multiple navigation pushes, creating duplicate view controllers in the stack

1.16 WHEN the user uses the back button during skipped exercise revisit phase THEN the system shows inconsistent behavior and may exit revisit mode incorrectly

1.17 WHEN the Close button is tapped THEN the system does not properly clean up workout state (timers, flags, tracking data)

#### Progress Tracking Issues

1.18 WHEN exercises are skipped and then revisited THEN the system shows incorrect progress bar states (wrong colors, wrong fill levels)

1.19 WHEN an exercise is marked as done THEN the system does not update the completed count immediately, showing stale "X of Y" labels

1.20 WHEN some exercises are skipped THEN the system calculates progress incorrectly, not accounting for skipped exercises in the total

#### Skipped Exercise Revisit Issues

1.21 WHEN the skipped exercise revisit phase completes THEN the system does not reset the `hasHandledSkippedExercises` flag properly, preventing future revisit prompts

1.22 WHEN in revisit mode THEN the system allows skipped exercises to be revisited multiple times if the user navigates back and forth

1.23 WHEN a user skips exercises again during the revisit phase THEN the system creates an infinite loop by adding them back to the skipped list

1.24 WHEN in revisit mode THEN the system provides no clear indication to the user that they are revisiting previously skipped exercises

#### State Management Issues

1.25 WHEN transitioning between main workout and revisit mode THEN the system does not synchronize the `isRevisitingSkipped` flag across view controllers, causing navigation errors

1.26 WHEN going back to a previous exercise THEN the system does not reset the `exerciseStartTime` properly, leading to incorrect duration calculations

1.27 WHEN all exercises are skipped or completed THEN the system can trigger workout completion prematurely before handling skipped exercise revisit

#### Rest Screen Issues

1.28 WHEN the rest screen appears THEN the system allows the user to skip rest immediately without any minimum rest time, defeating the purpose of rest periods

1.29 WHEN the Add Time button is tapped repeatedly THEN the system allows infinite time extension with no upper limit, allowing users to pause indefinitely

1.30 WHEN the user force-quits the app during rest THEN the system does not record the rest duration, losing workout time data

#### Completion Screen Issues

1.31 WHEN all exercises are skipped THEN the system allows the user to reach the completion screen with zero exercises completed

1.32 WHEN feedback buttons (Easy/Perfect/Hard) are tapped multiple times THEN the system can save duplicate feedback records

1.33 WHEN the completion screen is dismissed THEN the system does not properly clean up the navigation stack, leaving stale view controllers in memory

### Expected Behavior (Correct)

#### Timer Management Fixes

2.1 WHEN navigating between screens THEN the system SHALL invalidate all active timers before transitioning and create new timers only when the destination screen appears

2.2 WHEN the view disappears THEN the system SHALL immediately invalidate and nil out all timer references to stop background execution

2.3 WHEN cleaning up timers THEN the system SHALL use weak self references in timer closures to prevent retain cycles and memory leaks

#### Skip Button Fixes

2.4 WHEN in skipped exercise revisit mode THEN the system SHALL disable the Skip button or show a confirmation dialog preventing re-skipping

2.5 WHEN the user attempts to skip an exercise THEN the system SHALL validate that at least a minimum number of exercises (e.g., 3) will remain non-skipped before allowing the skip

2.6 WHEN the user goes back using Previous button THEN the system SHALL maintain accurate skipped state by not removing exercises from the skipped list unless explicitly un-skipped

2.7 WHEN processing skipped exercises THEN the system SHALL clean up stale skipped IDs (those not in current workout) before any skip-related logic

#### Done Button Fixes

2.8 WHEN the Done button is tapped on timer-based exercises THEN the system SHALL only allow completion if the timer has reached zero or a minimum threshold (e.g., 80% complete)

2.9 WHEN the Done button is tapped THEN the system SHALL disable the button immediately and use a flag to prevent duplicate completion processing

2.10 WHEN recording exercise duration THEN the system SHALL use atomic operations or serial queue to prevent race conditions in start time tracking

#### Previous Button Fixes

2.11 WHEN the Previous button is tapped THEN the system SHALL restore the exact state of the previous exercise including skipped status, timer state, and progress

2.12 WHEN navigating backwards and forwards THEN the system SHALL maintain consistency by recalculating current index based on completed/skipped state

2.13 WHEN going backwards THEN the system SHALL immediately update all progress bars to reflect the current exercise index and completion state

#### Navigation Flow Fixes

2.14 WHEN navigating between screens THEN the system SHALL use navigation guards (flags like `isNavigating`) to prevent race conditions

2.15 WHEN navigation buttons are tapped THEN the system SHALL disable buttons immediately and re-enable only after navigation completes

2.16 WHEN in skipped exercise revisit phase THEN the system SHALL handle back button by properly exiting revisit mode and returning to the appropriate screen

2.17 WHEN the Close button is tapped THEN the system SHALL invalidate all timers, reset flags, and clean up state before dismissing

#### Progress Tracking Fixes

2.18 WHEN exercises are skipped and revisited THEN the system SHALL update progress bars to show correct state (blue for completed, gray for skipped, partial for current)

2.19 WHEN an exercise is marked as done THEN the system SHALL immediately update the completed count label before any navigation

2.20 WHEN calculating progress THEN the system SHALL include both completed and skipped exercises in the progress calculation

#### Skipped Exercise Revisit Fixes

2.21 WHEN entering skipped exercise revisit mode THEN the system SHALL set `hasHandledSkippedExercises = true` and maintain this flag until workout completion

2.22 WHEN in revisit mode THEN the system SHALL prevent revisiting the same skipped exercises multiple times by checking the flag before showing the prompt

2.23 WHEN in revisit mode THEN the system SHALL disable the Skip button or require confirmation to prevent infinite revisit loops

2.24 WHEN in revisit mode THEN the system SHALL display a clear indicator (e.g., banner or label) showing "Revisiting Skipped Exercises"

#### State Management Fixes

2.25 WHEN transitioning between modes THEN the system SHALL pass `isRevisitingSkipped` flag through all navigation methods and maintain consistency

2.26 WHEN navigating to a previous exercise THEN the system SHALL reset `exerciseStartTime = Date()` to ensure accurate duration tracking

2.27 WHEN checking for workout completion THEN the system SHALL verify all exercises are processed and handle skipped exercise revisit before showing completion

#### Rest Screen Fixes

2.28 WHEN the rest screen appears THEN the system SHALL enforce a minimum rest time (e.g., 10 seconds) before allowing skip

2.29 WHEN the Add Time button is tapped THEN the system SHALL enforce a maximum total rest time (e.g., 180 seconds) to prevent indefinite pausing

2.30 WHEN the app is backgrounded during rest THEN the system SHALL record elapsed rest duration using background time tracking or save state on `viewWillDisappear`

#### Completion Screen Fixes

2.31 WHEN checking for workout completion THEN the system SHALL require a minimum number of completed exercises (e.g., at least 1) before showing the completion screen

2.32 WHEN feedback buttons are tapped THEN the system SHALL disable all feedback buttons immediately after the first tap to prevent duplicate submissions

2.33 WHEN dismissing the completion screen THEN the system SHALL use `popToRootViewController` or `popToViewController` to properly clean up the navigation stack

### Unchanged Behavior (Regression Prevention)

#### Core Workout Flow

3.1 WHEN a user completes exercises in normal sequence without skipping THEN the system SHALL CONTINUE TO navigate through exercises → rest → countdown → next exercise as before

3.2 WHEN a user completes all exercises without skipping any THEN the system SHALL CONTINUE TO show the completion screen with accurate statistics

3.3 WHEN exercise videos are displayed THEN the system SHALL CONTINUE TO loop videos smoothly using AVPlayerLooper

#### Progress Tracking

3.4 WHEN exercises are completed THEN the system SHALL CONTINUE TO show blue progress bars for completed exercises

3.5 WHEN the current exercise is in progress THEN the system SHALL CONTINUE TO show a partial (0.5) progress bar for the current exercise

3.6 WHEN exercises have not been started THEN the system SHALL CONTINUE TO show empty (0.0) progress bars

#### Timer Display

3.7 WHEN timer-based exercises (warmup/cooldown) are displayed THEN the system SHALL CONTINUE TO show countdown timers in the format "XX" seconds

3.8 WHEN rep-based exercises are displayed THEN the system SHALL CONTINUE TO show rep count and display "-" for the timer

#### Voice Instructions

3.9 WHEN an exercise is loaded THEN the system SHALL CONTINUE TO speak voice instructions after a 0.35 second delay

3.10 WHEN navigating away from an exercise THEN the system SHALL CONTINUE TO cancel pending voice instructions

#### Workout Persistence

3.11 WHEN exercises are completed or skipped THEN the system SHALL CONTINUE TO persist state using WorkoutManager.syncSessionPersistence()

3.12 WHEN the app is reopened THEN the system SHALL CONTINUE TO restore workout state from persisted data

#### Feedback and Adjustments

3.13 WHEN a user provides feedback (Easy/Perfect/Hard) THEN the system SHALL CONTINUE TO adjust future workouts based on the feedback

3.14 WHEN a user quits mid-workout due to pain/fatigue THEN the system SHALL CONTINUE TO reduce exercise intensity (reps/duration) for remaining exercises

#### Rest Screen Behavior

3.15 WHEN the rest screen is displayed THEN the system SHALL CONTINUE TO show the breathing animation guide

3.16 WHEN rest time expires THEN the system SHALL CONTINUE TO automatically transition to the next exercise countdown

#### Completion Screen

3.17 WHEN the completion screen is shown THEN the system SHALL CONTINUE TO display confetti animation

3.18 WHEN workout is completed THEN the system SHALL CONTINUE TO save DailyWorkoutSummary to Core Data

3.19 WHEN returning from completion screen THEN the system SHALL CONTINUE TO show the tab bar again
