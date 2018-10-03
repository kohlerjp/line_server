#!/usr/bin/env bash

mix deps.get
LINE_PATH=$1 mix phx.server
