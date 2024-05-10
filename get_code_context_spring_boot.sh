#!/bin/bash

# This works for Spring Boot projects with Gradle
# Put this in your root folder of your project
# run the command chmod +x get_code_context_spring_boot.sh
# then run ./get_code_context_spring_boot.sh

# Use the current directory as the project directory
project_dir=$(pwd)

# Extract the project name from build.gradle
project_name=$(grep 'rootProject.name' build.gradle | awk -F '=' '{print $2}' | tr -d "' " | tr -d "\n")

# Use a dynamic name for the output file in the current directory based on the project name
output_file="${project_dir}/${project_name}_code_context.txt"

# Check if the output file exists and remove it if it does
if [ -f "$output_file" ]; then
  rm "$output_file"
fi

# List of directories to look for
directories=("src/main/java" "src/main/resources" "src/test/java")

# List of file types to ignore
ignore_files=("*.ico" "*.png" "*.jpg" "*.jpeg" "*.gif" "*.svg")

# Recursive function to read files and append their content
read_files() {
  for entry in "$1"/*
  do
    if [ -d "$entry" ]; then
      # If entry is a directory, call this function recursively
      read_files "$entry"
    elif [ -f "$entry" ]; then
      # Check if the file type should be ignored
      should_ignore=false
      for ignore_pattern in "${ignore_files[@]}"; do
        if [[ "$entry" == $ignore_pattern ]]; then
          should_ignore=true
          break
        fi
      done

      # If the file type should not be ignored, append its relative path and content to the output file
      if ! $should_ignore; then
        relative_path=${entry#"$project_dir/"}
        echo "// File: $relative_path" >> "$output_file"
        cat "$entry" >> "$output_file"
        echo "" >> "$output_file"
      fi
    fi
  done
}

# Call the recursive function for each specified directory in the project directory
for dir in "${directories[@]}"; do
  if [ -d "${project_dir}/${dir}" ]; then
    read_files "${project_dir}/${dir}"
  fi
done

# Include the build.gradle file if it exists
if [ -f "${project_dir}/build.gradle" ]; then
  echo "// File: build.gradle" >> "$output_file"
  cat "${project_dir}/build.gradle" >> "$output_file"
  echo "" >> "$output_file"
fi
