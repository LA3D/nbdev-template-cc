#!/bin/bash
# nbdev_sync.sh - Custom workflow for nbdev with jupytext
# Place this in the scripts/ directory of your nbdev-template-cc repository

# Configuration (these get replaced in the actual project)
NOTEBOOKS_DIR="nbs"           # nbdev notebooks directory
EDITING_DIR="edit"            # Separate editing directory (non-package)
PACKAGE_DIR="%PROJECT_NAME%"  # Will be replaced during project creation

# Create the editing directory if it doesn't exist
mkdir -p "$EDITING_DIR"

# Function to display help
display_help() {
    echo "nbdev_sync.sh - Custom workflow for nbdev with jupytext"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  to_editing     Sync notebooks to editing directory"
    echo "  from_editing   Sync from editing directory back to notebooks"
    echo "  export         Safely export notebooks to package (syncs from editing first)"
    echo "  all            Run full synchronization and export workflow"
    echo "  build          Run full build process (including nbdev_prepare)"
    echo "  help           Display this help message"
    echo ""
    echo "Example: $0 from_editing"
}

# Command functions
sync_to_editing() {
    echo "📥 Syncing notebooks to editing directory..."
    
    # For each notebook in the notebooks directory
    for nb_file in "$NOTEBOOKS_DIR"/*.ipynb; do
        if [ -f "$nb_file" ]; then
            base_name=$(basename "$nb_file" .ipynb)
            edit_file="$EDITING_DIR/${base_name}.py"
            
            # Convert notebook to Python file in editing directory using jupytext
            jupytext --to py:percent "$nb_file" -o "$edit_file"
            echo "  ✓ Synced $nb_file → $edit_file"
        fi
    done
    
    echo "✅ Notebooks synced to editing directory"
}

sync_from_editing() {
    echo "📤 Syncing from editing directory back to notebooks..."
    
    # For each Python file in the editing directory
    for edit_file in "$EDITING_DIR"/*.py; do
        if [ -f "$edit_file" ]; then
            base_name=$(basename "$edit_file" .py)
            nb_file="$NOTEBOOKS_DIR/${base_name}.ipynb"
            
            if [ -f "$nb_file" ]; then
                # Update existing notebook
                jupytext --update --to notebook "$edit_file" -o "$nb_file"
                echo "  ✓ Updated $nb_file from $edit_file"
            else
                # Create new notebook
                jupytext --to notebook "$edit_file" -o "$nb_file"
                echo "  ✓ Created $nb_file from $edit_file"
            fi
        fi
    done
    
    echo "✅ Changes synced back to notebooks"
}

safe_export() {
    echo "📦 Safely exporting notebooks to package..."
    
    # First sync any changes from editing directory back to notebooks
    sync_from_editing
    
    # Then run nbdev_export to update the package
    nbdev_export
    
    echo "✅ Package safely exported"
}

run_all() {
    echo "🔄 Running full synchronization and export workflow..."
    
    # Sync from editing to notebooks
    sync_from_editing
    
    # Run nbdev_export to update the package
    nbdev_export
    
    # Sync notebooks back to editing directory (to capture any nbdev changes)
    sync_to_editing
    
    echo "✅ Full synchronization and export completed"
}

build_all() {
    echo "🏗️ Running full build process..."
    
    # Sync from editing to notebooks
    sync_from_editing
    
    # Run full nbdev pipeline
    nbdev_prepare
    
    # Sync notebooks back to editing directory
    sync_to_editing
    
    echo "✅ Full build completed"
}

# Command handler
case "$1" in
    to_editing)
        sync_to_editing
        ;;
    from_editing)
        sync_from_editing
        ;;
    export)
        safe_export
        ;;
    all)
        run_all
        ;;
    build)
        build_all
        ;;
    help)
        display_help
        ;;
    *)
        display_help
        ;;
esac