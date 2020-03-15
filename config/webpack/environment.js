const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const CompressionPlugin = require('compression-webpack-plugin')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery'
  }),
  new CompressionPlugin({
    filename: '[path].gz[query]',
    algorithm: 'brotliCompress',
    test: /\.js$|\.css$/,
    threshold: 10240,
    minRatio: 0.8,
    cache: true
  })
)

module.exports = environment
