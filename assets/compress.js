const sharp = require("sharp");
const fs = require("fs/promises");

module.exports = (path, extension) => {
  const src = `${path}${extension}`;
  const dest = {
    fullsize: `${path}_og${extension}`,
    preview: `${path}_preview${extension}`,
    thumb1x: `${path}_thumb@1x${extension}`,
    thumb2x: `${path}_thumb@2x${extension}`,
    thumb3x: `${path}_thumb@3x${extension}`,
  };

  // generate fullsize
  const fullsize = sharp(src).jpeg({ mozjpeg: true });
  // generate preview
  const preview = sharp(src).jpeg({ mozjpeg: true }).resize(1400);
  // generate thumbs
  const thumb1x = sharp(src).jpeg({ mozjpeg: true }).resize(275);
  const thumb2x = sharp(src).jpeg({ mozjpeg: true }).resize(400);
  const thumb3x = sharp(src).jpeg({ mozjpeg: true }).resize(500);

  return Promise.all([
    preview.toFile(dest.preview),
    thumb1x.toFile(dest.thumb1x),
    thumb2x.toFile(dest.thumb2x),
    thumb3x.toFile(dest.thumb3x),
    fullsize.toFile(dest.fullsize),
  ]);
};
