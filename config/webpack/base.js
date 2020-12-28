const { webpackConfig } = require('@rails/webpacker')

// const webpack = require('webpack')

// webpackConfig.plugins.append('Provide',
//     new webpack.ProvidePlugin({
//         $: 'jquery',
//         jQuery: 'jquery/src/jquery',
//         Popper: ['popper.js', 'default']
//     })
// )

// const globImporter = require('node-sass-glob-importer');

// webpackConfig.loaders.get('sass').use
//     .find(item => item.loader === 'sass-loader')
//     .options = { sassOptions: { importer: globImporter() } };

module.exports = webpackConfig
