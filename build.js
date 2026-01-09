const esbuild = require('esbuild');
const fs = require('fs');
const path = require('path');

async function build() {
  const outDir = path.join(__dirname, 'dist');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  // Bundle frontend JS: automatically include all .js files except package.js
  const jsDir = path.join(__dirname, 'frontend', 'assets', 'js');
  const entryPoints = fs.readdirSync(jsDir)
    .filter(f => f.endsWith('.js') && f !== 'package.js')
    .map(f => path.join(jsDir, f));

  if (entryPoints.length > 0) {
    await esbuild.build({
      entryPoints,
      outdir: path.join(outDir, 'assets/js'),
      bundle: true,
      minify: true,
      sourcemap: true,
      target: ['es2018']
    });
  }

  // Copy CSS and images
  const copy = (src, dest) => {
    if (!fs.existsSync(src)) return;
    const stat = fs.statSync(src);
    if (stat.isDirectory()) {
      fs.mkdirSync(dest, { recursive: true });
      fs.readdirSync(src).forEach(f => copy(path.join(src, f), path.join(dest, f)));
    } else {
      fs.mkdirSync(path.dirname(dest), { recursive: true });
      fs.copyFileSync(src, dest);
    }
  };

  copy(path.join(__dirname, 'frontend', 'assets', 'css'), path.join(outDir, 'assets', 'css'));
  copy(path.join(__dirname, 'frontend', 'assets', 'images'), path.join(outDir, 'assets', 'images'));

  // Copy pages
  copy(path.join(__dirname, 'frontend', 'pages'), path.join(outDir, 'pages'));

  console.log('Build complete. Output directory:', outDir);
}

build().catch(err => {
  console.error(err);
  process.exit(1);
});
