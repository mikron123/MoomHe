/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#007AFF',
          600: '#0056CC',
          700: '#004499',
          800: '#003377',
          900: '#002255',
        },
        background: '#F4F4F4',
        text: '#333333',
        accent: '#007AFF'
      }
    },
  },
  plugins: [],
}
