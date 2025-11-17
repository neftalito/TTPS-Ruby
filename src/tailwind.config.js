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
                'proyecto-text':      '#1F1C1A',
                'proyecto-bg':        '#F6F1EA',
                'proyecto-primary':   '#744C32',
                'proyecto-secondary': '#D9C7B3',
                'proyecto-accent':    '#B65E3C',
                'proyecto-success':   '#6A8C58',
                'proyecto-error':     '#9E473B',
                'proyecto-warning':   '#C28A3A',
                'proyecto-info':      '#5A7C94',
            }
        },
    },
    plugins: [
        require('flowbite/plugin'),
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
    ],
}
