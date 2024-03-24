const path = require('path')

module.exports = {
    mode: "production",
    entry: { Chrono: "./index.js" },
    output: {
        path:  path.resolve(__dirname, "dist"),
        filename: "[name].bundle.js",
        library: "[name]",
        libraryTarget: "var"
    }
};