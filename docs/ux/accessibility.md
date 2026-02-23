# Accessibility

Owner: Product Design + Engineering  
Status: Planned  
Last Updated: 2026-02-20  
Depends On: `docs/ux/design-system.md`

## Purpose

Ensure Yoked is usable by everyone, including people with disabilities. Accessibility is a requirement, not an afterthought.

## Standards

### Target Compliance
- **WCAG 2.1 Level AA** - Minimum standard
- **WCAG 2.1 Level AAA** - Target for core flows

### Platform Guidelines
- iOS: Apple Human Interface Guidelines - Accessibility
- Android: Material Design - Accessibility

## Core Principles

### 1. Perceivable
All users must be able to perceive the content.

- Text alternatives for non-text content
- Captions for video/audio
- Sufficient color contrast
- Resizable text without loss of functionality

### 2. Operable
All users must be able to operate the interface.

- Keyboard/switch accessible
- No seizure-inducing content
- Enough time to read and interact
- Navigable by assistive technology

### 3. Understandable
All users must be able to understand the content.

- Readable and predictable
- Input assistance
- Clear error messages

### 4. Robust
Content must work with current and future assistive technologies.

- Valid markup
- Proper ARIA labels
- Compatible with screen readers

## Implementation Guidelines

### Color & Contrast

| Element | Minimum Ratio | Target Ratio |
|---------|---------------|--------------|
| Normal text (< 18px) | 4.5:1 | 7:1 |
| Large text (≥ 18px bold) | 3:1 | 4.5:1 |
| UI components | 3:1 | 4.5:1 |

**Never use color alone** to convey information.

### Touch Targets

| Element | Minimum Size | Target Size |
|---------|--------------|-------------|
| Buttons/controls | 44×44 pt | 48×48 pt |
| Links in text | 44×44 pt hit area | - |
| Spacing between targets | 8pt minimum | - |

### Typography

- Minimum body text: 16px
- Support dynamic type (iOS) / font scaling (Android)
- Line length: 50-75 characters
- Line height: 1.5 minimum

### Screen Readers

#### iOS (VoiceOver)
```tsx
// React Native example
<TouchableOpacity
  accessible={true}
  accessibilityLabel="Accept match"
  accessibilityHint="Double tap to accept this match"
  accessibilityRole="button"
>
```

#### Android (TalkBack)
```tsx
// React Native example
<TouchableOpacity
  accessible={true}
  accessibilityLabel="Accept match"
  accessibilityRole="button"
>
```

### Focus Management

- Visible focus indicators (minimum 2px outline)
- Logical tab order
- Focus trap in modals
- Return focus after modal close

### Images & Media

- All images need `alt` text (decorative: `alt=""`)
- Profile photos: describe for context ("Profile photo of [name]")
- Icons: hidden from screen readers if decorative
- Video: captions and audio descriptions

### Forms

- Labels associated with inputs
- Clear error messages
- Error prevention for destructive actions
- Clear instructions before complex inputs

### Motion & Animation

- Respect `prefers-reduced-motion`
- No auto-playing content
- Pause/stop controls for animations
- No content that flashes > 3 times/second

## Testing

### Automated Testing
- Lighthouse (web)
- axe DevTools
- Accessibility scanner (Android)
- Accessibility Inspector (iOS)

### Manual Testing
- [ ] Navigate with screen reader (VoiceOver/TalkBack)
- [ ] Navigate with keyboard only
- [ ] Test at 200% zoom
- [ ] Test with high contrast mode
- [ ] Test with reduced motion

### User Testing
- Include users with disabilities in usability testing
- Test with actual assistive technologies

## Accessibility Checklist

Before any feature ships:
- [ ] Screen reader tested (iOS + Android)
- [ ] Color contrast passes AA
- [ ] Touch targets meet minimum size
- [ ] Focus management correct
- [ ] Error messages are clear
- [ ] Motion respects user preferences
- [ ] Forms have proper labels
- [ ] Automated tests pass

## Related Documents

- `docs/ux/design-system.md`
- `docs/ux/flows/`

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Apple Accessibility](https://developer.apple.com/accessibility/)
- [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility)
- [React Native Accessibility](https://reactnative.dev/docs/accessibility)
