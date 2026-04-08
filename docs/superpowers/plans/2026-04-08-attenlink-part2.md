# AttenLink Implementation Plan - Part 2

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement MCP-style Search Engine selection (Bing, Google, DuckDuckGo, Baidu), AI Fact Report cards with swipe tracking (Believe/Disbelieve), Daily Tracking mechanism, and GitHub Actions CI/CD.

**Architecture:** 
1. **Search Engine MCP:** Add search provider selection in `SettingsRepository`. Implement a `SearchService` that the AI can call as a tool.
2. **Explore Tab Updates:** Introduce `ExploreItem` to differentiate between `News` and `AIFactReport`. Swiping an `AIFactReport` triggers tracking.
3. **Tracking Service:** Save tracked facts locally. A background/startup check will verify tracked items.
4. **CI/CD:** Add `.github/workflows/release.yml` to build APK, Windows, Linux, macOS.

---

### Task 1: Search Engine Settings

**Files:**
- Modify: `lib/data/repositories/settings_repository.dart`
- Modify: `lib/presentation/settings/settings_screen.dart`

- [ ] **Step 1: Update SettingsRepository**
Add keys for `search_provider` and `search_api_key`.

- [ ] **Step 2: Update SettingsScreen**
Add a dropdown for Search Provider (DuckDuckGo, Bing, Google, Baidu) and an API Key field.

### Task 2: Search Service & Tool Calling Integration

**Files:**
- Create: `lib/data/services/search_service.dart`
- Modify: `lib/data/services/ai_service.dart`

- [ ] **Step 1: Implement SearchService**
Implement basic search logic using the selected provider.

- [ ] **Step 2: Update AI Service**
Pass `SearchService` to AI clients so they can use it to fetch context before generating the fact report.

### Task 3: Explore Screen - AI Fact Report Cards & Tracking

**Files:**
- Modify: `lib/presentation/explore/explore_screen.dart`
- Create: `lib/data/services/tracking_service.dart`

- [ ] **Step 1: Implement TrackingService**
Create a service to save "tracked topics" and check them.

- [ ] **Step 2: Update Explore Screen Cards**
Differentiate between News, Fact Report, and Correction cards.
- Swipe News Right -> Insert Fact Report card.
- Swipe Fact Report (Left/Right) -> Add to TrackingService.

### Task 4: GitHub Actions CI/CD

**Files:**
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: Create Release Workflow**
Setup Flutter environment, build APK, Linux, Windows, macOS, and upload artifacts.

### Task 5: Git Init and Push preparation

**Files:**
- None

- [ ] **Step 1: Commit code**
`git init`, `git add .`, `git commit`.
