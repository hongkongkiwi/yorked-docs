# ADR-0012: Expo for Mobile Development

Date: 2026-02-21  
Status: Accepted  
Owner: Engineering  
Last Updated: 2026-02-21  
Depends On: `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`

## Context

Yoked requires an iOS mobile client (Android later). We need to choose between:

1. **Expo** - Framework built on React Native with managed tooling
2. **Bare React Native CLI** - Direct React Native without Expo abstractions

### Requirements

- Phone OTP authentication
- Push notifications
- Camera access for photo capture/verification
- Biometric auth (future)
- Small team with limited native iOS/Android expertise
- Speed to MVP is critical

## Decision

**Use Expo with Development Builds.**

```
npx create-expo-app@latest --template blank-typescript
```

## Rationale

### Why Expo

| Factor | Expo | Decision |
|--------|------|----------|
| Setup time | Minutes vs hours | ✅ Expo |
| Team expertise | Lower barrier | ✅ Expo |
| Camera | `expo-camera` in SDK | ✅ Supported |
| Push notifications | `expo-notifications` in SDK | ✅ Supported |
| Biometrics | `expo-local-authentication` | ✅ Supported |
| OTA updates | EAS Update built-in | ✅ Expo |
| Build process | EAS cloud or local | ✅ Expo |

### 2025 Ecosystem Context

1. **React Native team officially recommends Expo** (2024+)
2. **CodePush is retiring March 2025** - EAS Update is the replacement
3. **Managed vs Bare is now a spectrum** - not binary
4. **Development builds** allow custom native modules while keeping Expo tooling
5. **Config plugins** enable native customization without ejecting

### Escape Hatch

If we hit Expo limitations:
```bash
npx expo prebuild
```

This generates native `ios/` and `android/` directories while keeping Expo SDK and EAS tooling. We can then:
- Add any native module
- Modify native code directly
- Continue using EAS for builds and updates

## Alternatives Considered

### Bare React Native CLI

**Pros:**
- Full control from day one
- Slightly smaller app size (~15MB vs ~25MB)
- Direct access to native code

**Cons:**
- Hours of setup vs minutes
- Manual native module linking
- Need separate OTA update solution (CodePush retiring)
- Higher expertise requirement
- More maintenance overhead

**Decision:** Rejected - overhead doesn't match team size or MVP timeline.

### Expo Managed Workflow (no dev builds)

**Pros:**
- Simplest setup
- No native code concerns

**Cons:**
- Limited to Expo SDK modules
- Can't add custom native modules

**Decision:** Rejected - development builds give us SDK convenience + flexibility.

## Consequences

### Positive

- Fast project initialization
- Unified build and deployment via EAS
- OTA updates without third-party service
- Lower native expertise requirement
- Can add native modules via config plugins
- Escape hatch exists (`expo prebuild`)

### Tradeoffs

- Slightly larger app bundle (~10MB overhead)
- EAS free tier limits (30 builds/month for iOS)
- Dependency on Expo ecosystem

### Risks

| Risk | Mitigation |
|------|------------|
| Hit Expo limitation | Use `expo prebuild` to access bare workflow |
| EAS pricing | Monitor usage; can build locally if needed |
| SDK version lock | Expo manages React Native upgrades automatically |

## Implementation Notes

### Project Creation

```bash
# Create Expo project with TypeScript
npx create-expo-app@latest apps/mobile --template blank-typescript

# Install core dependencies
cd apps/mobile
npx expo install expo-camera expo-notifications expo-secure-store expo-local-authentication
```

### EAS Configuration

```json
// eas.json
{
  "cli": {
    "version": ">= 10.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    },
    "production": {
      "ios": {
        "resourceClass": "m1-medium"
      }
    }
  },
  "submit": {
    "production": {}
  }
}
```

### Package.json Scripts

```json
{
  "scripts": {
    "start": "expo start",
    "ios": "expo run:ios",
    "android": "expo run:android",
    "build:ios": "eas build --platform ios",
    "build:android": "eas build --platform android",
    "submit": "eas submit"
  }
}
```

## Validation

Success metrics:
- Project initializes in < 5 minutes
- Local iOS simulator runs without Xcode configuration
- Camera and notifications work in development build
- First TestFlight build via EAS succeeds

## Related Docs

- `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`
- `docs/execution/epics/E01-identity.md`
- `docs/specs/onboarding.md`
