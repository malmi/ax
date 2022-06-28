module.exports = {
  title: 'AX Documentation',
  description:
    'Poor folks version of actors for a nice state management that is more event driven and should be used if you are an advocate of event sourcing.',
  head: [['link', { rel: 'icon', href: '/logo.png' }]],
  themeConfig: {
    displayAllHeaders: true,
    logo: '/assets/img/logo.png',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'External', link: 'https://google.com' },
    ],
    searchPlaceholder: 'Search...',
    sidebar: 'auto',
    sidebarDepth: 2,
    smoothScroll: true,
  },
  dest: '.vuepress/dist',
  extraWatchFiles: ['../docs/**'],
};
