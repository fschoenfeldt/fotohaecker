module.exports = {
  purge: [
    "lib/fotohaecker_web/**/*.eex",
    "lib/fotohaecker_web/**/*.leex",
    "lib/fotohaecker_web/**/*.ex",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/forms")],
};
