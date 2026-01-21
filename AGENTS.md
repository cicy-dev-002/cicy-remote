# AGENTS.md - Agent Guidelines for cicy-remote Repository

## Overview

This repository contains automation scripts and GitHub Actions workflows for setting up remote desktop environments (VNC, RDP) on Ubuntu and Windows systems. The primary languages used are Bash shell scripts, PowerShell scripts, and YAML for CI/CD workflows.

## Build Commands

Since this is an infrastructure automation project, there are no traditional build processes. However, the following commands can be used to "build" or validate the setup:

- **Validate scripts syntax**: Run shell scripts through syntax checking
  - Bash: `bash -n script.sh`
  - PowerShell: `powershell -Command "& { $ast = [System.Management.Automation.Language.Parser]::ParseFile('script.ps1', [ref]$null, [ref]$null); if ($ast) { 'Syntax OK' } else { 'Syntax Error' } }"`

- **Run installation scripts**: Execute the main setup scripts
  - Ubuntu VNC: `bash vnc/install.sh`
  - Windows RDP: `powershell -ExecutionPolicy Bypass -File workflows/scripts/win-establish-rdp.ps1`

## Lint Commands

Linting ensures code quality and catches potential issues:

- **Bash scripts**: Use `shellcheck`
  - All bash scripts: `find . -name "*.sh" -exec shellcheck {} \;`
  - Single script: `shellcheck path/to/script.sh`
  - With warnings: `shellcheck -W 3 path/to/script.sh`

- **PowerShell scripts**: Use `PSScriptAnalyzer`
  - Install: `Install-Module -Name PSScriptAnalyzer -Scope CurrentUser`
  - All PowerShell scripts: `Get-ChildItem -Path . -Filter "*.ps1" -Recurse | Invoke-ScriptAnalyzer`
  - Single script: `Invoke-ScriptAnalyzer -Path path/to/script.ps1`
  - With severity filter: `Invoke-ScriptAnalyzer -Path path/to/script.ps1 -Severity Warning,Error`

- **YAML workflows**: Use `yamllint`
  - Install: `pip install yamllint`
  - All workflows: `yamllint .github/workflows/`
  - Single workflow: `yamllint .github/workflows/filename.yml`

## Test Commands

Testing in this repository primarily involves validating script execution and checking for runtime errors. There are no unit tests, but you can test scripts by:

- **Running a single script in dry-run mode**: For bash scripts that support it
  - Example: Add `set -n` at the top for syntax-only execution

- **Validate workflow YAML**: Use GitHub's workflow validator
  - Via CLI: `gh workflow run --ref main workflow-file.yml` (requires gh CLI)
  - Check syntax: `python -c "import yaml; yaml.safe_load(open('.github/workflows/workflow.yml'))"`

- **Test script functionality**:
  - Create a test environment (e.g., Docker container)
  - Run scripts with mock inputs
  - Example: `docker run --rm ubuntu:20.04 bash -c "apt update && bash /path/to/script.sh"`

- **Integration testing**: Run the full GitHub Actions locally using `act`
  - Install: `curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash`
  - Run workflow: `act -j job-name`

## Code Style Guidelines

### General Principles

- Write clear, readable, and maintainable code
- Include comments for complex logic or non-obvious operations
- Use meaningful variable and function names
- Follow the principle of least surprise
- Handle errors gracefully and provide informative error messages
- Avoid hardcoding sensitive information (use environment variables or secrets)

### Bash Scripts

#### File Structure
- Start with shebang: `#!/bin/bash`
- Include `set -e` for strict error handling (unless intentionally allowing failures)
- Use `set -u` to treat unset variables as errors
- Add script description and usage at the top

#### Syntax and Formatting
- Use 4 spaces for indentation (no tabs)
- Keep lines under 80-100 characters
- Use double quotes for strings containing variables: `"$variable"`
- Use single quotes for literal strings: `'literal'`
- Use `[[ ]]` for conditional expressions instead of `[ ]`
- Use `$()` for command substitution instead of backticks

#### Variables and Functions
- Use UPPERCASE for global constants: `readonly MAX_RETRIES=3`
- Use lowercase with underscores for local variables: `local user_name="user"`
- Function names: `function_name()` or `function function_name()`
- Use `local` for function variables
- Export environment variables explicitly: `export VARIABLE_NAME`

#### Error Handling
- Check command exit codes: `command || { echo "Error message"; exit 1; }`
- Use traps for cleanup: `trap 'cleanup_function' EXIT`
- Provide meaningful error messages with context
- Log errors to stderr: `echo "Error: description" >&2`

#### Best Practices
- Use `printf` instead of `echo` for portability
- Avoid `eval` unless absolutely necessary
- Use `mktemp` for temporary files
- Check for required commands: `command -v tool >/dev/null || { echo "tool required"; exit 1; }`
- Use arrays for lists: `declare -a items=("item1" "item2")`

### PowerShell Scripts

#### File Structure
- Use UTF-8 encoding
- Include comment-based help at the top
- Use strict mode: `Set-StrictMode -Version Latest`
- Enable verbose preference for debugging

#### Syntax and Formatting
- Use PascalCase for cmdlet names and parameters
- Use camelCase for variables and function names
- Indent with 4 spaces
- Keep lines under 100 characters
- Use splatting for long parameter lists

#### Variables and Functions
- Use descriptive variable names: `$userName` instead of `$u`
- Use `[CmdletBinding()]` for advanced functions
- Include parameter validation: `[Parameter(Mandatory=$true)]`
- Use `[ValidateSet()]` for parameter constraints

#### Error Handling
- Use `try/catch/finally` blocks
- Set `$ErrorActionPreference = "Stop"` for strict error handling
- Use `Write-Error` for error messages
- Log errors with appropriate severity

#### Best Practices
- Avoid aliases in scripts (use full cmdlet names)
- Use `Write-Verbose` for debugging information
- Implement `WhatIf` and `Confirm` parameters for destructive operations
- Use modules for reusable code
- Follow PowerShell naming conventions

### YAML Workflows

#### Structure
- Use consistent indentation (2 spaces)
- Include workflow name and description
- Use meaningful job and step names
- Group related steps logically

#### Syntax
- Use quotes for strings containing special characters
- Use multi-line strings with `|` for scripts
- Keep values aligned for readability
- Use anchors and aliases for repeated configurations

#### Best Practices
- Use environment variables for secrets: `${{ secrets.SECRET_NAME }}`
- Cache dependencies when possible
- Set appropriate timeouts: `timeout-minutes: 3600`
- Use matrix builds for multiple configurations
- Include cleanup steps when necessary

### Naming Conventions

#### Files
- Bash scripts: `lowercase-with-dashes.sh`
- PowerShell scripts: `PascalCase.ps1`
- Workflows: `kebab-case.yml`

#### Variables
- Bash: `snake_case`
- PowerShell: `camelCase`
- Environment variables: `UPPER_CASE_WITH_UNDERSCORES`

#### Functions/Commands
- Bash: `snake_case`
- PowerShell: `PascalCase`

### Imports and Dependencies

#### Bash
- Source external scripts: `source /path/to/script.sh`
- Check for required tools before use
- Use absolute paths when possible

#### PowerShell
- Import modules: `Import-Module ModuleName`
- Use `using module` for class-based modules
- Specify minimum versions when importing

### Error Handling Patterns

#### Bash
```bash
function handle_error() {
    echo "Error: $1" >&2
    exit 1
}

command || handle_error "Command failed"
```

#### PowerShell
```powershell
try {
    # Code that might fail
} catch {
    Write-Error "An error occurred: $_"
    throw
} finally {
    # Cleanup code
}
```

### Security Considerations

- Never hardcode passwords or API keys
- Use environment variables or secure storage for secrets
- Validate user inputs to prevent injection attacks
- Run scripts with least privilege required
- Audit code for security vulnerabilities regularly

### Documentation

- Include inline comments for complex logic
- Use README files for setup instructions
- Document function parameters and return values
- Keep documentation up to date with code changes

### Version Control

- Commit related changes together
- Use descriptive commit messages
- Follow conventional commit format when applicable
- Review code changes before merging

This document should be updated as the codebase evolves and new conventions are established.</content>
<parameter name="filePath">/Users/data/github/cicy-remote/AGENTS.md