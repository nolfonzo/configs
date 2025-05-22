# Summary: Defines addhash and rmhash functions for managing zsh directory hashes.
# addhash: Creates a hash with a sanitized name for the current or specified directory.
# Usage: addhash [-f] [name] [directory]. Defaults to basename of directory if name omitted, $PWD if directory omitted.
# -f overwrites existing hashes. Sanitizes name to alphanumeric and underscores.
# Hashes are stored in ~/.config/zsh/hashes.zsh, sourced by ~/.config/zsh/.zshrc.
addhash() {
  local force=0
  local name raw_name sanitized_name dir
  local hashfile="$HOME/.config/zsh/hashes.zsh"

  # Check for -f flag
  if [[ "$1" == "-f" ]]; then
    force=1
    shift
  fi

  # Set raw name to provided argument or basename of target directory
  dir="${2:-$PWD}"
  raw_name="${1:-$(basename "$dir")}"

  # Validate directory
  if [[ ! -d "$dir" ]]; then
    echo "Error: '$dir' is not a directory"
    return 1
  fi

  # Sanitize the name: replace spaces and special characters with underscores, remove problematic chars
  sanitized_name=$(echo "$raw_name" | tr ' [:punct:]' '_' | sed 's/[^a-zA-Z0-9_]//g')

  # Check if sanitized name is empty
  if [[ -z "$sanitized_name" ]]; then
    echo "Error: Invalid hash name after sanitization"
    return 1
  fi

  # Check for duplicate hash name
  if [[ $force -eq 0 && -n "$(hash -d | grep "^$sanitized_name=")" ]]; then
    echo "Error: Hash name '$sanitized_name' already exists. Use -f to force overwrite or rmhash to remove."
    return 1
  fi

  # Check if ~/.config/zsh/hashes.zsh exists and is writable
  if [[ ! -f "$hashfile" ]]; then
    echo "Debug: Creating $hashfile"
    mkdir -p ~/.config/zsh
    touch "$hashfile" || { echo "Error: Cannot create $hashfile"; return 1; }
  fi
  if [[ ! -w "$hashfile" ]]; then
    echo "Error: $hashfile is not writable"
    return 1
  fi

  # Backup ~/.config/zsh/hashes.zsh before modifying
  cp "$hashfile" "$hashfile.bak" && echo "Debug: Backed up $hashfile to $hashfile.bak"

  # If forcing, remove existing hash line from ~/.config/zsh/hashes.zsh
  if [[ $force -eq 1 && -n "$(hash -d | grep "^$sanitized_name=")" ]]; then
    sed -i '' "/^hash -d $sanitized_name=/d" "$hashfile" && echo "Debug: Removed existing hash '$sanitized_name' from $hashfile"
  fi

  # Add the new hash
  hash -d "$sanitized_name=$dir"
  echo "hash -d $sanitized_name=$dir" >> "$hashfile" && echo "Debug: Appended hash to $hashfile"
  source "$hashfile" && echo "Debug: Sourced $hashfile"
  echo "Added ~$sanitized_name for $dir"
}

# Summary: Removes a zsh directory hash from the current session and ~/.config/zsh/hashes.zsh.
# Usage: rmhash [-f] <name>. Removes the specified hash name if it exists. -f ignores non-existent hashes.
rmhash() {
  local force=0
  local name
  local hashfile="$HOME/.config/zsh/hashes.zsh"

  # Check for -f flag
  if [[ "$1" == "-f" ]]; then
    force=1
    shift
  fi

  # Set name
  name="$1"
  echo "Debug: Processing hash name: '$name'"

  # Check for invalid name
  if [[ -z "$name" || "$name" == -* ]]; then
    echo "Error: Invalid hash name '$name'. Use 'rmhash [-f] <name>'."
    return 1
  fi

  # Check if the hash exists
  echo "Debug: Checking if hash '$name' exists in session"
  if ! hash -d | grep -q "^$name="; then
    if [[ $force -eq 1 ]]; then
      echo "Debug: Hash '$name' does not exist, skipping (force enabled)"
      return 0
    else
      echo "Error: Hash name '$name' does not exist"
      return 1
    fi
  fi

  # Check if ~/.config/zsh/hashes.zsh exists and is writable
  if [[ ! -f "$hashfile" ]]; then
    echo "Error: $hashfile does not exist"
    return 1
  fi
  if [[ ! -w "$hashfile" ]]; then
    echo "Error: $hashfile is not writable"
    return 1
  fi

  # Backup ~/.config/zsh/hashes.zsh before modifying
  cp "$hashfile" "$hashfile.bak" && echo "Debug: Backed up $hashfile"

  # Check if the hash exists in ~/.config/zsh/hashes.zsh and remove it
  if grep -q "^hash -d $name=" "$hashfile"; then
    sed -i '' "/^hash -d $name=/d" "$hashfile" && echo "Debug: Removed hash '$name' from $hashfile"
  else
    echo "Debug: Hash '$name' not found in $hashfile"
  fi

  # Remove the hash from the current session using built-in unhash
  echo "Debug: Removing hash '$name' from session"
  builtin unhash -d "$name"

  source "$hashfile" && echo "Debug: Sourced $hashfile"
  echo "Removed ~$name"
}
