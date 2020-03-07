# Conda
function {
  local conda_path='/opt/miniconda3'
  local conda_script="$conda_path/etc/profile.d/conda.sh"
  if [[ -f "$conda_script" && -r "$conda_script" ]]; then
    . "$conda_script"
  fi
}