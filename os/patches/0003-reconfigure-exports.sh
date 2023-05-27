#!/bin/bash -e
# Removes the export-noobs folder from pi-gen.

# export the -lite image from stage 3
mv stage2/EXPORT_IMAGE stage3/EXPORT_IMAGE

# remove all EXPORT_NOOBS
rm stage2/EXPORT_NOOBS
rm stage4/EXPORT_NOOBS
