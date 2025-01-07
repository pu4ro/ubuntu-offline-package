cat << 'EOF' > download_and_generate.sh
#!/bin/bash

# Script to download dependencies and generate repository metadata for Rocky Linux

# Set the working directory
WORK_DIR="$HOME/local-repo"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Function to download a package and its dependencies
download_deps() {
    local package=$1
    echo "Downloading: $package"
    # Download the main package
    dnf download $package --resolve --alldeps --destdir=$WORK_DIR

    # List dependencies
    local depends=$(dnf repoquery --requires --resolve $package | awk '{print $1}')
    for dep in $depends
    do
        # Check if the dependency has already been processed
        if ! grep -q "^$dep$" downloaded.txt; then
            echo $dep >> downloaded.txt
            download_deps $dep
        fi
    done
}

# Initialize the file to track downloaded packages
echo "" > downloaded.txt

# Process each package name provided as a command line argument
for pkg in "$@"
do
    if ! grep -q "^$pkg$" downloaded.txt; then
        echo $pkg >> downloaded.txt
        download_deps $pkg
    fi
done

# Use createrepo to generate repository metadata
if ! command -v createrepo &>/dev/null; then
    echo "createrepo is not installed. Installing..."
    sudo dnf install -y createrepo
fi

createrepo $WORK_DIR
echo "Repository metadata has been generated."

# Clean up temporary file
rm downloaded.txt

# Print completion message
echo "All tasks have been completed."
