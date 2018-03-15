#  HapticFeedbackPlayer

Create simple haptic feedback patters easily.

## Example

```swift
HapticFeedback()
    .selectionChanged.then(after: .milliseconds(200))
    .selectionChanged.then(after: .milliseconds(200))
    .selectionChanged.then(after: .milliseconds(200))
.play()
```

```swift
HapticFeedback()
    .selectionChanged.then(after: .milliseconds(200))
.replay(times: 3)
```

```swift
HapticFeedback()
    .selectionChanged.replay(times: 2, withInterval: .milliseconds(300)).then(after: .milliseconds(150))
    .impactOcurredWith(style: .light).then(after: .seconds(1))
    .notificationOcurredOf(type: .success)
.play()
```
