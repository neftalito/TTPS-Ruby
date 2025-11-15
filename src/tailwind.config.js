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
                'proyecto-accent': '#c46d45',
                'proyecto-success': '#4CAF50',
                'proyecto-error':   '#E53935',
                'proyecto-warning': '#FB8C00',
                'proyecto-info':    '#1E88E5',
            }
        },
    },
    plugins: [
        require('flowbite/plugin'),
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
    ],
}
