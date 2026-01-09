#!/bin/bash
export GRADLE_OPTS="-XX:+IgnoreUnrecognizedVMOptions --add-modules jdk.incubator.vector"
./gradlew assembleDebug
