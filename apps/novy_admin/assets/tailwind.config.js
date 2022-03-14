// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
    content: [
        './ts/**/*.ts',
        '../lib/*_admin.ex',
        '../lib/*_admin/**/*.*ex'
    ],
    theme: {
        extend: {},
    },
    plugins: [
        require('@tailwindcss/forms')
    ]
}