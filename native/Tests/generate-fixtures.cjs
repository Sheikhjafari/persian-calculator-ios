// Run from any directory: node native/Tests/generate-fixtures.cjs
const { Calculator } = require('../../web/calculator.js');
const fs = require('node:fs');
const path = require('node:path');
const sequences = [
 ['0','.','1','+','0','.','2','='],
 ['1','-','1','.','0','0','1','='],
 ['9','+','-','2','='], ['1','+','sign','2','='],
 ['1','+','2','+','3','='], ['1','+','='],
 ['1','+','2','=','4'], ['1','+','2','=','back'],
 ['sign','back'], ['1','.','.','2'], Array(22).fill('9'),
 [...Array(18).fill('9'),'+','1','='],
 ['1','+','2','clear','4'], ['1','+','2','=','sign','+','4','=']
];
let seed = 1037;
const keys = ['0','1','2','3','4','5','6','7','8','9','.','+','-','=','sign','back','clear'];
for (let run = 0; run < 200; run++) {
 const sequence = [];
 for (let i = 0; i < 80; i++) {
  seed = (Math.imul(seed,1664525) + 1013904223) >>> 0;
  sequence.push(keys[seed % keys.length]);
  sequences.push([...sequence]);
 }
}
const fixtures = sequences.map(keys => {
 const c = new Calculator(); keys.forEach(k => c.press(k));
 return {keys, value:c.value, expression:c.expression, fresh:c.fresh, operation:c.operator, left:c.left};
});
fs.writeFileSync(path.join(__dirname,'fixtures.json'),JSON.stringify(fixtures));
console.log(`Generated ${fixtures.length} web reference states`);
