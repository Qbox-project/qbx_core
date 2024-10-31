const fs = require('fs')

const version = process.env.TGT_RELEASE_VERSION
const newVersion = version.replace('v', '')

const manifestFile = fs.readFileSync('fxmanifest.lua', {encoding: 'utf8'})

const versionStr = `version '${newVersion}'`
let newFileContent = manifestFile.replace(/\bversion\s+(.*)$/gm, versionStr)

if (!newFileContent.includes(versionStr)) {
    newFileContent = manifestFile.replace(/\bgame\s+(.*)$/gm, `game 'gta5'\n${versionStr}`);
}

fs.writeFileSync('fxmanifest.lua', newFileContent)