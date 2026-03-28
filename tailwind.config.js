/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
  ],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: "#6366F1",
        "primary-dark": "#4F46E5",
        secondary: "#64748B",
        surface: "#F1F5F9",
        border: "#E8EAED",
        danger: "#EF4444",
        success: "#10B981",
        warning: "#F59E0B",
        muted: "#94A3B8",
      },
    },
  },
  plugins: [],
}

