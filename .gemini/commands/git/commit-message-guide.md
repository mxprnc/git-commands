# Git Commit Message Guide (Conventional Commits)

This document defines the standard Git commit message conventions for the project. All team members must adhere to this guide to ensure consistency and readability of the commit history.

> [!IMPORTANT]
> All commit messages (Header, Body, and Footer) must be written exclusively in **English**.

---

## 1. Basic Structure of a Commit Message

A commit message consists of three main elements: **Header**, **Body**, and **Footer**, with each element separated by an empty line.

```text
<type>(<scope>): <subject>  # Header (Required)

<body>                      # Body (Optional - write when detailed explanation is needed)

<footer>                    # Footer (Optional - write for referencing issue tracker IDs, etc.)
```

### Correct Full Example
```text
feat(editor): implement split-view mode for markdown files

Allow users to view the raw markdown editor and the rendered preview
side-by-side. This mode can be toggled via the toolbar button.

Resolves: #104, #112
See-also: docs/product/split-view.md
```

---

## 2. Main Commit Types used in the Header (`type`)

*   `feat`: Adding a new feature
*   `fix`: Fixing a bug
*   `docs`: Documentation changes (README.md, comments, etc., with no code changes)
*   `style`: Formatting changes (whitespace, missing semicolons, etc., with no semantic code changes)
*   `refactor`: Code refactoring (structural improvements without adding features or fixing bugs)
*   `test`: Adding or modifying test code (no changes to production code)
*   `chore`: Build tasks, package manager configuration, simple configuration changes, etc.
*   `perf`: Code changes aimed at improving performance
*   `ci`: Modifications to CI configuration files and scripts
*   `revert`: Reverting a previous commit

---

## 3. Seven Rules for a Great Git Commit Message (Chris Beams' Rules)

1.  **Separate subject from body with a blank line.** (Allows commands like `git log --oneline` to display cleanly)
2.  **Limit the subject line to 50 characters.** (Prevents truncation in GitHub UI and other tools)
3.  **Capitalize the subject line.**
4.  **Do not end the subject line with a period.**
5.  **Use the imperative mood in the subject line.**
    *   Start with a verb in the base form: `Add feature` (O) / `Added feature` (X), `Adds feature` (X)
6.  **Wrap the body at 72 characters.** (Ensures readability in CLI terminals)
7.  **Use the body to explain what and why vs. how.**

---

## 4. AI-Powered Git Commit Helper (Automation Tool Guide)

The project includes built-in **AI Helper Tools** designed to automatically enforce commit message conventions, translate inputs to English, and summarize changes.

Because the AI directly analyzes the `git diff` of staged changes to generate commit messages, developers can adhere to the standards perfectly without the need for manual English composition.

### 🛠️ Available Interfaces

These **AI Custom Commands** are used within the Gemini CLI chat session for precise collaboration and step-by-step commit execution.

1. **`/git:commit-message [intent]`**
   - **Description**: Analyzes the diff of currently staged files to generate an English commit message.
   - **Storage Location**: Saved temporarily as `<type>-<subject-kebab-case>/<id>.md` under the [.gemini/commands/git/git-temp/](git-temp/) folder.
   - **Metadata Storage**: Automatically embeds a list of staged files, sizes, and hashes at the bottom of the file inside a `<!-- gemini-cli-metadata -->` comment block.
   - **Editing Guide**: Displays the generated message and the temp file path, allowing the user to open and edit the markdown file directly.

2. **`/git:commit`**
   - **Description**: Confirms and executes the actual git commit using the prepared draft.
   - **Safeguard (Diff Comparison)**: If staged files change after the message is generated, it compares the metadata hashes, reports the discrepancy to the user, and asks whether to regenerate the message or keep the current draft.
   - **Comment Filtering (Strip)**: Before saving the commit history, it **completely filters out** the `<!-- gemini-cli-metadata -->` comment block from the bottom of the draft, leaving only the clean message text in the commit log.
   - **Temporary File Cleanup**: Once the commit succeeds, the associated temporary directories under `.gemini/commands/git/git-temp/` are deleted automatically.

3. **`/git:force-commit`**
   - **Description**: An automation feature where the AI immediately writes a high-quality English commit message based on staged files, strips metadata comments, and executes the commit directly without review or confirmation prompts.

---

> [!TIP]
> **Tips for Successful Automation**:
> - Arguments specifying your intent (e.g., `"docs: (README) add guide documentation"`) can be input in **any language (Korean, Japanese, Chinese, etc.)** and will be fully analyzed and converted into a standard English Conventional Commit message.
> - If no staged files are detected, commands will trigger a safeguard, prompt you to run `git add` first, and terminate safely.
