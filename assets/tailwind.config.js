const plugin = require("tailwindcss/plugin");
const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/fotohaecker_web.ex",
    "../lib/fotohaecker_web/**/*.*ex",
  ],
  theme: {
    colors: {
      transparent: "transparent",
      black: colors.black,
      white: colors.white,
      gray: colors.stone,
      green: colors.emerald,
      red: colors.red,
      blue: colors.indigo,
    },
    extend: {
      colors: {
        signature: {
          grey: "#17161b",
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),
  ],
};
