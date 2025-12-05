# GitHub Actions Workflows

This directory contains CI/CD workflows for the merklez project.

## Workflows

### test.yml

Main CI pipeline that runs on every push and pull request.

**Jobs:**

1. **test** - Runs Nargo tests
   - Checks out code
   - Installs Nargo using [noirup action](https://github.com/noir-lang/noirup)
   - Compiles the project with `nargo check`
   - Runs all tests with `nargo test`

2. **lint** - Checks code formatting
   - Checks out code
   - Installs Nargo
   - Verifies code formatting with `nargo fmt --check`

**Triggers:**
- Push to main, master, or develop branches
- Pull requests to main, master, or develop branches

## Status Badge

The CI status badge is displayed in the main README:

```markdown
[![CI Tests](https://github.com/olivmath/merklez/actions/workflows/test.yml/badge.svg)](https://github.com/olivmath/merklez/actions/workflows/test.yml)
```

## Local Testing

To run the same checks locally:

```bash
# Check syntax and compile
nargo check

# Run tests
nargo test

# Check formatting
nargo fmt --check

# Auto-format code
nargo fmt
```

## Toolchain

The workflows use the **stable** toolchain of Nargo, installed via the `noir-lang/noirup@v0.1.3` action.

To use a specific version, modify the workflow:

```yaml
- name: Install Nargo
  uses: noir-lang/noirup@v0.1.3
  with:
    toolchain: 0.34.0  # Specify version
```

## Adding More Checks

You can extend the CI with additional jobs:

### Example: Gate Count Check

```yaml
gate-check:
  name: Check Circuit Gates
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: noir-lang/noirup@v0.1.3
      with:
        toolchain: stable
    - run: nargo info
```

### Example: Build Examples

```yaml
examples:
  name: Build Examples
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: noir-lang/noirup@v0.1.3
      with:
        toolchain: stable
    - run: |
        cd examples
        for example in */; do
          cd "$example"
          nargo check
          cd ..
        done
```

## Troubleshooting

If the CI fails:

1. **Syntax errors**: Run `nargo check` locally to see the errors
2. **Test failures**: Run `nargo test` locally with verbose output
3. **Format issues**: Run `nargo fmt` to auto-fix formatting
4. **Nargo version**: Check if you're using a compatible Nargo version

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Noir Documentation](https://noir-lang.org/)
- [noirup Action](https://github.com/noir-lang/noirup)
