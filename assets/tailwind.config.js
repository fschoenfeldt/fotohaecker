const devMode = process.env.NODE_ENV !== "production";

module.exports = {
  purge: devMode
    ? false
    : ["../lib/**/*.ex", "../lib/**/*.leex", "../lib/**/*.eex", "./js/**/*.js"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fontFamily: {
        sans: ["IBM Plex Sans", "sans-serif"],
        // heading: ["Oswald", "sans-serif"],
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/forms")],
};
