// Based off of https://github.com/overextended/ox_lib/blob/master/.github/actions/bump-manifest-version.js
import { readFileSync, writeFileSync } from 'fs'

const version = process.env.TGT_RELEASE_VERSION
const newVersion = version.replace('v', '')

const manifestFile = readFileSync('fxmanifest.lua', {encoding: 'utf8'})

const newFileContent = manifestFile.replace(/\bversion\s+(.*)$/gm, `version '${newVersion}'`)

writeFileSync('fxmanifest.lua', newFileContent)