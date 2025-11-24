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
          50: '#f4f7fb',
          100: '#eef2f6',
          200: '#dce4ed',
          300: '#bdcde0',
          400: '#96b0cf',
          500: '#7395bd',
          600: '#567aa3',
          700: '#456285',
          800: '#3b516c',
          900: '#334459',
          950: '#232d3b',
        },
        secondary: {
          50: '#fbf9f5',
          100: '#f6f3eb',
          200: '#eae2d0',
          300: '#dacba8',
          400: '#c8ad7b',
          500: '#b59259', // Gold-ish
          600: '#9a7646',
          700: '#7b5b3a',
          800: '#664b35',
          900: '#543e2f',
          950: '#2e2118',
        },
        background: '#0f172a', // Deep slate/navy
        surface: '#1e293b', // Slate 800
        surfaceHighlight: '#334155', // Slate 700
        text: '#f1f5f9', // Slate 100
        textMuted: '#94a3b8', // Slate 400
        accent: '#b59259'
      },
      fontFamily: {
        sans: ['Inter', 'Segoe UI', 'sans-serif'],
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out',
        'slide-up': 'slideUp 0.5s ease-out',
        'slide-in-right': 'slideInRight 0.4s ease-out',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'float': 'float 6s ease-in-out infinite',
        'shimmer': 'shimmer 2.5s linear infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideInRight: {
          '0%': { transform: 'translateX(100%)', opacity: '0' },
          '100%': { transform: 'translateX(0)', opacity: '1' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-1000px 0' },
          '100%': { backgroundPosition: '1000px 0' },
        }
      },
      boxShadow: {
        'glass': '0 8px 32px 0 rgba(0, 0, 0, 0.37)',
        'glass-sm': '0 4px 16px 0 rgba(0, 0, 0, 0.2)',
        'glow': '0 0 15px rgba(115, 149, 189, 0.5)',
      },
      backdropBlur: {
        'xs': '2px',
      }
    },
  },
  plugins: [],
}
