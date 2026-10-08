const esbuild = require("esbuild");
const { sassPlugin } = require("esbuild-sass-plugin");

const options = {
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  outdir: "app/assets/builds",
  format: "esm",
  sourcemap: true,
  plugins: [sassPlugin()]
};

async function run() {
  if (process.argv.includes("--watch")) {
    const context = await esbuild.context(options);
    await context.watch();
    console.log("Assets: monitorando alterações em JavaScript e Sass.");
    for (const signal of ["SIGINT", "SIGTERM"]) {
      process.once(signal, async () => {
        await context.dispose();
        process.exit(0);
      });
    }
  } else {
    await esbuild.build(options);
  }
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
