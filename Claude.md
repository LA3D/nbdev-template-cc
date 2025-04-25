# Project Information for Claude Code

This project uses a custom workflow integrating nbdev, jupytext, rich-cli, and uv for efficient notebook development and package management.

## Project Structure

```
project/

├── 00_core.ipynb
├── Claude.md
├── LICENSE
├── MANIFEST.in
├── README.md
├── index.ipynb
├── pyproject.toml
├── references.bib
├── scripts
│   └── nbdev_sync.sh
├── settings.ini
├── setup.py
└── styles.css
```

## Package Management with uv

This project uses uv for fast, efficient package management. Key files:

- **pyproject.toml**: Defines project metadata and dependencies
- **uv.lock**: Lock file containing exact dependency specifications (never edit manually)
- **.python-version**: Specifies the Python version for the environment

### Key uv Commands

```bash
# Install dependencies in pyproject.toml
uv sync

# Add a new dependency
uv add package_name

# Add a dev dependency
uv add --dev package_name

# Update lock file without installing
uv lock

# View dependency tree
uv tree

# Run a command in the project environment
uv run python script.py
```

### Best Practices for uv

1. **Always commit the uv.lock file to version control**
   - This ensures all developers use the same dependency versions
   - The lock file is essential for reproducible environments

2. **Use dependency groups for development dependencies**
   - Add dev tools with `uv add --dev package_name`
   - This will create an entry in the `[dependency-groups]` table

3. **Sync before running code**
   - Use `uv sync` to ensure your environment matches your dependencies
   - This happens automatically with `uv run` but can be done manually

4. **Update dependencies intentionally**
   - Use `uv add --upgrade-package package_name` to update a specific package
   - This preserves other locked versions while updating just what you need

## Workflow Options

This project supports multiple workflows:

### 1. Notebook-to-Edit-to-Package Flow

The standard nbdev workflow with jupytext integration:
1. Create/edit Jupyter notebooks in the `nbs/` directory
2. Use the custom sync script to generate paired Python files in `edit/`
3. Modify Python files in `edit/` when needed
4. Sync changes back to notebooks
5. Export to package code

### 2. View & Inspect Using rich-cli

Use rich-cli to view and inspect notebooks directly in the terminal:

```bash
# View a notebook with syntax highlighting
rich nbs/00_core.ipynb

# Add line numbers
rich nbs/00_core.ipynb --line-numbers

# Use a specific theme
rich nbs/00_core.ipynb --theme monokai
```

## GitHub Integration

### Committing Changes

When committing changes to GitHub, follow these practices:

1. **Always include the uv.lock file**
   - The lock file should be committed to version control to ensure all developers use the same dependency versions

2. **Run nbdev_prepare before committing**
   - Ensures Python modules are exported
   - Cleans notebook metadata
   - Runs tests

3. **Include .python-version in commits**
   - This ensures everyone uses the same Python version

### GitHub Actions Workflow

For continuous integration with GitHub Actions:

```yaml
# Example minimal workflow
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install uv
        uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true
          cache-dependency-glob: "uv.lock"
      - name: Set up Python
        run: uv python install
      - name: Install dependencies
        run: uv sync
      - name: Test
        run: uv run nbdev_test
```

## Working with Claude Code

### Editing Options

1. **Edit Python files in `edit/` directory**:
   ```bash
   claude "Add a function to calculate statistics in edit/00_core.py"
   ```
   Then sync changes: `./scripts/nbdev_sync.sh from_editing`

2. **Review notebooks using rich-cli**:
   ```bash
   # Ask Claude to examine notebook content
   claude "Use rich-cli to view nbs/00_core.ipynb and explain what it does"
   ```

3. **Manage dependencies with uv**:
   ```bash
   # Ask Claude to add dependencies
   claude "Add scipy and matplotlib to our project using uv"
   ```

### Example Development Workflow

```bash
# 1. Add a new dependency
claude "Add pandas to our project using uv"
uv add pandas

# 2. Edit the Python file
claude "Create a function read_data in edit/00_core.py that loads a CSV using pandas"

# 3. Sync changes to notebooks
./scripts/nbdev_sync.sh from_editing

# 4. View the notebook changes
rich nbs/00_core.ipynb

# 5. Export to package and run tests
./scripts/nbdev_sync.sh export
uv run nbdev_test
```

## nbdev_sync.sh Commands

- `./scripts/nbdev_sync.sh to_editing` - Sync notebooks to editing files
- `./scripts/nbdev_sync.sh from_editing` - Sync editing files to notebooks
- `./scripts/nbdev_sync.sh export` - Safely export to package
- `./scripts/nbdev_sync.sh all` - Run full synchronization cycle
- `./scripts/nbdev_sync.sh build` - Run complete build process

## Troubleshooting

If you encounter issues:

1. **Desynchronization between notebooks and editing files:**
   - Run `./scripts/nbdev_sync.sh all` to fully resynchronize everything

2. **Package installation issues:**
   - Run `uv sync` to ensure dependencies are installed correctly
   - Check for conflicts in the uv.lock file by looking at the error messages
   - Try `uv sync --upgrade-package problematic_package` to resolve version conflicts

3. **Python version issues:**
   - Ensure your .python-version file contains a valid Python version
   - Use `uv python install 3.10` (or your version) to install the correct Python
   - Run `uv sync` after changing Python versions