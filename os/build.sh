#!/bin/bash -e
# Builds the Pi-DJ OS customized Raspbian image.
cd "$(dirname "$0")"
target="$1"

here_dir=$(pwd)
work_dir=/tmp/pi-dj
rm -rf $work_dir && mkdir -p $work_dir

function usage() {
  echo "Usage: $0 [generator | image]"
  echo "> generator: build the Pi-DJ OS image generator"
  echo "> image: build the Pi-DJ OS image generator, then use it to generate the Pi-DJ OS image"
}

if [[ "$target" == "help" ]] || [[ "$target" == "--help" ]] || [[ "$target" == "-h" ]]; then
  usage
fi

if [[ -z "$target" ]]; then
  echo "> Error: no target specified."
  echo
  usage
  exit
fi

echo
echo "> Building Pi-DJ OS in $work_dir"
echo "> - Target: $target"
echo

function build_generator {
  echo "> applying patches to pi-gen..."

  cp -r pi-gen $work_dir/
  for file in ./patches/*; do
    cd "$work_dir/pi-gen"

    echo "$file"

    # Run every .sh file we find onto pi-gen
    if [[ "$file" == *.sh ]]; then
      "$here_dir/$file"
    fi

    # Apply every patch file we find onto pi-gen
    if [[ "$file" == *.patch ]]; then
      patch --silent < "$here_dir/$file"
    fi

    cd "$here_dir"
  done

  echo
  echo "> Success! Target: generator"
  echo
}

function build_image() {
  build_generator

  echo "> Step 2: configure pi-gen"

  cd "$here_dir"
  cp config $work_dir/pi-gen/

  echo
  echo "> Step 3: TODO: run pi-gen/build-docker.sh"
  echo

  $work_dir/pi-gen/build-docker.sh
}

case "$target" in
  generator)
    build_generator
    exit
    ;;
  image)
    build_image
    exit
    ;;
  *)
    echo "> Error: invalid target: $target"
    echo
    usage
    exit 1
    ;;
esac
