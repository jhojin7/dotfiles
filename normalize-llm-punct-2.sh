#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
normalize-llm-punct.sh - normalize common LLM/rich-text punctuation to plain ASCII

Usage:
  normalize-llm-punct.sh [OPTIONS] [FILE|DIR|GLOB ...]
  cat input.md | normalize-llm-punct.sh > output.md

Options:
  -i, --in-place      Rewrite files in place.
  -n, --dry-run       Do not write changes. Report files that would change.
  -v, --verbose       Print processed/skipped files to stderr.
  -h, --help          Show this help.

Input behavior:
  - No input args: read stdin and write normalized text to stdout.
  - FILE args: process exact files.
  - DIR args: recursively process regular files under the directory.
  - GLOB args: supports quoted globs like "*.md", "docs/**/*.md", "**/*.txt".

Examples:
  normalize-llm-punct.sh input.md > clean.md
  normalize-llm-punct.sh -i README.md
  normalize-llm-punct.sh --dry-run --verbose "**/*.md"
  normalize-llm-punct.sh -i "docs/**/*.md" "*.txt"
USAGE
}

inplace=false
dry_run=false
verbose=false
inputs=()
files=()

log() {
  if "$verbose"; then
    printf '%s\n' "$*" >&2
  fi
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

has_glob_meta() {
  case "$1" in
    *'*'*|*'?'*|*'['*) return 0 ;;
    *) return 1 ;;
  esac
}

normalize() {
  perl -CSDA -Mutf8 -pe '
    s/^(\s*)\x{00B7}\s+/$1- /g;  # bullet: · item -> - item
    s/\s*\x{00B7}\s*/, /g;       # inline: A · B -> A, B

    s/\x{2018}/'\''/g;   # left single quote
    s/\x{2019}/'\''/g;   # right single quote / apostrophe
    s/\x{201A}/'\''/g;
    s/\x{201B}/'\''/g;

    s/\x{201C}/"/g;      # left double quote
    s/\x{201D}/"/g;      # right double quote
    s/\x{201E}/"/g;
    s/\x{201F}/"/g;

    s/\x{2013}/-/g;      # en dash
    s/\x{2014}/-/g;      # em dash
    s/\x{2212}/-/g;      # minus sign
    s/\x{2010}/-/g;      # hyphen
    s/\x{2011}/-/g;      # non-breaking hyphen
    s/\x{2012}/-/g;
    s/\x{2015}/-/g;

    s/\x{2026}/.../g;    # ellipsis

    s/\x{00A0}/ /g;      # non-breaking space
    s/\x{2007}/ /g;
    s/\x{202F}/ /g;

    s/\x{200B}//g;       # zero-width space
    s/\x{200C}//g;
    s/\x{200D}//g;
    s/\x{FEFF}//g;

    s/\x{2022}/-/g;      # bullet
    s/\x{25E6}/-/g;
    s/\x{2043}/-/g;

    s/\x{00AE}/(R)/g;    # registered
    s/\x{00A9}/(C)/g;    # copyright
    s/\x{2122}/TM/g;     # trademark
  '
}

is_text_file() {
  perl -e '
    my $file = shift;
    open my $fh, "<:raw", $file or exit 1;
    read $fh, my $buf, 4096;
    exit(($buf =~ /\0/) ? 1 : 0);
  ' "$1"
}

add_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    files+=("$file")
  fi
}

add_dir_recursive() {
  local dir="$1"
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(find "$dir" -type f -print0)
}

expand_recursive_glob() {
  local pattern="$1"
  perl -MFile::Find -CSDA -e '
    use strict;
    use warnings;
    use File::Find;

    my $pat = shift @ARGV;
    my $match_pat = $pat;
    $match_pat =~ s{^\./}{} unless $match_pat =~ m{^/};

    sub has_glob_meta {
      return $_[0] =~ /[*?\[]/;
    }

    sub glob_to_regex {
      my ($p) = @_;
      my $re = q{^};
      my $i = 0;

      while ($i < length($p)) {
        my $c = substr($p, $i, 1);

        if ($c eq q{*}) {
          if (substr($p, $i, 2) eq q{**}) {
            if (substr($p, $i + 2, 1) eq q{/}) {
              $re .= q{(?:[^/]+/)*};
              $i += 3;
              next;
            }
            $re .= q{.*};
            $i += 2;
            next;
          }
          $re .= q{[^/]*};
        } elsif ($c eq q{?}) {
          $re .= q{[^/]};
        } elsif ($c eq q{[}) {
          my $j = index($p, q{]}, $i + 1);
          if ($j > $i) {
            my $class = substr($p, $i, $j - $i + 1);
            $class =~ s{/}{}g;
            $re .= $class;
            $i = $j;
          } else {
            $re .= quotemeta($c);
          }
        } else {
          $re .= quotemeta($c);
        }

        $i++;
      }

      return qr/$re\z/;
    }

    my $root = $pat;
    while (has_glob_meta($root)) {
      my $next = $root;
      $next =~ s{/[^/]*\z}{};

      if ($next eq $root) {
        $root = q{.};
        last;
      }

      $root = length($next) ? $next : q{.};
    }

    $root = q{.} unless -d $root;

    my $re = glob_to_regex($match_pat);

    find({
      no_chdir => 1,
      wanted => sub {
        return unless -f $File::Find::name;

        my $path = $File::Find::name;
        my $match_path = $path;
        $match_path =~ s{^\./}{} unless $match_pat =~ m{^/};

        print $path, "\0" if $match_path =~ $re;
      },
    }, $root);
  ' "$pattern"
}

expand_input() {
  local arg="$1"

  if [[ -f "$arg" ]]; then
    add_file "$arg"
    return
  fi

  if [[ -d "$arg" ]]; then
    add_dir_recursive "$arg"
    return
  fi

  if has_glob_meta "$arg"; then
    local matched=false

    while IFS= read -r -d '' file; do
      matched=true
      add_file "$file"
    done < <(expand_recursive_glob "$arg")

    if ! "$matched"; then
      warn "no matches for pattern: $arg"
    fi

    return
  fi

  warn "not found: $arg"
}

process_file() {
  local file="$1"
  local tmp

  if ! is_text_file "$file"; then
    log "skip binary: $file"
    return 0
  fi

  tmp="$(mktemp)"
  normalize < "$file" > "$tmp"

  if cmp -s "$file" "$tmp"; then
    log "unchanged: $file"
    rm -f "$tmp"
    return 0
  fi

  if "$dry_run"; then
    printf 'would change: %s\n' "$file"
    rm -f "$tmp"
    return 0
  fi

  if "$inplace"; then
    cat "$tmp" > "$file"
    log "changed: $file"
    rm -f "$tmp"
    return 0
  fi

  log "output: $file"
  cat "$tmp"
  rm -f "$tmp"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--in-place)
      inplace=true
      ;;
    -n|--dry-run)
      dry_run=true
      ;;
    -v|--verbose)
      verbose=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        inputs+=("$1")
        shift
      done
      break
      ;;
    -*)
      printf 'error: unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      inputs+=("$1")
      ;;
  esac
  shift
done

if "$dry_run" && [[ "${#inputs[@]}" -eq 0 ]]; then
  printf 'error: --dry-run requires file, directory, or glob input\n' >&2
  exit 2
fi

if [[ "${#inputs[@]}" -eq 0 ]]; then
  normalize
  exit 0
fi

for input in "${inputs[@]}"; do
  expand_input "$input"
done

if [[ "${#files[@]}" -eq 0 ]]; then
  printf 'error: no files matched\n' >&2
  exit 1
fi

for file in "${files[@]}"; do
  process_file "$file"
done
