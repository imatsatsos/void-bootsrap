#!/bin/sh
# apply intel-undervolt settings on resume from system sleep state
type intel-undervolt >/dev/null && intel-undervolt apply
