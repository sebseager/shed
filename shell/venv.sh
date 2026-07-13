##
# venv-cli shell integration
##

# bin/ should already be on PATH by the time this loads
if command -v venv-cli >/dev/null 2>&1; then
    eval "$(venv-cli shellenv)"
fi
