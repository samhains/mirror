const path = require('path');

module.exports = {
  entry: path.join(__dirname, "src/main.js"),
  output: {
    // path: path.resolve(__dirname, "build"),
    filename: "bundle.js"
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015']
        }
      },
      {
        test: /\.glsl$/,
        loader: "webpack-glsl-loader"
      },
    ]
  },
  devtool: 'source-map',
  devServer: {
    port: 7000
  }
}