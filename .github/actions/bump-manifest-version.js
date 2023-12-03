const fs = require('fs')

const version = process.env.TGT_RELEASE_VERSION
const newVersion = version.replace('v', '')

const manifestFile = fs.readFileSync('fxmanifest.lua', {encoding: 'utf8'})

let newFileContent = manifestFile.replace(/\bversion\s+(.*)$/gm, `version '${newVersion}'`)

if (newFileContent == manifestFile) {
    newFileContent = manifestFile.replace(/\bgame\s+(.*)$/gm, `game 'gta5'\nversion '${newVersion}'`);
}

fs.writeFileSync('fxmanifest.lua', newFileContent)