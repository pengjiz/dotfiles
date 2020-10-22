# Ensure unique path
typeset -U PATH path

# Conda
function {
  local script='/opt/miniconda3/etc/profile.d/conda.sh'
  [[ -f "$script" ]] && . "$script"
}
