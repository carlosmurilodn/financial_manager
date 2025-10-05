const esbuild = require("esbuild");
const { sassPlugin } = require("esbuild-sass-plugin");

esbuild.build({
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  outdir: "app/assets/builds",
  format: "esm",
  sourcemap: true,
  plugins: [sassPlugin()]
}).catch(() => process.exit(1));
