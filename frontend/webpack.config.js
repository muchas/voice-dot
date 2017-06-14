const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = function (env) {
  const srcDir = path.resolve(__dirname, './src');
  const distDir = path.resolve(__dirname, './dist');

  return {
    context: srcDir,

    entry: './main.ts',
    output: {
      filename: 'app.bundle.js',
      path: distDir
    },

    module: {
      rules: [
        {
          test: /\.ts$/,
          use: 'ts-loader'
        },
        {
          test: /\.css$/,
          use: ['style-loader', 'css-loader']
        }
      ]
    },

    resolve: {
      extensions: ['.js', '.ts']
    },

    plugins: [
      new CopyWebpackPlugin([{
        from: '../ext-files', to: '../dist'
      }])
    ]
  }
}
