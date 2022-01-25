const mix = require('laravel-mix')

mix.js('resources/js/app.js', 'public/js')
    .vue()
    .sass('resources/scss/app.scss', 'public/css')
    .sourceMaps()
    .webpackConfig(require('./webpack.config'))
    .disableNotifications()

if (mix.inProduction()) {
    mix.version()
} else {
    mix.browserSync({
        proxy: 'localhost',
        open: false,
        notify: false
    })
}