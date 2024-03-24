import * as chrono from 'chrono-node';


export class Chrono {
  static parse(phrase) {
    return chrono.parseDate(phrase);
  }
}