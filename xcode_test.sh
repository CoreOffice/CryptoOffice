#!/bin/bash

set -ex

sudo xcode-select --switch /Applications/$1.app/Contents/Developer

swift test
