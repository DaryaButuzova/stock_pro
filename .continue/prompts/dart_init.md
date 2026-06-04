---
name: dart_init
description: Deep project analysis and architectural memory generation
invokable: true
---
Role: Senior Dart/Flutter Architect.
Objective: Analyze the project to get it context aknowledge.

EXECUTION ALGORITHM (Execute silently, execute all steps strictly in order, but you can call tools in parallel if possible):

STEP 1: Initialization & Root Setup
1.1. Check for existing `.continue/project_memory.md` or `README.md`/`CONTINUE.md` and read them to get context of project.
1.2. Run `project-filesystem` → `list_directory` with path `./` to confirm root structure and obtain the absolute path.
1.3. MANDATORY: Initialize Dart MCP by calling `dart` → `add_roots`.
     - Format: `add_roots(roots=[{"root": "file:///absolute/path/from/step/1.2"}])`
     - If it fails with a format error, ask the user: "Please provide the absolute path to the project root for `add_roots`."
1.4. Wait for successful confirmation. DO NOT proceed until roots are set.
1.5 Obtain current system date from terminal command `date`. If `.continue/project_memory.md` is up to date (not more than a week passed since last edit) finish the prompt execution and notify user about what you've done. Else proceed to the next step.

STEP 2: Architectural Analysis (Use `dart` MCP ONLY for code)
2.1. Read `./pubspec.yaml` (or `./melos.yaml` for monorepos) to determine project type and core dependencies.
2.2. Run map the directory structure without reading every file.
2.3. Identify and `read_file` the "Architectural Pillars": main router, state management setup, network client, and DI configuration.
2.4. If complex/unknown packages are used, query `context7` → `get_documentation` for several key packages to ensure API accuracy.

STEP 3: Error & Issue Detection
3.1. Review `analyze_files` output for critical warnings/errors.
3.2. If obscure errors exist, use `kindly` → `web_search` (append current year, e.g., "flutter error 2026") to find solutions.

STEP 4: Generate Detailed Memory
Use `dart` → `write_file` to create/overwrite `.continue/project_memory.md`. Fill this template MAXIMALLY DETAILED using ONLY facts gathered:

```markdown
# 🧠 Project Memory: [Name from pubspec.yaml]

## 1. Overview & Stack
- **Architecture Type:** (Monorepo with Melos / Single App / Clean Architecture / Feature-first)
- **SDK Version:** (from pubspec.yaml)
- **Key Dependencies:** (Grouped: State Management, Routing, Network, Local Storage, DI, Code Generation)
- **Critical Package Versions:** (Exact versions of core packages)

## 2. Project Structure & Entry Points
- **Entry Points:** (Exact relative paths, e.g., `apps/mobile/lib/main.dart`)
- **Key Directory Tree:** (Brief tree, e.g., `lib/core/` = utils/themes, `lib/features/auth/` = auth module)

## 3. Architectural Pillars (How it works)
- **State Management:** (Specific package, e.g., Riverpod. Global or feature-scoped? Brief code example)
- **Routing:** (Specific package, e.g., go_router. Where is config? Patterns used?)
- **Network & Data:** (e.g., Dio + Retrofit + Freezed. Where are models? Error handling?)
- **Dependency Injection:** (e.g., get_it, riverpod_generator. Setup details)

## 4. API & Integrations
- **Key API Patterns:** (How core packages are used in this project)
- **Version Quirks:** (Any specific version behaviors to note)