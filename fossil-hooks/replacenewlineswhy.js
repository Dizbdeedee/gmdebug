const replace = require('replace-in-file')
const fs = require('fs')
const readIgnore = fs.readFileSync('.fossil-settings/ignore-glob')
const ignores = readIgnore.toString().split("\n")
ignores.push("*FOSSIL*")
console.log(ignores)
const options = {
	files: '*',
	from: /\r\n/g,
	ignore: ignores,
	to: '\n',
	glob: {
		matchBase: true
	}
}
replace(options, (error, results) => {
  if (error) {
    return console.error('Error occurred:', error);
  }
  console.log('Replacement results:', results);
});