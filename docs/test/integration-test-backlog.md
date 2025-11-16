# Integration Test Backlog

**Purpose**: Track complex user flows that should be tested via Integration/E2E tests rather than brittle unit tests.

**Guidelines** (from test-maintenance.md):
- Complex flows with multiple components → Integration test
- Simple unit logic → Keep as unit test
- Priority: High (core flows) > Medium (common) > Low (edge cases)

---

## Pending Integration Tests

### 1. Profile Management Flow
- **Priority**: Medium
- **Feature**: Profile
- **User Story**: User can view and update their profile information
- **Test Steps**:
  1. User logs in with valid credentials
  2. Navigate to `/profile/edit` route
  3. Profile screen loads user data from repository
  4. User updates fields (name, email, bio, etc.)
  5. User clicks "Save" button
  6. Success snackbar message displays
  7. Navigate to dashboard
  8. Return to `/profile/edit`
  9. Verify changes were persisted
- **Expected Outcome**:
  - Profile updates saved to Isar storage
  - Changes visible immediately without refresh
  - Success feedback shown to user
- **Original Unit Tests**: `test/features/profile/application/notifiers/profile_notifier_test.dart`
  - Deleted due to high complexity (complex provider mocking)
  - Better covered by integration test
- **Blocked By**: None
- **Assigned To**: TBD
- **Status**: Backlog

---

## Completed Integration Tests

_(None yet - this is the initial backlog)_

---

## Guidelines for Adding Tests

When moving a test from unit → integration:

1. **Identify the user flow**: What is the user trying to accomplish?
2. **Document the steps**: List each action the user takes
3. **Define success criteria**: What should happen at each step?
4. **Reference original test**: Link to the unit test being replaced
5. **Set priority**: High (critical path), Medium (common), Low (edge case)

### Priority Guidelines

- **High**: Login, Payment, Core CRUD operations
- **Medium**: Profile management, Settings, Secondary features
- **Low**: Edge cases, Rarely used features

---

## Notes

- Integration tests should focus on **user journeys**, not implementation details
- Prefer fewer, high-value integration tests over many low-value ones
- Update this backlog when removing complex unit tests
- Review quarterly to prioritize and implement highest-value tests

---

## Related Documents

- Test Maintenance Principles: `/Users/pro16/Desktop/project/n06/docs/test-maintenance.md`
- Test Cleanup Analysis: `/Users/pro16/Desktop/project/n06/docs/test-cleanup-analysis.md`
- Integration Test Directory: `/Users/pro16/Desktop/project/n06/integration_test/`
