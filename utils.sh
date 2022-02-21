# Check for GNU sed
SED="sed"
GNU_SED=true
command -v gsed >/dev/null && SED="gsed" || \
  ${SED} --version 2>&1 | grep "GNU" >/dev/null || \
  GNU_SED=false
