const chrono = require('chrono-node');


function parse(phrase, locale) {
  let result = null;
  if (!chrono[locale]) {
    // fallback to english
    locale = 'en'
  }
  return chrono[locale].parseDate(phrase);
}

let phrases = [
  ['tomorrow morning at 8am', 'en'],
  ['demain a 08h00 du matin', 'fr'],
  ['明天早上 8 点', 'zh'],
  ['mañana a las 8 de la mañana', 'es'],
]

// get date for tomorrow morning at 8am in current timezone
let date = new Date();
date.setDate(date.getDate() + 1);
date.setHours(8, 0, 0, 0);

for (let [phrase, locale] of phrases) {
  let newDate = parse(phrase, locale);
  if (newDate.getTime() !== date.getTime()) {
    console.error(`Failed to parse ${phrase} in ${locale}.\nExpected ${date}, got ${newDate}`);
  }
}
