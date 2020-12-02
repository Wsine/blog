// This is where project configuration and plugin options are located.
// Learn more: https://gridsome.org/docs/config

// Changes here requires a server restart.
// To restart press CTRL + C in terminal and run `gridsome develop`

const marked = require('marked')

module.exports = {
  siteUrl: 'https://wsine.github.io/blog/',
  siteName: "Wsine's Blog",
  siteDescription: '爱分享爱写文章的科研狗',

  templates: {
    Post: '/:year/:month/:day/:fileInfo__name',
    Tag: '/tag/:id'
  },

  plugins: [
    {
      // Create posts from markdown files
      use: '@gridsome/source-filesystem',
      options: {
        typeName: 'Post',
        path: 'content/posts/*.md',
        refs: {
          // Creates a GraphQL collection from 'tags' in front-matter and adds a reference.
          tags: {
            typeName: 'Tag',
            create: true
          }
        }
      }
    },
    {
      use: '@microflash/gridsome-plugin-feed',
      options: {
        contentTypes: ['Post'],
        feedOptions: {
          title: "Wsine's Blog",
          description: '爱分享爱写文章的科研狗',
          image: 'https://wsine.github.io/blog/author.jpg',
          favicon: 'https://wsine.github.io/blog/favicon.ico',
        },
        rss: {
          enabled: true,
          output: '/feed.xml',
        },
        htmlFields: ['description', 'content'],
        enforceTrailingSlashes: false,
        nodeToFeedItem: node => ({
          title: node.title,
          date: node.date,
          content: marked(node.content),
        }),
      },
    }
  ],

  transformers: {
    //Add markdown support to all file-system sources
    remark: {
      externalLinksTarget: '_blank',
      externalLinksRel: ['nofollow', 'noopener', 'noreferrer'],
      anchorClassName: 'icon icon-link',
      plugins: [
        '@gridsome/remark-prismjs'
      ]
    }
  }
}
