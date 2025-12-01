################################################################################
# Get the URL of the latest release of an asset from Github
################################################################################
#
# $1 = repo, e.g. "asdf-vm/asdf"
# $2 = grep -E pattern to match the asset URL
#
################################################################################
github_latest_asset_url() {
  local repo="$1" pattern="$2"

  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" |
    grep -Po '"browser_download_url":\s*"\K[^"]+' |
    grep -E "$pattern" |
    head -n1
}

################################################################################
# Download the latest matching asset to a file from Github
################################################################################
#
# $1 = repo
# $2 = asset pattern (grep -E)
# $3 = destination file path
#
################################################################################
github_download_latest_asset() {
  local repo="$1" pattern="$2" dest="$3" url

  url="$(github_latest_asset_url "$repo" "$pattern")" || return 1
  if [[ -z "$url" ]]; then
    echo "github_download_latest_asset: no asset matching '$pattern' for repo '$repo'" >&2
    return 1
  fi

  echo "Downloading from: $url"
  curl -fLo "$dest" "$url"
}
