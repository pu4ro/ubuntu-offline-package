cat << 'EOF' > download_and_generate.sh
#!/bin/bash

# Script to download dependencies and generate metadata

# Set the working directory
WORK_DIR="$HOME/local-repo"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Function to download a package and its dependencies
download_deps() {
    local package=$1
    echo "Downloading: $package"
    apt-get download $package 2>/dev/null
    local depends=$(apt-cache depends $package | grep 'Depends' | sed "s/.*Depends: //" | sed 's/<[^>]*>//g' | tr '\n' ' ')
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

# Use dpkg-scanpackages to create the Packages.gz file
dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz
echo "Package metadata has been generated."

# Clean up temporary file
rm downloaded.txt

# Print completion message
echo "All tasks have been completed."
EOF

# Grant execute permission to the script
chmod +x download_and_generate.sh