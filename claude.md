# GLP-1 MVP - Development Orchestration

## When to Use This Guide

**Before coding**: Read this document first to understand the workflow
**During development**: Use as navigation map to relevant documentation
**When stuck**: Check decision trees and critical rules

---


## Critical Rules (Non-negotiable)

### Layer Dependency
```
Presentation → Application → Domain ← Infrastructure
```

**Violation = Immediate rejection**

### Repository Pattern
```
Application/Presentation → Repository Interface (Domain)
                        → Repository Implementation (Infrastructure)
```

**Why**: Phase 1 transition depends on this (1-line change)

---

## Decision Trees

### "Where should this code go?"

```
Is it UI rendering?
  → Presentation Layer (features/{feature}/presentation/)

Is it state management or UseCase orchestration?
  → Application Layer (features/{feature}/application/)

Is it business logic or data model?
  → Domain Layer (features/{feature}/domain/)

Is it database access or DTO conversion?
  → Infrastructure Layer (features/{feature}/infrastructure/)
```

### "What Provider type should I use?"

```
CRUD operations with async?
  → AsyncNotifierProvider (see state-management.md)

Real-time Isar watch?
  → StreamProvider (see state-management.md)

Immutable service or repository?
  → Provider (see state-management.md)

Derived calculation from other providers?
  → Provider (see state-management.md)
```

---


## Common Mistakes

### ❌ NEVER
```dart
// Application accessing Isar directly
final isar = ref.watch(isarProvider); // WRONG

// Skipping Repository interface
class ConcreteRepository { } // WRONG (no interface)

// Domain importing Flutter
import 'package:flutter/material.dart'; // in domain/ folder

// Writing code before test
// (Violates TDD - see docs/tdd.md)
```

### ✅ ALWAYS
```dart
// Use Repository interface
final repo = ref.read(medicationRepositoryProvider);

// Domain defines interface
abstract class MedicationRepository { }

// Infrastructure implements
class IsarMedicationRepository implements MedicationRepository { }

// Test first
test('should...', () { }); // Then write code
```

**Details**: See `docs/code_structure.md` (DO/DON'T sections)

---

## Quick Reference

### File Location Patterns
```
features/{feature}/
  presentation/screens/{feature}_screen.dart
  application/notifiers/{feature}_notifier.dart
  domain/entities/{entity}.dart
  domain/repositories/{feature}_repository.dart
  infrastructure/repositories/isar_{feature}_repository.dart
  infrastructure/dtos/{entity}_dto.dart
```

### Naming Conventions
```
Entity: DoseRecord (domain/entities/)
DTO: DoseRecordDto (infrastructure/dtos/)
Repository Interface: MedicationRepository (domain/repositories/)
Repository Impl: IsarMedicationRepository (infrastructure/repositories/)
Notifier: MedicationNotifier (application/notifiers/)
Provider: medicationNotifierProvider
```

**Full structure**: See `docs/code_structure.md`

---

## Phase 0 → Phase 1 Transition

**Impact**: Infrastructure Layer ONLY (1-line change per repository)

```dart
// Phase 0
@riverpod
MedicationRepository medicationRepository(ref) =>
  IsarMedicationRepository(ref.watch(isarProvider));

// Phase 1
@riverpod
MedicationRepository medicationRepository(ref) =>
  SupabaseMedicationRepository(ref.watch(supabaseProvider));
```

**Zero changes**: Domain, Application, Presentation

**Requirement**: Repository Pattern strictly enforced

**Details**: See `docs/techstack.md` (Phase Transition section)

---

## Before Committing

```
[ ] Tests pass (flutter test)
[ ] No warnings (flutter analyze)
[ ] TDD cycle completed (docs/tdd.md)
[ ] Repository pattern maintained (docs/code_structure.md)
[ ] No layer violations (check imports)
[ ] Performance constraints met (docs/requirements.md)
```

---

## When Stuck

### Architecture questions
→ `docs/code_structure.md`

### State management questions
→ `docs/state-management.md`

### Business logic questions
→ `docs/requirements.md` or `docs/userflow.md`

### Data model questions
→ `docs/database.md`

### Testing questions
→ `docs/tdd.md`

### Technology choice questions
→ `docs/techstack.md`

---

## Core Principles

1. **Separation of Concerns**: Each layer has ONE responsibility (see code_structure.md)
2. **Dependency Inversion**: Depend on interfaces, not implementations (Repository Pattern)
3. **Test-Driven**: Test first, code second (see tdd.md)
4. **Phase Flexibility**: Infrastructure-only changes for Phase 1 (see techstack.md)

## rules
- sot 문서를 작성할 때는 한글로 작성하라.
