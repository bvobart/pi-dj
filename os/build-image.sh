#!/bin/bash -e
# Builds the Pi-DJ OS customized Raspbian image.

cd "$(dirname "$0")"

here_dir=$(pwd)
work_dir=/tmp/pi-dj
rm -rf $work_dir && mkdir -p $work_dir

echo "> Building Pi-DJ OS in $work_dir"
echo

echo "> Step 1: apply patches to pi-gen"

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
echo "> Step 2: configure pi-gen"

cd "$here_dir"
cp config $work_dir/pi-gen/

echo
echo "> Step 3: TODO: run pi-gen/build-docker.sh"

