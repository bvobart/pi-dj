#!/bin/bash -e
# Removes stages 5 completely and remove the contents of stage 4 from pi-gen because they're not necessary for Pi-DJ

rm -rf stage5
rm -rf stage4/0*
