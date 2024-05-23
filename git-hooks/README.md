# Pre-commit hook running gitleaks

## Notice: you must have docker installed in your systems for hook to run

Run installer in you code repo root locally to get pre-commit hook installed:

```bash
curl -sSfL "https://raw.githubusercontent.com/kaathepython/telebot/main/git-hooks/pre-commit-installer" | sh
```

Enable gitleaks checking in repo:

```bash
git config --bool hooks.gitleaks true
```

## Example

To ensure it works as intended try committing a file with the following content:

```go
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
```

The commit should be rejected, and `gitleaks` will output the detected secret name and file where it was found.
