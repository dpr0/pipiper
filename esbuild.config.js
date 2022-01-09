const path = require('path')
const rails = require('esbuild-rails')
const ImportGlobPlugin = require('esbuild-plugin-import-glob').default;

require("esbuild").build({
    entryPoints: ["application.js"],
    bundle: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    absWorkingDir: path.join(process.cwd(), "app/javascript"),
    watch: process.argv.includes("--watch"),
    plugins: [rails(), ImportGlobPlugin()],
    loader: { '.js': 'jsx' },
}).catch(() => process.exit(1))
