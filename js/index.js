import * as chrono from 'chrono-node';


export class Chrono {
  static parse(phrase, locale) {
    let result = null;
    if (!chrono[locale]) {
      // fallback to english
      locale = 'en'
    }
    return chrono.parseDate(phrase);
  }
}