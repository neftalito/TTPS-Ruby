module.exports = {
    content: [
        "./app/views/**/*.{html,erb,haml,slim}",
        "./app/helpers/**/*.rb",
        "./app/frontend/**/*.{js,ts,vue}",
        "./node_modules/flowbite/**/*.js"
    ],
    theme: {
        extend: {
            colors: {
                'proyecto-text': '#2b2b2b',
                'proyecto-bg': '#faf6f5',
                'proyecto-primary': '#1a4d70',
                'proyecto-secondary': '#e9dcc9',
                'proyecto-accent': '#c46d45'
            }
        },
    },
    plugins: [
        require('flowbite/plugin'),
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
    ],
}
