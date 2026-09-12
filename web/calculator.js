/* Decimal arithmetic uses integers to avoid errors such as 0.1 + 0.2. */
(function(root) {
  function calculate(a, b, operator) {
    const scale = Math.max((a.split('.')[1] || '').length, (b.split('.')[1] || '').length);
    const integer = value => {
      const [whole, fraction = ''] = value.split('.');
      return BigInt(whole + fraction.padEnd(scale, '0'));
    };
    const result = operator === '+' ? integer(a) + integer(b) : integer(a) - integer(b);
    const negative = result < 0n;
    let digits = (negative ? -result : result).toString().padStart(scale + 1, '0');
    if (scale) digits = (digits.slice(0, -scale) + '.' + digits.slice(-scale)).replace(/0+$/, '').replace(/\.$/, '');
    return (negative ? '-' : '') + digits;
  }
  class Calculator {
    constructor() { this.clear(); }
    clear() { this.value = '0'; this.left = null; this.operator = null; this.fresh = false; this.expression = ''; }
    press(key) {
      if (key === 'clear') return this.clear();
      if (/^[0-9.]$/.test(key)) {
        if (this.fresh) { this.value = '0'; this.fresh = false; if (!this.operator) this.expression = ''; }
        if (key === '.') { if (!this.value.includes('.')) this.value += '.'; return; }
        if (this.value.replace(/[-.]/g, '').length >= 18) return;
        this.value = this.value === '0' ? key : this.value === '-0' ? '-' + key : this.value + key;
      } else if (key === 'sign') {
        if (this.fresh && this.operator) { this.value = '-0'; this.fresh = false; }
        else { this.value = this.value.startsWith('-') ? this.value.slice(1) : '-' + this.value; this.fresh = false; }
      } else if (key === 'back') {
        if (this.fresh) return;
        this.value = this.value.slice(0, -1);
        if (!this.value || this.value === '-') this.value = '0';
      } else if (key === '+' || key === '-') {
        if (this.operator && !this.fresh) this.value = calculate(this.left, this.value, this.operator);
        this.left = this.value; this.operator = key; this.fresh = true;
        this.expression = this.left + ' ' + key;
      } else if (key === '=' && this.operator && !this.fresh) {
        this.expression = this.left + ' ' + this.operator + ' ' + this.value + ' =';
        this.value = calculate(this.left, this.value, this.operator);
        this.operator = null; this.left = null; this.fresh = true;
      }
    }
  }
  if (typeof module !== 'undefined') module.exports = {calculate, Calculator};
  else root.Calculator = Calculator;
})(typeof globalThis !== 'undefined' ? globalThis : this);
