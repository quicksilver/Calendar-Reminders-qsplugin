export function parse(phrase, locale) {
    let result = null;
    if (chrono[locale]) {
      result = chrono[locale].parse(phrase);
    }
    if (!result) {
      // fallback to English
      result = chrono.parse(phrase);
    }
    return result;
  }