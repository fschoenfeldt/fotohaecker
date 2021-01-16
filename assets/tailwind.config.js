const devMode = process.env.NODE_ENV !== "production";

module.exports = {
  purge: devMode
    ? false
    : ["../lib/**/*.ex", "../lib/**/*.leex", "../lib/**/*.eex", "./js/**/*.js"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/forms")],
};
