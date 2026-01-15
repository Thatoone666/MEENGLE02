const fs = require('fs');
const path = require('path');

// Create dist directory
const distDir = path.join(__dirname, '..', 'dist');
if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
}

// Copy index.html
const indexHtml = path.join(__dirname, '..', 'index.html');
if (fs.existsSync(indexHtml)) {
  fs.copyFileSync(indexHtml, path.join(distDir, 'index.html'));
  console.log('? Copied index.html');
}

// Copy pages
const pagesDir = path.join(__dirname, '..', 'pages');
if (fs.existsSync(pagesDir)) {
  copyDirRecursive(pagesDir, distDir);
  console.log('? Copied pages/');
}

// Copy assets
const assetsDir = path.join(__dirname, '..', 'assets');
if (fs.existsSync(assetsDir)) {
  const destAssetsDir = path.join(distDir, 'assets');
  copyDirRecursive(assetsDir, destAssetsDir);
  console.log('? Copied assets/');
}

// Copy src
const srcDir = path.join(__dirname, '..', 'src');
if (fs.existsSync(srcDir)) {
  const destSrcDir = path.join(distDir, 'src');
  copyDirRecursive(srcDir, destSrcDir);
  console.log('? Copied src/');
}

// Create 404.html for SPA routing
const notFoundPath = path.join(distDir, '404.html');
if (!fs.existsSync(notFoundPath)) {
  const indexPath = path.join(distDir, 'index.html');
  if (fs.existsSync(indexPath)) {
    fs.copyFileSync(indexPath, notFoundPath);
    console.log('? Created 404.html');
  }
}

console.log('? Build complete!');

function copyDirRecursive(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  
  fs.readdirSync(src).forEach(file => {
    const srcPath = path.join(src, file);
    const destPath = path.join(dest, file);
    
    if (fs.statSync(srcPath).isDirectory()) {
      copyDirRecursive(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  });
}
