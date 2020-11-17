#!/usr/bin/env bash

source "$(dirname $0)/base.sh"

function _render {
  hugo --minify --verbose --environment production
}

_render
